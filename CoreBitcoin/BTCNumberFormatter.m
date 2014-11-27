#import "BTCNumberFormatter.h"

#define NarrowNbsp @"\xE2\x80\xAF"
//#define PunctSpace @" "
//#define ThinSpace  @" "

NSString* const BTCNumberFormatterBitcoinCode    = @"XBT";

NSString* const BTCNumberFormatterSymbolBTC      = @"Ƀ" @"";
NSString* const BTCNumberFormatterSymbolMilliBTC = @"mɃ";
NSString* const BTCNumberFormatterSymbolBit      = @"ƀ";
NSString* const BTCNumberFormatterSymbolSatoshi  = @"ṡ";

BTCAmount BTCAmountFromDecimalNumber(NSNumber* num)
{
    if ([num isKindOfClass:[NSDecimalNumber class]])
    {
        NSDecimalNumber* dnum = (id)num;
        // Starting iOS 8.0.2, the longLongValue method returns 0 for some non rounded values.
        // Rounding the number looks like a work around.
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                          scale:0
                                                                                               raiseOnExactness:NO
                                                                                                raiseOnOverflow:YES
                                                                                               raiseOnUnderflow:NO
                                                                                            raiseOnDivideByZero:YES];
        num = [dnum decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    }
    BTCAmount sat = [num longLongValue];
    return sat;
}

@implementation BTCNumberFormatter

- (id) initWithBitcoinUnit:(BTCNumberFormatterUnit)unit
{
    return [self initWithBitcoinUnit:unit symbolStyle:BTCNumberFormatterSymbolStyleNone];
}

- (id) initWithBitcoinUnit:(BTCNumberFormatterUnit)unit symbolStyle:(BTCNumberFormatterSymbolStyle)symbolStyle
{
    if (self = [super init])
    {
        _bitcoinUnit = unit;
        _symbolStyle = symbolStyle;

        [self updateFormatterProperties];
    }
    return self;
}

- (void) setBitcoinUnit:(BTCNumberFormatterUnit)bitcoinUnit
{
    if (_bitcoinUnit == bitcoinUnit) return;
    _bitcoinUnit = bitcoinUnit;
    [self updateFormatterProperties];
}

- (void) setSymbolStyle:(BTCNumberFormatterSymbolStyle)suffixStyle
{
    if (_symbolStyle == suffixStyle) return;
    _symbolStyle = suffixStyle;
    [self updateFormatterProperties];
}

- (void) updateFormatterProperties
{
    // Reset formats so they are recomputed after we change properties.
    self.positiveFormat = nil;
    self.negativeFormat = nil;

    self.lenient = YES;
    self.generatesDecimalNumbers = YES;
    self.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyCode = @"XBT";
    self.groupingSize = 3;

    self.currencySymbol = [self bitcoinUnitSymbol] ?: @"";

    self.internationalCurrencySymbol = self.currencySymbol;

    // On iOS 8 we have to set these *after* setting the currency symbol.
    switch (_bitcoinUnit)
    {
        case BTCNumberFormatterUnitSatoshi:
            self.minimumFractionDigits = 0;
            self.maximumFractionDigits = 0;
            break;
        case BTCNumberFormatterUnitBit:
            self.minimumFractionDigits = 0;
            self.maximumFractionDigits = 2;
            break;
        case BTCNumberFormatterUnitMilliBTC:
            self.minimumFractionDigits = 2;
            self.maximumFractionDigits = 5;
            break;
        case BTCNumberFormatterUnitBTC:
            self.minimumFractionDigits = 2;
            self.maximumFractionDigits = 8;
            break;
        default:
            [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
    }

    switch (_symbolStyle)
    {
        case BTCNumberFormatterSymbolStyleNone:
            self.minimumFractionDigits = 0;
            self.positivePrefix = @"";
            self.positiveSuffix = @"";
            self.negativePrefix = @"–";
            self.negativeSuffix = @"";
            break;
        case BTCNumberFormatterSymbolStyleCode:
        case BTCNumberFormatterSymbolStyleLowercase:
            self.positivePrefix = @"";
            self.positiveSuffix = [NSString stringWithFormat:@" %@", self.currencySymbol]; // nobreaking space here.
            self.negativePrefix = @"-";
            self.negativeSuffix = self.positiveSuffix;
            break;

        case BTCNumberFormatterSymbolStyleSymbol:
            // Leave positioning of the currency symbol to locale (in English it'll be prefix, in French it'll be suffix).
            break;
    }
    self.maximum = @(BTC_MAX_MONEY/(int64_t)pow(10.0, self.maximumFractionDigits));

    // Fixup prefix symbol with a no-breaking space. When it's postfix, Foundation puts nobr space already.
    self.positiveFormat = [self.positiveFormat stringByReplacingOccurrencesOfString:@"¤" withString:@"¤" NarrowNbsp "#"];

    // Fixup negative format to have the same format as positive format and a minus sign in front of the first digit.
    self.negativeFormat = [self.positiveFormat stringByReplacingCharactersInRange:[self.positiveFormat rangeOfString:@"#"] withString:@"–#"];
}

- (NSString *) standaloneSymbol
{
    NSString* sym = [self bitcoinUnitSymbol];
    if (!sym)
    {
        sym = [self bitcoinUnitSymbolForStyle:BTCNumberFormatterSymbolStyleCode unit:_bitcoinUnit];
    }
    return sym;
}

- (NSString*) bitcoinUnitSymbol
{
    return [self bitcoinUnitSymbolForStyle:_symbolStyle unit:_bitcoinUnit];
}

- (NSString*) bitcoinUnitSymbolForStyle:(BTCNumberFormatterSymbolStyle)symbolStyle unit:(BTCNumberFormatterUnit)bitcoinUnit
{
    switch (symbolStyle)
    {
        case BTCNumberFormatterSymbolStyleNone:
            return nil;
        case BTCNumberFormatterSymbolStyleCode:
            switch (bitcoinUnit)
            {
                case BTCNumberFormatterUnitSatoshi:
                    return NSLocalizedStringFromTable(@"SAT", @"CoreBitcoin", @"");
                case BTCNumberFormatterUnitBit:
                    return NSLocalizedStringFromTable(@"Bits", @"CoreBitcoin", @"");
                case BTCNumberFormatterUnitMilliBTC:
                    return NSLocalizedStringFromTable(@"mBTC", @"CoreBitcoin", @"");
                case BTCNumberFormatterUnitBTC:
                    return NSLocalizedStringFromTable(@"BTC", @"CoreBitcoin", @"");
                default:
                    [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            }
        case BTCNumberFormatterSymbolStyleLowercase:
            switch (bitcoinUnit)
            {
                case BTCNumberFormatterUnitSatoshi:
                    return [NSLocalizedStringFromTable(@"SAT", @"CoreBitcoin", @"") lowercaseString];
                case BTCNumberFormatterUnitBit:
                    return [NSLocalizedStringFromTable(@"Bits", @"CoreBitcoin", @"") lowercaseString];
                case BTCNumberFormatterUnitMilliBTC:
                    return [NSLocalizedStringFromTable(@"mBTC", @"CoreBitcoin", @"") lowercaseString];
                case BTCNumberFormatterUnitBTC:
                    return [NSLocalizedStringFromTable(@"BTC", @"CoreBitcoin", @"") lowercaseString];
                default:
                    [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            }
        case BTCNumberFormatterSymbolStyleSymbol:
            switch (bitcoinUnit)
            {
                case BTCNumberFormatterUnitSatoshi:
                    return BTCNumberFormatterSymbolSatoshi;
                case BTCNumberFormatterUnitBit:
                    return BTCNumberFormatterSymbolBit;
                case BTCNumberFormatterUnitMilliBTC:
                    return BTCNumberFormatterSymbolMilliBTC;
                case BTCNumberFormatterUnitBTC:
                    return BTCNumberFormatterSymbolBTC;
                default:
                    [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            }
        default:
            [[NSException exceptionWithName:@"BTCNumberFormatter: not supported symbol style" reason:@"" userInfo:nil] raise];
    }
    return nil;
}

- (NSString *) placeholderText
{
    NSString* groupSeparator = self.currencyGroupingSeparator ?: @"";
    NSString* decimalPoint = self.currencyDecimalSeparator ?: @".";
    switch (_bitcoinUnit)
    {
        case BTCNumberFormatterUnitSatoshi:
            return [NSString stringWithFormat:@"000%@000%@000", groupSeparator, groupSeparator];
        case BTCNumberFormatterUnitBit:
            return [NSString stringWithFormat:@"0%@000%@000%@00", groupSeparator, groupSeparator, decimalPoint];
        case BTCNumberFormatterUnitMilliBTC:
            return [NSString stringWithFormat:@"0%@000%@00000", groupSeparator, decimalPoint];
        case BTCNumberFormatterUnitBTC:
            return [NSString stringWithFormat:@"0%@00000000", decimalPoint];
        default:
            [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            return nil;
    }
}

- (NSNumber*) numberFromSatoshis:(BTCAmount)satoshis
{
    switch (_bitcoinUnit)
    {
        case BTCNumberFormatterUnitSatoshi:
            return @(satoshis);
        case BTCNumberFormatterUnitBit:
            return [[NSDecimalNumber alloc] initWithMantissa:ABS(satoshis) exponent:-2 isNegative:satoshis < 0];
        case BTCNumberFormatterUnitMilliBTC:
            return [[NSDecimalNumber alloc] initWithMantissa:ABS(satoshis) exponent:-5 isNegative:satoshis < 0];
        case BTCNumberFormatterUnitBTC:
            return [[NSDecimalNumber alloc] initWithMantissa:ABS(satoshis) exponent:-8 isNegative:satoshis < 0];
        default:
            [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            return nil;
    }
}

- (BTCAmount) satoshisFromNumber:(NSNumber*)number
{
    switch (_bitcoinUnit)
    {
        case BTCNumberFormatterUnitSatoshi:
            return BTCAmountFromDecimalNumber(number);
        case BTCNumberFormatterUnitBit:
            return BTCAmountFromDecimalNumber([self number:number multipliedByPowerOf10:2]);
        case BTCNumberFormatterUnitMilliBTC:
            return BTCAmountFromDecimalNumber([self number:number multipliedByPowerOf10:5]);
        case BTCNumberFormatterUnitBTC:
            return BTCAmountFromDecimalNumber([self number:number multipliedByPowerOf10:8]);
        default:
            [[NSException exceptionWithName:@"BTCNumberFormatter: not supported bitcoin unit" reason:@"" userInfo:nil] raise];
            return 0;
    }
}

- (NSNumber*) number:(NSNumber*)num multipliedByPowerOf10:(int)power
{
    if (!num) return nil;

    NSDecimalNumber* dn = nil;
    if ([num isKindOfClass:[NSDecimalNumber class]])
    {
        dn = (id)num;
    }
    else
    {
        dn = [NSDecimalNumber decimalNumberWithDecimal:num.decimalValue];
    }

    return [dn decimalNumberByMultiplyingByPowerOf10:power];
}

- (NSString *) stringFromAmount:(BTCAmount)amount
{
    return [self stringFromNumber:[self numberFromSatoshis:amount]];
}

- (BTCAmount) amountFromString:(NSString *)string
{
    return [self satoshisFromNumber:[self numberFromString:string]];
}

- (id) copyWithZone:(NSZone *)zone
{
    return [[BTCNumberFormatter alloc] initWithBitcoinUnit:self.bitcoinUnit symbolStyle:self.symbolStyle];
}


@end
