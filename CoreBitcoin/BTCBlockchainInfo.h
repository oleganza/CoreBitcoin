#import <Foundation/Foundation.h>

// Collection of useful APIs for Blockchain.info
@interface BTCBlockchainInfo : NSObject

// Builds a request from a list of BTCAddress objects.
- (NSMutableURLRequest*) requestForUnspentOutputsWithAddresses:(NSArray*)addresses;

// List of BTCTransactionOutput instances parsed from the response.
- (NSArray*) unspentOutputsForResponseData:(NSData*)responseData error:(NSError**)errorOut;

@end

