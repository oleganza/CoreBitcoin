#import "BTCBitcoinURL.h"
#import "BTCAddress.h"
#import "BTCNumberFormatter.h"

@implementation BTCBitcoinURL

+ (NSURL*) URLWithAddress:(BTCAddress*)address amount:(BTCAmount)amount label:(NSString*)label
{
    if (!address || amount <= 0) return nil;

    NSString* amountString = [self formatAmount:amount];

    NSMutableString* s = [NSMutableString stringWithFormat:@"bitcoin:%@?amount=%@", address.base58String, amountString];

    if (label && label.length > 0)
    {
        [s appendFormat:@"&label=%@", [label stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    return [NSURL URLWithString:s];
}

/*!
 * Instantiates if URL is a valid bitcoin: URL.
 */
- (id) initWithURL:(NSURL*)url
{
    if (!url) return nil;

    NSURLComponents* comps = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];

    if (!comps) return nil;

    if (![comps.scheme isEqual:@"bitcoin"]) return nil;

    // We allow empty address, but if it's not empty, it must be a valid address.
    BTCAddress* address = nil;
    if (comps.path.length > 0)
    {
        address = [BTCAddress addressWithBase58String:comps.path];
        if (!address)
        {
            return nil;
        }
    }

    if (self = [super init])
    {
        self.address = address;
        for (NSURLQueryItem* item in comps.queryItems)
        {
            if ([item.name isEqual:@"amount"])
            {
                self.amount = [[self class] parseAmount:item.value];
            }
        }
    }
    return self;
}

- (NSURL*) URL
{
    return nil;
}

+ (NSString*) formatAmount:(BTCAmount)amount
{
    return [NSString stringWithFormat:@"%d.%08d", (int)(amount / BTCCoin), (int)(amount % BTCCoin)];
}

+ (BTCAmount) parseAmount:(NSString*)string
{
    NSLocale* locale = [[NSLocale localeWithLocaleIdentifier:@"en_US"] copy]; // uses period (".") as a decimal point.
    NSAssert([[locale objectForKey:NSLocaleDecimalSeparator] isEqual:@"."], @"must be point as a decimal separator");
    NSDecimalNumber* dn = [NSDecimalNumber decimalNumberWithString:string locale:locale];
    dn = [dn decimalNumberByMultiplyingByPowerOf10:8];
    return BTCAmountFromDecimalNumber(dn);
}

@end
