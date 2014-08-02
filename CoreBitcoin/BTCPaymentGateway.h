//
//  BTCPaymentGateway.h
//  CoreBitcoin
//
//  Created by Oleg Andreev on 02.08.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTCKey;
@class BTCAddress;
@class BTCKeychain;
@interface BTCPaymentGateway : NSObject

// Keychain used to derive all addresses.
@property(nonatomic, readonly) BTCKeychain* keychain;

// List of currency converters to use (instances of BTCPaymentGatewayCurrencyConverter).
// Default is [BTCPaymentGatewayConverterBitstamp, BTCPaymentGatewayConverterPaymium, BTCPaymentGatewayConverterBTCChina]
@property(nonatomic) NSArray* currencyConverters;

// Default 'max age' value in seconds for convertCurrency method. If not overriden defaults to 24*3600.
@property(nonatomic) NSTimeInterval currencyRateMaxAge;


// Public keychain to derive addresses from. For your safety, exception is raised if private keychain is supplied.
- (id) initWithKeychain:(BTCKeychain*)keychain;

// Public key derived from keychain for this order identifier.
- (BTCKey*) keyForOrder:(uint32_t)orderID;

// Address derived from keychain for this order identifier.
- (BTCAddress*) addressForOrder:(uint32_t)orderID;


// Attempts to convert currency with the matching converter.
// If converter fails, tries another one matching.
// Required parameters:
// amount => 1234  # Fixnum amount in smallest units for a :from currency (cents for USD, satoshis for BTC etc.)
// from   => "USD" # from which currency to convert
// to     => "BTC" # to which currency to convert (one of these *must* be "BTC" for now)
// Optional parameter maxAge means maximum age of the exchange rate to be used. Default is currencyRateMaxAge. If the fetched rate is older, 0 is returned.
// Returns value > 0 on success and 0 on failure (none of the converters worked, or exchange rate is not fresh enough, or no converter for your currency).
// Raises an exception if you supply unsupported conversion pair (e.g. from USD to EUR). Only to/from BTC conversions are supported.

- (int64_t)convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode error:(NSError**)errorOut;
- (int64_t)convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode maxAge:(NSTimeInterval)maxAge error:(NSError**)errorOut;

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
//    "address": <BTCAddress>,
//    "pubkey":  <BTCKey>,
//    "confirmations": 0,
//    "balance": 0,
//    "transactions": [ {"txid": <NSData feba9e7bfea...>, "amount": 1202000, ...} ],
// }

- (NSDictionary*) statusForOrder:(uint32_t)orderID;
- (NSDictionary*) statusForOrder:(uint32_t)orderID targetAmount:(int64_t)targetAmount;

// Returns true/false depending on whether the amount to be paid is met by one or more transactions for this order.
// All transactions fulfilling the target amount must have at least <minConfirmations>. Default is 1.
// It is recommended to raise amount of confirmations based on amount and risk of fraud.
// For digital non-resellable purchases one may specify 0 for minConfirmations.
// This method internally uses statusForOrderID.
- (BOOL) isOrderPaid:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC;
- (BOOL) isOrderPaid:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC minConfirmations:(int)minConfirmations;

// Same as isOrderPaidForID?, but allows zero-confirmation transactions.
- (BOOL) isPaymentInitiated:(uint32_t)orderID targetAmount:(int64_t)targetAmountBTC;

@end

// This API is for subclasses only.
@interface BTCPaymentGatewayCurrencyConverter : NSObject

// Array of ISO identifiers of currencies supported by this provider. E.g. ["USD", "EUR"]
- (NSArray*) supportedCurrencies;

// Date when the rate was last updated.
- (NSDate*) rateUpdateDate;

// Conversion method as in BTCPaymentGateway.
- (int64_t) convertAmount:(int64_t)amount from:(NSString*)fromCurrencyCode to:(NSString*)toCurrencyCode maxAge:(NSTimeInterval)maxAge error:(NSError**)errorOut;

// Starts an asynchronous request to refresh the rate immediately.
// If completionBlock is provided, calls it upon completion.
- (void) refreshRate:(void(^)(BOOL, NSError*))completionBlock;

@end
