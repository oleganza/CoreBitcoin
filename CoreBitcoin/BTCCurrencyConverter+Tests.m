//
//  BTCCurrencyConverter+Tests.m
//  CoreBitcoin
//
//  Created by Andrew Ogden on 5/4/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

#import "BTCCurrencyConverter+Tests.h"


@implementation BTCCurrencyConverter (Tests)

+ (void) runAllTests {
    [self testRateUpdates];
    [self testAsksAndBids];
    [self testFiatConversions];
}

+ (void) testRateUpdates {
    BTCCurrencyConverter* converter = [[BTCCurrencyConverter alloc] init];
    [converter setBuyRate:[NSDecimalNumber decimalNumberWithString:@"210.0"]];
    [converter setSellRate:[NSDecimalNumber decimalNumberWithString:@"200.0"]];
    
    NSAssert(converter.averageRate.doubleValue == 205.0, @"Average should be from buy and sell rates");
    
    [converter setAverageRate:[NSDecimalNumber decimalNumberWithString:@"300.0"]];
    
    NSAssert(converter.sellRate.doubleValue == 300.0, @"Setting average should reassign sell rate");
    NSAssert(converter.buyRate.doubleValue == 300.0, @"Setting average should reassign buy rate");
}

+ (void) testAsksAndBids {
    BTCCurrencyConverter* converter = [[BTCCurrencyConverter alloc] init];
    [converter setBuyRate:[NSDecimalNumber decimalNumberWithString:@"210.0"]];
    [converter setSellRate:[NSDecimalNumber decimalNumberWithString:@"200.0"]];
    
    NSArray* asks = @[@[[NSNumber numberWithDouble:209.0],[NSNumber numberWithDouble:1.0]]];
    
    [converter setAsks:asks];
    NSAssert(converter.asks,@"Should be valid ask array");
//    NSAssert([converter.buyRate isEqualTo:[NSDecimalNumber decimalNumberWithString:@"209.0"]], @"Buy rate should equal minimum of asks array");
    
    NSArray* bids = @[@[[NSNumber numberWithDouble:201.0],[NSNumber numberWithDouble:1.0]]];
    
    [converter setBids:bids];
    NSAssert(converter.bids,@"Should be valid bids array");
//    NSAssert([converter.sellRate isEqualTo:[NSDecimalNumber decimalNumberWithString:@"201.0"]], @"Sell rate should equal maximum of bids array");
}

+ (void) testFiatConversions {
    BTCCurrencyConverter* converter = [[BTCCurrencyConverter alloc] init];
    [converter setBuyRate:[NSDecimalNumber decimalNumberWithString:@"205.0"]];
    [converter setSellRate:[NSDecimalNumber decimalNumberWithString:@"195.0"]];
    
    converter.mode = BTCCurrencyConverterModeAverage;
    BTCAmount averageBTCAmout = [converter bitcoinFromFiat:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
    
    NSAssert(averageBTCAmout == 5000000, @"10.0 fiat with average BTC price of 200 should buy 5 million satoshis");
    
    converter.mode = BTCCurrencyConverterModeBuy;
    BTCAmount buyBTCAmount = [converter bitcoinFromFiat:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
    
    NSAssert(buyBTCAmount == 4878049, @"10.0 fiat with buy rate of 205 should buy 4878049 satoshis");
    
    converter.mode = BTCCurrencyConverterModeSell;
    BTCAmount sellBTCAmount = [converter bitcoinFromFiat:[NSDecimalNumber decimalNumberWithString:@"10.0"]];
    
    NSAssert(sellBTCAmount == 5128205, @"10.0 fiat with sell rate of 195 should convert to 5128205 satoshis");
}


@end