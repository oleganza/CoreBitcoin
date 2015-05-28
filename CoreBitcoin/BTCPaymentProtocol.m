// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCPaymentProtocol.h"
#import "BTCPaymentRequest.h"
#import "BTCErrors.h"
#import "BTCAssetType.h"
#import <Security/Security.h>

@interface BTCPaymentProtocol ()
@property(nonnull, nonatomic, readwrite) NSArray* assetTypes;
@property(nonnull, nonatomic) NSArray* paymentRequestMediaTypes;
@end

@implementation BTCPaymentProtocol

// Instantiates default BIP70 protocol that supports only Bitcoin.
- (nonnull id) init {
    return [self initWithAssetTypes:@[ BTCAssetTypeBitcoin ]];
}

// Instantiates protocol instance with accepted asset types.
- (nonnull id) initWithAssetTypes:(nonnull NSArray*)assetTypes {
    NSParameterAssert(assetTypes);
    NSParameterAssert(assetTypes.count > 0);
    if (self = [super init]) {
        self.assetTypes = assetTypes;
    }
    return self;
}

- (NSArray*) paymentRequestMediaTypes {
    if (!_paymentRequestMediaTypes && self.assetTypes) {
        NSMutableArray* arr = [NSMutableArray array];
        for (NSString* assetType in self.assetTypes) {
            if ([assetType isEqual:BTCAssetTypeBitcoin]) {
                [arr addObject:@"application/bitcoin-paymentrequest"];
            } else if ([assetType isEqual:BTCAssetTypeOpenAssets]) {
                [arr addObject:@"application/oa-paymentrequest"];
            }
        }
        _paymentRequestMediaTypes = arr;
    }
    return _paymentRequestMediaTypes;
}

- (NSInteger) maxDataLength {
    return 50000;
}


// Convenience API


- (void) loadPaymentRequestFromURL:(nonnull NSURL*)paymentRequestURL completionHandler:(nonnull void(^)(BTCPaymentRequest* __nullable pr, NSError* __nullable error))completionHandler {
    NSParameterAssert(paymentRequestURL);
    NSParameterAssert(completionHandler);

    NSURLRequest* request = [self requestForPaymentRequestWithURL:paymentRequestURL];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        BTCPaymentRequest* pr = [self paymentRequestFromData:data response:response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(pr, pr ? nil : error);
        });
    });
}

- (void) postPayment:(nonnull BTCPayment*)payment URL:(nonnull NSURL*)paymentURL completionHandler:(nonnull void(^)(BTCPaymentACK* __nullable ack, NSError* __nullable error))completionHandler {
    NSParameterAssert(payment);
    NSParameterAssert(paymentURL);
    NSParameterAssert(completionHandler);

    NSURLRequest* request = [self requestForPayment:payment url:paymentURL];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        BTCPaymentACK* ack = [self paymentACKFromData:data response:response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(ack, ack ? nil : error);
        });
    });
}


// Low-level API
// (use this if you have your own connection queue).

- (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL {
    return [self requestForPaymentRequestWithURL:paymentRequestURL timeout:10];
}

- (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL timeout:(NSTimeInterval)timeout {
    if (!paymentRequestURL) return nil;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:paymentRequestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    for (NSString* mimeType in self.paymentRequestMediaTypes) {
        [request addValue:mimeType forHTTPHeaderField:@"Accept"];
    }
    return request;
}

- (BTCPaymentRequest*) paymentRequestFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {

    if (![self.paymentRequestMediaTypes containsObject:response.MIMEType.lowercaseString]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    if (data.length > [self maxDataLength]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestTooBig userInfo:@{}];
        return nil;
    }
    BTCPaymentRequest* pr = [[BTCPaymentRequest alloc] initWithData:data];
    if (!pr) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    return pr;
}

- (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL {
    return [self requestForPayment:payment url:paymentURL timeout:10];
}

- (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL timeout:(NSTimeInterval)timeout {
    if (!payment) return nil;
    if (!paymentURL) return nil;

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:paymentURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];

    [request addValue:@"application/bitcoin-payment" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/bitcoin-paymentack" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:payment.data];
    return request;
}

- (BTCPaymentACK*) paymentACKFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {

    if (![response.MIMEType.lowercaseString isEqual:@"application/bitcoin-paymentack"]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    if (data.length > [self maxDataLength]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestTooBig userInfo:@{}];
        return nil;
    }

    BTCPaymentACK* ack = [[BTCPaymentACK alloc] initWithData:data];

    if (!ack) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    
    return ack;
}




// DEPRECATED METHODS

+ (void) loadPaymentRequestFromURL:(NSURL*)paymentRequestURL completionHandler:(void(^)(BTCPaymentRequest* pr, NSError* error))completionHandler {
    [[[self alloc] init] loadPaymentRequestFromURL:paymentRequestURL completionHandler:completionHandler];
}
+ (void) postPayment:(BTCPayment*)payment URL:(NSURL*)paymentURL completionHandler:(void(^)(BTCPaymentACK* ack, NSError* error))completionHandler {
    [[[self alloc] init] postPayment:payment URL:paymentURL completionHandler:completionHandler];
}

+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL {
    return [self requestForPaymentRequestWithURL:paymentRequestURL timeout:10];
}

+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL timeout:(NSTimeInterval)timeout {
    return [[[self alloc] init] requestForPaymentRequestWithURL:paymentRequestURL timeout:timeout];
}

+ (BTCPaymentRequest*) paymentRequestFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {
    return [[[self alloc] init] paymentRequestFromData:data response:response error:errorOut];
}

+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL {
    return [self requestForPayment:payment url:paymentURL timeout:10];
}

+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL timeout:(NSTimeInterval)timeout {
    return [[[self alloc] init] requestForPayment:payment url:paymentURL timeout:timeout];
}

+ (BTCPaymentACK*) paymentACKFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {
    return [[[self alloc] init] paymentACKFromData:data response:response error:errorOut];
}

@end


