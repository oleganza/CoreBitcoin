// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCBlockchainInfo+Tests.h"
#import "BTCAddress.h"
#import "BTCTransactionOutput.h"

@implementation BTCBlockchainInfo (Tests)

+ (void) runAllTests {
    [self testUnspentOutputs];
}

+ (void) testUnspentOutputs {
    // our donations address with some outputs: 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG
    // some temp address without outputs: 1LKF45kfvHAaP7C4cF91pVb3bkAsmQ8nBr

    {
        NSError* error = nil;
        NSArray* outputs = [[[BTCBlockchainInfo alloc] init] unspentOutputsWithAddresses:@[ [BTCAddress addressWithString:@"1LKF45kfvHAaP7C4cF91pVb3bkAsmQ8nBr"] ] error:&error];
        
        NSAssert([outputs isEqual:@[]], @"should return an empty array");
        NSAssert(!error, @"should have no error");
    }

    
    {
        NSError* error = nil;
        NSArray* outputs = [[[BTCBlockchainInfo alloc] init] unspentOutputsWithAddresses:@[ [BTCAddress addressWithString:@"1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"] ] error:&error];
        
        NSAssert(outputs.count > 0, @"should return non-empty array");
        NSAssert([outputs.firstObject isKindOfClass:[BTCTransactionOutput class]], @"should contain BTCTransactionOutput objects");
        NSAssert(!error, @"should have no error");
    }
}

@end
