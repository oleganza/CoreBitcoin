#import <Foundation/Foundation.h>

#import "BTCBigNumber+Tests.h"
#import "BTCData+Tests.h"
#import "BTCAddress+Tests.h"
#import "BTCProtocolSerialization+Tests.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        [NSData runAllTests];
        [BTCBigNumber runAllTests];
        [BTCAddress runAllTests];
        [BTCProtocolSerialization runAllTests];
        NSLog(@"All tests passed.");
    }
    return 0;
}

