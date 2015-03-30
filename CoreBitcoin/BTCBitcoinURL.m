#import "BTCBitcoinURL.h"
#import "BTCAddress.h"
#import "BTCNumberFormatter.h"

@implementation BTCBitcoinURL

+ (NSURL*) URLWithAddress:(BTCAddress*)address amount:(BTCAmount)amount label:(NSString*)label {
    BTCBitcoinURL* btcurl = [[self alloc] init];
    btcurl.address = address;
    btcurl.amount = amount;
    btcurl.label = label;
    return btcurl.URL;
}

- (id) init {
    if (self = [super init]) {
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

    if (self = [super init]) {
        self.address = address;
        for (NSURLQueryItem* item in comps.queryItems) {
            if ([item.name isEqual:@"amount"]) {
                self.amount = [[self class] parseAmount:item.value];
            }
            if ([item.name isEqual:@"label"]) {
                self.label = item.value;
            }
            if ([item.name isEqual:@"message"]) {
                self.message = item.value;
            }
            if ([item.name isEqual:@"r"]) {
                self.paymentRequestURL = [NSURL URLWithString:item.value];
            }
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

    if (self.amount > 0) {
        [queryItems addObject:[NSString stringWithFormat:@"amount=%@", [BTCBitcoinURL formatAmount:self.amount]]];
    }

    if (self.label.length > 0) {
        [queryItems addObject:[NSString stringWithFormat:@"label=%@",
                               CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.label, NULL, CFSTR("&="),
                                                                                kCFStringEncodingUTF8))]];
    }

    if (self.message.length > 0) {
        [queryItems addObject:[NSString stringWithFormat:@"message=%@",
                               CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.message, NULL, CFSTR("&="),
                                                                                kCFStringEncodingUTF8))]];
    }

    if (self.paymentRequestURL) {
        NSString* r = self.paymentRequestURL.absoluteString;
        [queryItems addObject:[NSString stringWithFormat:@"r=%@",
                               CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)r, NULL, CFSTR("&="),
                                                                                kCFStringEncodingUTF8))]];
    }

    if (queryItems.count > 0) {
        [string appendString:@"?"];
        [string appendString:[queryItems componentsJoinedByString:@"&"]];
    }

    return [NSURL URLWithString:string];
}

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
