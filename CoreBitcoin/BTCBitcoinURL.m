#import "BTCBitcoinURL.h"
#import "BTCAddress.h"
#import "BTCNumberFormatter.h"

@interface BTCBitcoinURL ()
@property NSMutableDictionary* mutableQueryParameters;
@end

@implementation BTCBitcoinURL

@synthesize amount = _amount;
@synthesize label = _label;
@synthesize message = _message;
@synthesize paymentRequestURL = _paymentRequestURL;
@synthesize queryParameters = _queryParameters;

+ (NSURL*) URLWithAddress:(BTCAddress*)address amount:(BTCAmount)amount label:(NSString*)label {
    BTCBitcoinURL* btcurl = [[self alloc] init];
    btcurl.address = address;
    btcurl.amount = amount;
    btcurl.label = label;
    return btcurl.URL;
}

- (id) init {
    if (self = [super init]) {
        self.mutableQueryParameters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) initWithURL:(NSURL*)url {
    if (!url) return nil;

    NSURLComponents* comps = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];

    if (!comps) return nil;

    if (![comps.scheme isEqual:@"bitcoin"]) return nil;

    // We allow empty address, but if it's not empty, it must be a valid address.
    BTCAddress* address = nil;
    if (comps.path.length > 0) {
        address = [BTCAddress addressWithBase58String:comps.path];
        if (!address) {
            return nil;
        }
    }

    if (self = [self init]) {
        self.address = address;
        for (NSURLQueryItem* item in comps.queryItems) {
            [self.mutableQueryParameters setObject:item.value forKey:item.name];
        }
    }
    return self;
}

- (BOOL) isValid {
    return self.address || self.paymentRequestURL;
}

- (NSURL*) URL
{
    NSMutableString* string = [NSMutableString stringWithFormat:@"bitcoin:%@", self.address ? self.address.string : @""];
    NSMutableArray* queryItems = [NSMutableArray array];

    if(self.queryParameters) {
        NSArray* keys = self.queryParameters.allKeys;
        for (NSString* key in keys) {
            NSString* encodedKey = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)key, NULL, CFSTR("&="),
                                                                                             kCFStringEncodingUTF8));
            NSString* encodedValue = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self.queryParameters objectForKey:key], NULL, CFSTR("&="),
                                                                                               kCFStringEncodingUTF8));
            [queryItems addObject:[NSString stringWithFormat:@"%@=%@",encodedKey,encodedValue]];
             
        }
    }

    if (queryItems.count > 0) {
        [string appendString:@"?"];
        [string appendString:[queryItems componentsJoinedByString:@"&"]];
    }

    return [NSURL URLWithString:string];
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    return self.mutableQueryParameters[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    self.mutableQueryParameters[key] = obj;
}

- (NSDictionary*) queryParameters {
    return self.mutableQueryParameters;
}

- (void) setQueryParameters:(NSDictionary *)queryParameters {
    self.mutableQueryParameters = [NSMutableDictionary dictionaryWithDictionary:queryParameters];
    //Reset cached standard query parameters
    _amount = 0;
    _paymentRequestURL = nil;
    _message = nil;
    _label = nil;
}

#pragma mark Standard query parameters

- (BTCAmount) amount {
    if(_amount == 0){
        NSString* amountString = self.mutableQueryParameters[@"amount"];
        if (amountString) _amount = [BTCBitcoinURL parseAmount:amountString];
    }
    return _amount;
}

- (void) setAmount:(BTCAmount)amount {
    _amount = amount;
    NSString* amountString = [BTCBitcoinURL formatAmount:amount];
    self.mutableQueryParameters[@"amount"] = amountString;
}

- (NSURL*) paymentRequestURL {
    if (!_paymentRequestURL) {
        NSString* r = self.mutableQueryParameters[@"r"];
        if (r) _paymentRequestURL = [NSURL URLWithString:r];
    }
    return _paymentRequestURL;
}

- (void) setPaymentRequestURL:(NSURL *)paymentRequestURL {
    _paymentRequestURL = paymentRequestURL;
    if(paymentRequestURL != nil) {
        self.mutableQueryParameters[@"r"] = paymentRequestURL.absoluteString;
    } else {
        [self.mutableQueryParameters removeObjectForKey:@"r"];
    }
}

- (NSString*) label {
    if(!_label) {
        _label = self.mutableQueryParameters[@"label"];
    }
    return _label;
}

- (void) setLabel:(NSString *)label {
    _label = label;
    if(label != nil) {
        self.mutableQueryParameters[@"label"] = label;
    } else {
        [self.mutableQueryParameters removeObjectForKey:@"label"];
    }
}

- (NSString*) message {
    if(!_message) {
        _message = self.mutableQueryParameters[@"message"];
    }
    return _message;
}

- (void) setMessage:(NSString *)message {
    _message = message;
    if(message != nil) {
        self.mutableQueryParameters[@"message"] = message;
    } else {
        [self.mutableQueryParameters removeObjectForKey:@"message"];
    }
}

#pragma mark

+ (NSString*) formatAmount:(BTCAmount)amount {
    return [NSString stringWithFormat:@"%d.%08d", (int)(amount / BTCCoin), (int)(amount % BTCCoin)];
}

+ (BTCAmount) parseAmount:(NSString*)string {
    NSLocale* locale = [[NSLocale localeWithLocaleIdentifier:@"en_US"] copy]; // uses period (".") as a decimal point.
    NSAssert([[locale objectForKey:NSLocaleDecimalSeparator] isEqual:@"."], @"must be point as a decimal separator");
    NSDecimalNumber* dn = [NSDecimalNumber decimalNumberWithString:string locale:locale];
    // Fixes crash on URL like "bitcoin:1shaYanre36PBhspFL9zG7nt6tfDhxQ4u?amount=#" (https://twitter.com/sbetamc/status/581974120440700929)
    if ([dn isEqual:[NSDecimalNumber notANumber]]) {
        return 0;
    }
    if (BTCAmountFromDecimalNumber(dn) > 21000000) { // prevent overflow when multiplying by 8.
        return 0;
    }
    dn = [dn decimalNumberByMultiplyingByPowerOf10:8];
    return BTCAmountFromDecimalNumber(dn);
}

@end
