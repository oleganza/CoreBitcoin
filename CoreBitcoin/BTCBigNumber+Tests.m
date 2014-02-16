// Oleg Andreev <oleganza@gmail.com>

#import "BTCBigNumber+Tests.h"
#import "BTCData.h"

@implementation BTCBigNumber (Tests)

+ (void) runAllTests
{
    NSAssert([[[BTCBigNumber alloc] init] isEqual:[BTCBigNumber zero]], @"default bignum should be zero");
    NSAssert(![[[BTCBigNumber alloc] init] isEqual:[BTCBigNumber one]], @"default bignum should not be one");
    NSAssert([@"0" isEqualToString:[[[BTCBigNumber alloc] init] stringInBase:10]], @"default bignum should be zero");
    NSAssert([[[BTCBigNumber alloc] initWithInt32:0] isEqual:[BTCBigNumber zero]], @"0 should be equal to itself");
    
    NSAssert([[BTCBigNumber one] isEqual:[BTCBigNumber one]], @"1 should be equal to itself");
    NSAssert([[BTCBigNumber one] isEqual:[[BTCBigNumber alloc] initWithUInt32:1]], @"1 should be equal to itself");
    
    NSAssert([[[BTCBigNumber one] stringInBase:16] isEqual:@"1"], @"1 should be correctly printed out");
    NSAssert([[[[BTCBigNumber alloc] initWithUInt32:1] stringInBase:16] isEqual:@"1"], @"1 should be correctly printed out");
    NSAssert([[[[BTCBigNumber alloc] initWithUInt32:0xdeadf00d] stringInBase:16] isEqual:@"deadf00d"], @"0xdeadf00d should be correctly printed out");
    
    NSAssert([[[[BTCBigNumber alloc] initWithUInt64:0xdeadf00ddeadf00d] stringInBase:16] isEqual:@"deadf00ddeadf00d"], @"0xdeadf00ddeadf00d should be correctly printed out");

    NSAssert([[[[BTCBigNumber alloc] initWithString:@"0b1010111" base:2] stringInBase:2] isEqual:@"1010111"], @"0b1010111 should be correctly parsed");
    NSAssert([[[[BTCBigNumber alloc] initWithString:@"0x12346789abcdef" base:16] stringInBase:16] isEqual:@"12346789abcdef"], @"0x12346789abcdef should be correctly parsed");
    
    {
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithUInt64:0xdeadf00ddeadbeef];
        NSData* data = bn.littleEndianData;
        BTCBigNumber* bn2 = [[BTCBigNumber alloc] initWithLittleEndianData:data];
        NSAssert([@"deadf00ddeadbeef" isEqualToString:bn2.hexString], @"converting to and from data should give the same result");
    }
    
    
    // Negative zero
    {
        BTCBigNumber* zeroBN = [BTCBigNumber zero];
        BTCBigNumber* negativeZeroBN = [[BTCBigNumber alloc] initWithLittleEndianData:BTCDataWithHexString(@"80")];
        BTCBigNumber* zeroWithEmptyDataBN = [[BTCBigNumber alloc] initWithLittleEndianData:[NSData data]];
        
        //NSLog(@"negativeZeroBN.data = %@", negativeZeroBN.data);
        
        NSAssert(zeroBN, @"must exist");
        NSAssert(negativeZeroBN, @"must exist");
        NSAssert(zeroWithEmptyDataBN, @"must exist");
        
        //NSLog(@"negative zero: %lld", [negativeZeroBN int64value]);
        
        NSAssert([[[zeroBN mutableCopy] add:[[BTCBigNumber alloc] initWithInt32:1]] isEqual:[BTCBigNumber one]], @"0 + 1 == 1");
        NSAssert([[[negativeZeroBN mutableCopy] add:[[BTCBigNumber alloc] initWithInt32:1]] isEqual:[BTCBigNumber one]], @"0 + 1 == 1");
        NSAssert([[[zeroWithEmptyDataBN mutableCopy] add:[[BTCBigNumber alloc] initWithInt32:1]] isEqual:[BTCBigNumber one]], @"0 + 1 == 1");
        
        // In BitcoinQT script.cpp, there is check (bn != bnZero).
        // It covers negative zero alright because "bn" is created in a way that discards the sign.
        NSAssert(![zeroBN isEqual:negativeZeroBN], @"zero should != negative zero");
    }
    
    // Experiments:

    return;
    {
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithUInt32:0xdeadf00dL];
        NSLog(@"bn = %@ (%@) 0x%@ b36:%@", bn, bn.decimalString, [bn stringInBase:16], [bn stringInBase:36]);
    }
    {
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithInt32:-16];
        NSLog(@"bn = %@ (%@) 0x%@ b36:%@", bn, bn.decimalString, [bn stringInBase:16], [bn stringInBase:36]);
    }
    
    {
        int base = 17;
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithString:@"123" base:base];
        NSLog(@"bn = %@", [bn stringInBase:base]);
    }
    {
        int base = 2;
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithString:@"0b123" base:base];
        NSLog(@"bn = %@", [bn stringInBase:base]);
    }

    {
        BTCBigNumber* bn = [[BTCBigNumber alloc] initWithUInt64:0xdeadf00ddeadbeef];
        NSData* data = bn.littleEndianData;
        BTCBigNumber* bn2 = [[BTCBigNumber alloc] initWithLittleEndianData:data];
        NSLog(@"bn = %@", [bn2 hexString]);
    }
}

@end
