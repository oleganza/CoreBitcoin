//
//  BTCBitcoinURL+Tests.m
//  CoreBitcoin
//
//  Created by Oleg Andreev on 02.04.2015.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

#import "BTCBitcoinURL+Tests.h"
#import "BTCAddress.h"

@implementation BTCBitcoinURL (Tests)

+ (void) runAllTests {

    [self testSimpleURL];
    [self testCompatiblePaymentRequest];
    [self testNakedPaymentRequest];
    [self testInvalidURL];
    [self testMalformedURL];
}

+ (void) testSimpleURL {
    BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&label=Hello%20world"]];
    NSAssert(burl, @"Must parse");
    NSAssert(burl.isValid == YES, @"Must be valid");
    NSAssert(burl.amount == 123450009, @"Must parse amount formatted as btc");
    NSAssert([burl.address.string isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Must parse address");
    NSAssert(burl.paymentRequestURL == nil, @"Must parse payment request");
    NSAssert([burl.label isEqualToString:@"Hello world"], @"Must parse label");
    NSAssert([burl.queryParameters[@"label"] isEqualToString:@"Hello world"], @"Must provide raw query items access");
    NSAssert([burl.queryParameters[@"amount"] isEqualToString:@"1.23450009"], @"Must provide raw query items access");
    NSAssert([burl[@"label"] isEqualToString:@"Hello world"], @"Must provide raw query items access");
    NSAssert([burl[@"amount"] isEqualToString:@"1.23450009"], @"Must provide raw query items access");
}

+ (void) testCompatiblePaymentRequest {
    BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&r=http://example.com/order-1000123"]];
    NSAssert(burl, @"Must parse");
    NSAssert(burl.isValid == YES, @"Must be valid");
    NSAssert(burl.amount == 123450009, @"Must parse amount formatted as btc");
    NSAssert([burl.address.string isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Must parse address");
    NSAssert([burl.paymentRequestURL.absoluteString isEqual:@"http://example.com/order-1000123"], @"Must parse payment request");
}

+ (void) testNakedPaymentRequest {
    BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:?r=http://example.com/order-1000123"]];
    NSAssert(burl, @"Must parse");
    NSAssert(burl.isValid == YES, @"Must be valid");
    NSAssert(burl.amount == 0, @"Default amount is zero");
    NSAssert(burl.address == nil, @"Default address is nil");
    NSAssert([burl.paymentRequestURL.absoluteString isEqual:@"http://example.com/order-1000123"], @"Must parse payment request");
}

+ (void) testInvalidURL {
    {
    BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:?x=something"]];
    NSAssert(burl, @"Must parse");
    NSAssert(burl.isValid == NO, @"Must not be valid");
    NSAssert(burl.amount == 0, @"Default amount is zero");
    NSAssert(burl.address == nil, @"Default address is nil");
    NSAssert(burl.paymentRequestURL == nil, @"Must have nil payment request");
    NSAssert([burl[@"x"] isEqual: @"something"], @"Must have query item");
    }

    {
    BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:?amount=1.2"]];
    NSAssert(burl, @"Must parse");
    NSAssert(burl.isValid == NO, @"Must not be valid");
    NSAssert(burl.amount == 120000000, @"Must parse amount");
    NSAssert(burl.address == nil, @"Default address is nil");
    NSAssert(burl.paymentRequestURL == nil, @"Must have nil payment request");
    NSAssert([burl[@"amount"] isEqual: @"1.2"], @"Must have query item");
    }
}

+ (void) testMalformedURL {
    {
        BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"bitcoin:xxxx"]];
        NSAssert(!burl, @"Must not parse broken address");
    }
    {
        BTCBitcoinURL* burl = [[BTCBitcoinURL alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]];
        NSAssert(!burl, @"Must not parse other schemas than bitcoin:");
    }
}
@end
