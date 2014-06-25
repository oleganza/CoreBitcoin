#import <Foundation/Foundation.h>
@class BTCAddress;

// Collection of APIs for Chain.con
@interface BTCChain : NSObject

// Getting unspent outputs.

// Builds a request from a list of BTCAddress objects.
- (NSMutableURLRequest*) requestForUnspentOutputsWithAddress:(BTCAddress*)address;
// List of BTCTransactionOutput instances parsed from the response.
- (NSArray*) unspentOutputsForResponseData:(NSData*)responseData error:(NSError**)errorOut;
// Makes sync request for unspent outputs and parses the outputs.
- (NSArray*) unspentOutputsWithAddress:(BTCAddress*)addresses error:(NSError**)errorOut;

@end
