#import <Foundation/Foundation.h>

#import "BTC256+Tests.h"
#import "BTCData+Tests.h"
#import "BTCMnemonic+Tests.h"
#import "BTCBigNumber+Tests.h"
#import "BTCBase58+Tests.h"
#import "BTCAddress+Tests.h"
#import "BTCProtocolSerialization+Tests.h"
#import "BTCKey+Tests.h"
#import "BTCKeychain+Tests.h"
#import "BTCCurvePoint+Tests.h"
#import "BTCScript+Tests.h"
#import "BTCBlockchainInfo+Tests.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        BTC256RunAllTests();
        [NSData runAllTests];
        [BTCMnemonic runAllTests];
        [BTCBigNumber runAllTests];
        BTCBase58RunAllTests();
        [BTCAddress runAllTests];
        [BTCProtocolSerialization runAllTests];
        [BTCKey runAllTests];
        [BTCCurvePoint runAllTests];
        [BTCKeychain runAllTests];
        [BTCScript runAllTests];
        [BTCBlockchainInfo runAllTests];

        NSLog(@"All tests passed.");
    }
    return 0;
}

