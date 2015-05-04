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
#import "BTCBlindSignature+Tests.h"
#import "BTCEncryptedBackup+Tests.h"
#import "BTCEncryptedMessage+Tests.h"
#import "BTCFancyEncryptedMessage+Tests.h"
#import "BTCScript+Tests.h"
#import "BTCTransaction+Tests.h"
#import "BTCBlockchainInfo+Tests.h"
#import "BTCPriceSource+Tests.h"
#import "BTCMerkleTree+Tests.h"
#import "BTCBitcoinURL+Tests.h"
#import "BTCCurrencyConverter+Tests.h"

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
        [BTCBlindSignature runAllTests];
        [BTCEncryptedBackup runAllTests];
        [BTCEncryptedMessage runAllTests];
        [BTCFancyEncryptedMessage runAllTests];
        [BTCScript runAllTests];
        [BTCMerkleTree runAllTests];
        [BTCBlockchainInfo runAllTests];
        [BTCPriceSource runAllTests];
        [BTCBitcoinURL runAllTests];
        [BTCCurrencyConverter runAllTests];

        [BTCTransaction runAllTests]; // has some interactive features to ask for private key
        NSLog(@"All tests passed.");
    }
    return 0;
}

