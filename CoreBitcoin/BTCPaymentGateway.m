//
//  BTCPaymentGateway.m
//  CoreBitcoin
//
//  Created by Oleg Andreev on 02.08.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BTCPaymentGateway.h"
#import "BTCAddress.h"
#import "BTCKey.h"
#import "BTCKeychain.h"
#import "BTCData.h"
#import "BTCBlockchainInfo.h"
#import <objc/objc.h>


@interface BTCPaymentGateway ()
@property(nonatomic, readwrite) BTCKeychain* keychain;
@end

@implementation BTCPaymentGateway

- (id) initWithKeychain:(BTCKeychain*)keychain
{
    NSParameterAssert(!keychain.isPrivate);
    
    if (self = [super init])
    {
        self.keychain = keychain;
        self.currencyConverters = @[ /* TODO: supply default converters */ ];
        self.currencyRateMaxAge = 24*3600;
    }
    return self;
}

// Public key derived from keychain for this order identifier.
- (BTCKey*) keyForOrder:(uint32_t)orderID
{
    return [self.keychain keyAtIndex:orderID];
}

- (BTCAddress*) addressForOrder:(uint32_t)orderID
{
    return [self keyForOrder:orderID].compressedPublicKeyAddress; // compressed because all derived pubkeys in BIP32 are compressed.
}

// Attempts to convert currency with the matching converter.
// If converter fails, tries another one matching.
// Required parameters:
// amount => 1234  # Fixnum amount in smallest units for a :from currency (cents for USD, satoshis for BTC etc.)
// from   => "USD" # from which currency to convert
// to     => "BTC" # to which currency to convert (one of these *must* be "BTC" for now)
// Optional parameter maxAge means maximum age of the exchange rate to be used. Default is currencyRateMaxAge. If the fetched rate is older, 0 is returned.
// Returns value > 0 on success and 0 on failure (none of the converters worked, or exchange rate is not fresh enough, or no converter for your currency).
// Raises an exception if you supply unsupported conversion pair (e.g. from USD to EUR). Only to/from BTC conversions are supported.
- (int64_t)convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode error:(NSError**)errorOut
{
    return [self convertAmount:amount from:fromCurrencyCode to:toCurrencyCode maxAge:self.currencyRateMaxAge error:errorOut];
}

- (int64_t)convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode maxAge:(NSTimeInterval)maxAge error:(NSError**)errorOut
{
    NSParameterAssert(fromCurrencyCode != nil);
    NSParameterAssert(toCurrencyCode != nil);
    NSParameterAssert([fromCurrencyCode isEqualToString:@"BTC"] || [toCurrencyCode isEqualToString:@"BTC"]);
        
    if (amount == 0) return 0;
    
    NSString* foreignCurrency = [fromCurrencyCode isEqualToString:@"BTC"] ? toCurrencyCode : fromCurrencyCode;
    
    // If some wiseguy supplied BTC->BTC, that's okay - return the amount directly.
    if ([foreignCurrency isEqualToString:@"BTC"]) return amount;
    
    for (BTCPaymentGatewayCurrencyConverter* converter in self.currencyConverters)
    {
        if ([[converter supportedCurrencies] containsObject:foreignCurrency])
        {
            // TODO: try to use this one to convert the currency.
            
        }
    }
    
    return 0;
}

// Returns a dictionary with info about the order.
// Order without any visible transactions has 0 confirmations and no transactions.
// Order with a single, but unconfirmed transaction will have 0 confirmations and one transaction.
// Order with multiple transactions will have 'confirmations' number equal to
// the lowest confirmation number for oldest transactions containing target_amount.
// If targetAmount: is not specified, all transactions are counted for 'confirmations' number.
// targetAmount: and balance are denominated in satoshis.
// This is lower-level API for better insight into details of the order, debugging and testing.
// Example:
// {
//    "address": "1kS2b2aB4512f65He723qEeba1q2yoP2",
//    "pubkey": "03f5f79f0be8a8bfe7e79a2356abbb3193461be9162719aab5931f",
//    "confirmations": 0,
//    "balance": 0,
//    "transactions": [ {"txid": "feba9e7bfea...", "amount": 1202000, ...} ],
// }

- (NSDictionary*) statusForOrder:(uint32_t)orderID
{
    return [self statusForOrder:orderID targetAmount:0];
}

- (NSDictionary*) statusForOrder:(uint32_t)orderID targetAmount:(int64_t)targetAmount
{
    // TODO: finish this.
    return @{};
}

// Returns true/false depending on whether the amount to be paid is met by one or more transactions for this order.
// All transactions fulfilling the target amount must have at least <minConfirmations>. Default is 1.
// It is recommended to raise amount of confirmations based on amount and risk of fraud.
// For digital non-resellable purchases one may specify 0 for minConfirmations.
// This method internally uses statusForOrderID.
- (BOOL) isOrderPaid:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC
{
    return [self isOrderPaid:orderID targetAmount:targetAmountBTC minConfirmations:1];
}

- (BOOL) isOrderPaid:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC minConfirmations:(int)minConfirmations
{
    // TODO: finish this.
    return NO;
}

// Same as isOrderPaidForID?, but allows zero-confirmation transactions.
- (BOOL) isPaymentInitiated:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC
{
    return [self isOrderPaid:orderID targetAmount:targetAmountBTC minConfirmations:0];
}

@end





@implementation BTCPaymentGatewayCurrencyConverter

// Array of ISO identifiers of currencies supported by this provider. E.g. ["USD", "EUR"]
- (NSArray*) supportedCurrencies
{
    return @[];
}

- (NSDate*) rateUpdateDate
{
    return nil;
}

// Conversion method as in BTCPaymentGateway.
- (int64_t) convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode maxAge:(NSTimeInterval)maxAge error:(NSError**)errorOut
{
    return 0;
}

// Starts an asynchronous request to refresh the rate immediately.
// If completionBlock is provided, calls it upon completion.
- (void) refreshRate:(void(^)(BOOL, NSError*))completionBlock
{
    if (completionBlock) completionBlock(NO, nil);
}

@end
