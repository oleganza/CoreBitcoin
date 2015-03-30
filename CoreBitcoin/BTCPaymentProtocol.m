// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCPaymentProtocol.h"
#import "BTCProtocolBuffers.h"
#import "BTCErrors.h"
#import "BTCData.h"
#import "BTCNetwork.h"
#import "BTCScript.h"
#import "BTCTransaction.h"
#import "BTCTransactionOutput.h"
#import <Security/Security.h>

NSInteger const BTCPaymentRequestVersion1 = 1;

NSString* const BTCPaymentRequestPKITypeNone = @"none";
NSString* const BTCPaymentRequestPKITypeX509SHA1 = @"x509+sha1";
NSString* const BTCPaymentRequestPKITypeX509SHA256 = @"x509+sha256";

BTCAmount const BTCUnspecifiedPaymentAmount = -1;

typedef NS_ENUM(NSInteger, BTCOutputKey) {
    BTCOutputKeyAmount = 1,
    BTCOutputKeyScript = 2
};

typedef NS_ENUM(NSInteger, BTCRequestKey) {
    BTCRequestKeyVersion        = 1,
    BTCRequestKeyPkiType        = 2,
    BTCRequestKeyPkiData        = 3,
    BTCRequestKeyPaymentDetails = 4,
    BTCRequestKeySignature      = 5
};

typedef NS_ENUM(NSInteger, BTCDetailsKey) {
    BTCDetailsKeyNetwork      = 1,
    BTCDetailsKeyOutputs      = 2,
    BTCDetailsKeyTime         = 3,
    BTCDetailsKeyExpires      = 4,
    BTCDetailsKeyMemo         = 5,
    BTCDetailsKeyPaymentURL   = 6,
    BTCDetailsKeyMerchantData = 7
};

typedef NS_ENUM(NSInteger, BTCCertificatesKey) {
    BTCCertificatesKeyCertificate = 1
};

typedef NS_ENUM(NSInteger, BTCPaymentKey) {
    BTCPaymentKeyMerchantData = 1,
    BTCPaymentKeyTransactions = 2,
    BTCPaymentKeyRefundTo     = 3,
    BTCPaymentKeyMemo         = 4
};

typedef NS_ENUM(NSInteger, BTCPaymentAckKey) {
    BTCPaymentAckKeyPayment = 1,
    BTCPaymentAckKeyMemo    = 2
};




@implementation BTCPaymentProtocol

// Convenience API

// Loads a BTCPaymentRequest object from a given URL.
+ (void) loadPaymentRequestFromURL:(NSURL*)paymentRequestURL completionHandler:(void(^)(BTCPaymentRequest* pr, NSError* error))completionHandler {
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

// Posts completed payment object to a given payment URL (provided in BTCPaymentDetails) and
// returns a PaymentACK object.
+ (void) postPayment:(BTCPayment*)payment URL:(NSURL*)paymentURL completionHandler:(void(^)(BTCPaymentACK* ack, NSError* error))completionHandler {
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

+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL {
    return [self requestForPaymentRequestWithURL:paymentRequestURL timeout:10];
}

+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL timeout:(NSTimeInterval)timeout {
    if (!paymentRequestURL) return nil;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:paymentRequestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    [request addValue:@"application/bitcoin-paymentrequest" forHTTPHeaderField:@"Accept"];
    return request;
}

+ (BTCPaymentRequest*) paymentRequestFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {

    if (![response.MIMEType.lowercaseString isEqual:@"application/bitcoin-paymentrequest"]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    if (data.length > 50000) {
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

+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL {
    return [self requestForPayment:payment url:paymentURL timeout:10];
}

+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL timeout:(NSTimeInterval)timeout {
    if (!payment) return nil;
    if (!paymentURL) return nil;

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:paymentURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];

    [request addValue:@"application/bitcoin-payment" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/bitcoin-paymentack" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:payment.data];
    return request;
}

+ (BTCPaymentACK*) paymentACKFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut {

    if (![response.MIMEType.lowercaseString isEqual:@"application/bitcoin-paymentack"]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorPaymentRequestInvalidResponse userInfo:@{}];
        return nil;
    }
    if (data.length > 50000) {
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

@end













@interface BTCPaymentRequest ()
// If you make these publicly writable, make sure to set _data to nil and _isValidated to NO.
@property(nonatomic, readwrite) NSInteger version;
@property(nonatomic, readwrite) NSString* pkiType;
@property(nonatomic, readwrite) NSData* pkiData;
@property(nonatomic, readwrite) BTCPaymentDetails* details;
@property(nonatomic, readwrite) NSData* signature;
@property(nonatomic, readwrite) NSArray* certificates;
@property(nonatomic, readwrite) NSData* data;

@property(nonatomic) BOOL isValidated;
@property(nonatomic, readwrite) BOOL isValid;
@property(nonatomic, readwrite) NSString* signerName;
@property(nonatomic, readwrite) BTCPaymentRequestStatus status;
@end


@interface BTCPaymentDetails ()
@property(nonatomic, readwrite) BTCNetwork* network;
@property(nonatomic, readwrite) NSArray* /*[BTCTransactionOutput]*/ outputs;
@property(nonatomic, readwrite) NSDate* date;
@property(nonatomic, readwrite) NSDate* expirationDate;
@property(nonatomic, readwrite) NSString* memo;
@property(nonatomic, readwrite) NSURL* paymentURL;
@property(nonatomic, readwrite) NSData* merchantData;
@property(nonatomic, readwrite) NSData* data;
@end


@interface BTCPayment ()
@property(nonatomic, readwrite) NSData* merchantData;
@property(nonatomic, readwrite) NSArray* /*[BTCTransaction]*/ transactions;
@property(nonatomic, readwrite) NSArray* /*[BTCTransactionOutput]*/ refundOutputs;
@property(nonatomic, readwrite) NSString* memo;
@property(nonatomic, readwrite) NSData* data;
@end


@interface BTCPaymentACK ()
@property(nonatomic, readwrite) BTCPayment* payment;
@property(nonatomic, readwrite) NSString* memo;
@property(nonatomic, readwrite) NSData* data;
@end







@implementation BTCPaymentRequest

- (id) initWithData:(NSData*)data {
    if (!data) return nil;

    if (self = [super init]) {

        NSInteger offset = 0;
        while (offset < data.length) {
            uint64_t i = 0;
            NSData* d = nil;

            switch ([BTCProtocolBuffers fieldAtOffset:&offset int:&i data:&d fromData:data]) {
                case BTCRequestKeyVersion:
                    if (i) _version = (uint32_t)i;
                    break;
                case BTCRequestKeyPkiType:
                    if (d) _pkiType = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                    break;
                case BTCRequestKeyPkiData:
                    if (d) _pkiData = d;
                    break;
                case BTCRequestKeyPaymentDetails:
                    if (d) _details = [[BTCPaymentDetails alloc] initWithData:d];
                    break;
                case BTCRequestKeySignature:
                    if (d) _signature = d;
                    break;
                default: break;
            }
        }

        // Payment details are required.
        if (!_details) return nil;
    }
    return self;
}

- (NSData*) data {
    if (!_data) {
        _data = [self dataWithSignature:_signature];
    }
    return _data;
}

- (NSData*) dataForSigning {
    return [self dataWithSignature:[NSData data]];
}

- (NSData*) dataWithSignature:(NSData*)signature {
    NSMutableData* data = [NSMutableData data];

    // Note: we should reconstruct the data exactly as it was on the input.
    if (_version > 0) {
        [BTCProtocolBuffers writeInt:_version withKey:BTCRequestKeyVersion toData:data];
    }
    if (_pkiType) {
        [BTCProtocolBuffers writeString:_pkiType withKey:BTCRequestKeyPkiType toData:data];
    }
    if (_pkiData) {
        [BTCProtocolBuffers writeData:_pkiData withKey:BTCRequestKeyPkiData toData:data];
    }

    [BTCProtocolBuffers writeData:self.details.data withKey:BTCRequestKeyPaymentDetails toData:data];

    if (signature) {
        [BTCProtocolBuffers writeData:signature withKey:BTCRequestKeySignature toData:data];
    }
    return data;
}

- (NSInteger) version
{
    return (_version > 0) ? _version : BTCPaymentRequestVersion1;
}

- (NSString*) pkiType
{
    return _pkiType ?: BTCPaymentRequestPKITypeNone;
}

- (NSArray*) certificates {
    if (!_certificates) {
        NSMutableArray* certs = [NSMutableArray array];
        NSInteger offset = 0;
        while (offset < self.pkiData.length) {
            NSData* d = nil;
            NSInteger key = [BTCProtocolBuffers fieldAtOffset:&offset int:NULL data:&d fromData:self.pkiData];
            if (key == BTCCertificatesKeyCertificate && d) {
                [certs addObject:d];
            }
        }
        _certificates = certs;
    }
    return _certificates;
}

- (BOOL) isValid {
    if (!_isValidated) [self validatePaymentRequest];
    return _isValid;
}

- (NSString*) signerName {
    if (!_isValidated) [self validatePaymentRequest];
    return _signerName;
}

- (BTCPaymentRequestStatus) status {
    if (!_isValidated) [self validatePaymentRequest];
    return _status;
}

- (void) validatePaymentRequest {
    _isValidated = YES;
    _isValid = NO;

    if ([self.pkiType isEqual:BTCPaymentRequestPKITypeX509SHA1] ||
        [self.pkiType isEqual:BTCPaymentRequestPKITypeX509SHA256]) {

        // 1. Verify chain of trust

        NSMutableArray *certs = [NSMutableArray array];
        NSArray *policies = @[CFBridgingRelease(SecPolicyCreateBasicX509())];
        SecTrustRef trust = NULL;
        SecTrustResultType trustResult = kSecTrustResultInvalid;

        for (NSData *certData in self.certificates) {
            SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
            if (cert) [certs addObject:CFBridgingRelease(cert)];
        }

        if (certs.count > 0) {
            _signerName = CFBridgingRelease(SecCertificateCopySubjectSummary((__bridge SecCertificateRef)certs[0]));
        }

        SecTrustCreateWithCertificates((__bridge CFArrayRef)certs, (__bridge CFArrayRef)policies, &trust);
        SecTrustEvaluate(trust, &trustResult); // verify certificate chain

        // kSecTrustResultUnspecified indicates the evaluation succeeded
        // and the certificate is implicitly trusted, but user intent was not
        // explicitly specified.
        if (trustResult != kSecTrustResultUnspecified && trustResult != kSecTrustResultProceed) {
            if (certs.count > 0) {
                _status = BTCPaymentRequestStatusUntrustedCertificate;
            } else {
                _status = BTCPaymentRequestStatusMissingCertificate;
            }
            return;
        }

        // 2. Verify signature

#if TARGET_OS_IPHONE
        SecKeyRef pubKey = SecTrustCopyPublicKey(trust);
        SecPadding padding = kSecPaddingPKCS1;
        NSData* hash = nil;

        NSData* dataForSigning = [self dataForSigning];
        if ([self.pkiType isEqual:BTCPaymentRequestPKITypeX509SHA256]) {
            hash = BTCSHA256(dataForSigning);
            padding = kSecPaddingPKCS1SHA256;
        }
        else if ([self.pkiType isEqual:BTCPaymentRequestPKITypeX509SHA1]) {
            hash = BTCSHA1(dataForSigning);
            padding = kSecPaddingPKCS1SHA1;
        }

        OSStatus status = SecKeyRawVerify(pubKey, padding, hash.bytes, hash.length, _signature.bytes, _signature.length);

        CFRelease(pubKey);

        if (status != errSecSuccess) {
            _status = BTCPaymentRequestStatusInvalidSignature;
            return;
        }

        _status = BTCPaymentRequestStatusValid;
        _isValid = YES;
#else
        // On OS X 10.10 we don't have kSecPaddingPKCS1SHA256 and SecKeyRawVerify.
        // So we have to verify the signature using Security Transforms API.

        //  Here's a draft of what needs to be done here.
        /*
         CFErrorRef* error = NULL;
         verifier = SecVerifyTransformCreate(publickey, signature, &error);
         if (!verifier) { CFShow(error); exit(-1); }
         if (!SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, dataForSigning, &error) {
            CFShow(error);
            exit(-1);
         }
         // if it's sha256, then set SHA2 digest type and 32 bytes length.
         if (!SecTransformSetAttribute(verifier, kSecDigestTypeAttribute, kSecDigestSHA2, &error) {
            CFShow(error);
            exit(-1);
         }
         // Not sure if the length is in bytes or bits. Quinn The Eskimo says it's in bits:
         // https://devforums.apple.com/message/1119092#1119092
         if (!SecTransformSetAttribute(verifier, kSecDigestLengthAttribute, @(256), &error) {
            CFShow(error);
            exit(-1);
         }

         result = SecTransformExecute(verifier, &error);
         if (error) {
            CFShow(error);
            exit(-1);
         }
         if (result == kCFBooleanTrue) {
            // signature is valid
             _status = BTCPaymentRequestStatusValid;
             _isValid = YES;
         } else {
            // signature is invalid.
             _status = BTCPaymentRequestStatusInvalidSignature;
             _isValid = NO;
            return NO;
         }
         
         // -----------------------------------------------------------------------
         
         // From CryptoCompatibility sample code (QCCRSASHA1VerifyT.m):

         BOOL                success;
         SecTransformRef     transform;
         CFBooleanRef        result;
         CFErrorRef          errorCF;

         result = NULL;
         errorCF = NULL;

         // Set up the transform.

         transform = SecVerifyTransformCreate(self.publicKey, (__bridge CFDataRef) self.signatureData, &errorCF);
         success = (transform != NULL);

         // Note: kSecInputIsAttributeName defaults to kSecInputIsPlainText, which is what we want.

         if (success) {
         success = SecTransformSetAttribute(transform, kSecDigestTypeAttribute, kSecDigestSHA1, &errorCF) != false;
         }

         if (success) {
         success = SecTransformSetAttribute(transform, kSecTransformInputAttributeName, (__bridge CFDataRef) self.inputData, &errorCF) != false;
         }

         // Run it.

         if (success) {
         result = SecTransformExecute(transform, &errorCF);
         success = (result != NULL);
         }

         // Process the results.

         if (success) {
         assert(CFGetTypeID(result) == CFBooleanGetTypeID());
         self.verified = (CFBooleanGetValue(result) != false);
         } else {
         assert(errorCF != NULL);
         self.error = (__bridge NSError *) errorCF;
         }

         // Clean up.

         if (result != NULL) {
         CFRelease(result);
         }
         if (errorCF != NULL) {
         CFRelease(errorCF);
         }
         if (transform != NULL) {
         CFRelease(transform);
         }
         */

        _status = BTCPaymentRequestStatusUnknown;
        _isValid = NO;
        return;
#endif

    } else {
        // Either "none" PKI type or some new and unsupported PKI.

        if (self.certificates.count > 0) {
            // Non-standard extension to include a signer's name without actually signing request.
            _signerName = [[NSString alloc] initWithData:self.certificates[0] encoding:NSUTF8StringEncoding];
        }

        if ([self.pkiType isEqual:BTCPaymentRequestPKITypeNone]) {
            _isValid = YES;
            _status = BTCPaymentRequestStatusUnsigned;
        } else {
            _isValid = NO;
            _status = BTCPaymentRequestStatusUnknown;
        }
    }

    if (self.details.expirationDate && [[NSDate date] timeIntervalSinceDate:self.details.expirationDate] > 0.0) {
        _status = BTCPaymentRequestStatusExpired;
        _isValid = NO;
        return;
    }
}

- (BTCPayment*) paymentWithTransaction:(BTCTransaction*)tx {
    if (!tx) return nil;
    return [self paymentWithTransactions:@[ tx ] memo:nil];
}

- (BTCPayment*) paymentWithTransactions:(NSArray*)txs memo:(NSString*)memo {
    if (!txs || txs.count == 0) return nil;
    BTCPayment* payment = [[BTCPayment alloc] init];
    payment.merchantData = self.details.merchantData;
    payment.transactions = txs;
    payment.memo = memo;
    return payment;
}

@end
























@implementation BTCPaymentDetails

- (id) initWithData:(NSData*)data {
    if (!data) return nil;

    if (self = [super init]) {
        NSMutableArray* outputs = [NSMutableArray array];

        NSInteger offset = 0;
        while (offset < data.length) {
            uint64_t integer = 0;
            NSData* d = nil;

            switch ([BTCProtocolBuffers fieldAtOffset:&offset int:&integer data:&d fromData:data]) {
                case BTCDetailsKeyNetwork:
                    if (d) {
                        NSString* networkName = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                        if ([networkName isEqual:@"main"]) {
                            _network = [BTCNetwork mainnet];
                        } else if ([networkName isEqual:@"test"]) {
                            _network = [BTCNetwork testnet];
                        } else {
                            _network = [[BTCNetwork alloc] initWithName:networkName];
                        }
                    }
                    break;
                case BTCDetailsKeyOutputs: {
                    NSInteger offset2 = 0;
                    BTCAmount amount = BTCUnspecifiedPaymentAmount;
                    NSData* scriptData = nil;
                    // both amount and scriptData are optional, so we try to read any of them
                    while (offset2 < d.length) {
                        [BTCProtocolBuffers fieldAtOffset:&offset2 int:(uint64_t*)&amount data:&scriptData fromData:d];
                    }
                    if (scriptData) {
                        BTCScript* script = [[BTCScript alloc] initWithData:scriptData];
                        if (!script) {
                            NSLog(@"CoreBitcoin ERROR: Received invalid script data in Payment Request Details: %@", scriptData);
                            return nil;
                        }
                        BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] initWithValue:amount script:script];
                        [outputs addObject:txout];
                    }
                    break;
                }
                case BTCDetailsKeyTime:
                    if (integer) _date = [NSDate dateWithTimeIntervalSince1970:integer];
                    break;
                case BTCDetailsKeyExpires:
                    if (integer) _expirationDate = [NSDate dateWithTimeIntervalSince1970:integer];
                    break;
                case BTCDetailsKeyMemo:
                    if (d) _memo = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                    break;
                case BTCDetailsKeyPaymentURL:
                    if (d) _paymentURL = [NSURL URLWithString:[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]];
                    break;
                case BTCDetailsKeyMerchantData:
                    if (d) _merchantData = d;
                    break;
                default: break;
            }
        }

        // PR must have at least one output
        if (outputs.count == 0) return nil;

        // PR requires a creation time.
        if (!_date) return nil;
        
        _outputs = outputs;
    }
    return self;
}

- (BTCNetwork*) network {
    return _network ?: [BTCNetwork mainnet];
}

- (NSData*) data {
    if (!_data) {
        NSMutableData* dst = [NSMutableData data];

        // Note: we should reconstruct the data exactly as it was on the input.

        if (_network) {
            [BTCProtocolBuffers writeString:_network.paymentProtocolName withKey:BTCDetailsKeyNetwork toData:dst];
        }

        for (BTCTransactionOutput* txout in _outputs) {
            NSMutableData* outputData = [NSMutableData data];

            if (txout.value != BTCUnspecifiedPaymentAmount) {
                [BTCProtocolBuffers writeInt:txout.value withKey:BTCOutputKeyAmount toData:outputData];
            }
            [BTCProtocolBuffers writeData:txout.script.data withKey:BTCOutputKeyScript toData:outputData];
            [BTCProtocolBuffers writeData:outputData withKey:BTCDetailsKeyOutputs toData:dst];
        }

        if (_date) {
            [BTCProtocolBuffers writeInt:(uint64_t)[_date timeIntervalSince1970] withKey:BTCDetailsKeyTime toData:dst];
        }
        if (_expirationDate) {
            [BTCProtocolBuffers writeInt:(uint64_t)[_expirationDate timeIntervalSince1970] withKey:BTCDetailsKeyExpires toData:dst];
        }
        if (_memo) {
            [BTCProtocolBuffers writeString:_memo withKey:BTCDetailsKeyMemo toData:dst];
        }
        if (_paymentURL) {
            [BTCProtocolBuffers writeString:_paymentURL.absoluteString withKey:BTCDetailsKeyPaymentURL toData:dst];
        }
        if (_merchantData) {
            [BTCProtocolBuffers writeData:_merchantData withKey:BTCDetailsKeyMerchantData toData:dst];
        }
        _data = dst;
    }
    return _data;
}

@end




















@implementation BTCPayment

- (id) initWithData:(NSData*)data {
    if (!data) return nil;

    if (self = [super init]) {

        NSInteger offset = 0;
        NSMutableArray* txs = [NSMutableArray array];
        NSMutableArray* outputs = [NSMutableArray array];

        while (offset < data.length) {
            uint64_t integer = 0;
            NSData* d = nil;
            BTCTransaction* tx = nil;

            switch ([BTCProtocolBuffers fieldAtOffset:&offset int:&integer data:&d fromData:data]) {
                case BTCPaymentKeyMerchantData:
                    if (d) _merchantData = d;
                    break;
                case BTCPaymentKeyTransactions:
                    if (d) tx = [[BTCTransaction alloc] initWithData:d];
                    if (tx) [txs addObject:tx];
                    break;
                case BTCPaymentKeyRefundTo: {
                    NSInteger offset2 = 0;
                    BTCAmount amount = BTCUnspecifiedPaymentAmount;
                    NSData* scriptData = nil;
                    // both amount and scriptData are optional, so we try to read any of them
                    while (offset2 < d.length) {
                        [BTCProtocolBuffers fieldAtOffset:&offset2 int:(uint64_t*)&amount data:&scriptData fromData:d];
                    }
                    if (scriptData) {
                        BTCScript* script = [[BTCScript alloc] initWithData:scriptData];
                        if (!script) {
                            NSLog(@"CoreBitcoin ERROR: Received invalid script data in Payment Request Details: %@", scriptData);
                            return nil;
                        }
                        BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] initWithValue:amount script:script];
                        [outputs addObject:txout];
                    }
                    break;
                }
                case BTCPaymentKeyMemo:
                    if (d) _memo = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                    break;
                default: break;
            }

        }
        
        _transactions = txs;
        _refundOutputs = outputs;
    }
    return self;
}

- (NSData*) data {

    if (!_data) {
        NSMutableData* dst = [NSMutableData data];

        if (_merchantData) {
            [BTCProtocolBuffers writeData:_merchantData withKey:BTCPaymentKeyMerchantData toData:dst];
        }

        for (BTCTransaction* tx in _transactions) {
            [BTCProtocolBuffers writeData:tx.data withKey:BTCPaymentKeyTransactions toData:dst];
        }

        for (BTCTransactionOutput* txout in _refundOutputs) {
            NSMutableData* outputData = [NSMutableData data];

            if (txout.value != BTCUnspecifiedPaymentAmount) {
                [BTCProtocolBuffers writeInt:txout.value withKey:BTCOutputKeyAmount toData:outputData];
            }
            [BTCProtocolBuffers writeData:txout.script.data withKey:BTCOutputKeyScript toData:outputData];
            [BTCProtocolBuffers writeData:outputData withKey:BTCPaymentKeyRefundTo toData:dst];
        }

        if (_memo) {
            [BTCProtocolBuffers writeString:_memo withKey:BTCPaymentKeyMemo toData:dst];
        }

        _data = dst;
    }
    return _data;
}

@end






















@implementation BTCPaymentACK

- (id) initWithData:(NSData*)data {
    if (!data) return nil;

    if (self = [super init]) {
        NSInteger offset = 0;
        while (offset < data.length) {
            uint64_t integer = 0;
            NSData* d = nil;

            switch ([BTCProtocolBuffers fieldAtOffset:&offset int:&integer data:&d fromData:data]) {
                case BTCPaymentAckKeyPayment:
                    if (d) _payment = [[BTCPayment alloc] initWithData:d];
                    break;
                case BTCPaymentAckKeyMemo:
                    if (d) _memo = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                    break;
                default: break;
            }
        }

        // payment object is required.
        if (! _payment) return nil;
    }
    return self;
}


- (NSData*) data {

    if (!_data) {
        NSMutableData* dst = [NSMutableData data];

        [BTCProtocolBuffers writeData:_payment.data withKey:BTCPaymentAckKeyPayment toData:dst];

        if (_memo) {
            [BTCProtocolBuffers writeString:_memo withKey:BTCPaymentAckKeyMemo toData:dst];
        }

        _data = dst;
    }
    return _data;
}


@end
