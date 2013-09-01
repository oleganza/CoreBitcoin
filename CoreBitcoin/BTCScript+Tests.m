// Oleg Andreev <oleganza@gmail.com>

#import "BTCScript+Tests.h"
#import "BTCData.h"

@implementation BTCScript (Tests)

+ (void) runAllTests
{
    [self testBinarySerialization];
    [self testStringSerialization];
    [self testStandardScripts];
}

+ (void) testBinarySerialization
{
    // Empty script
    {
        NSAssert([[[BTCScript alloc] init].data isEqual:[NSData data]], @"Default script should be empty.");
        NSAssert([[[BTCScript alloc] initWithData:[NSData data]].data isEqual:[NSData data]], @"Empty script should be empty.");
    }
    
    
}

+ (void) testStringSerialization
{
    
}

+ (void) testStandardScripts
{
    //
}

@end
