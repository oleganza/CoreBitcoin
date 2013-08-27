// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey+Tests.h"
#import "BTCEllipticCurveKey.h"
#import "BTCAddress.h"
#import "NSData+BTCData.h"

@implementation BTCEllipticCurveKey (Tests)

+ (void) runAllTests
{
    NSString* message = @"Test message";
    NSData* messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData* secret = BTCDataWithHexString(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a");
    
    NSAssert(secret.length == 32, @"secret must be 32 bytes long");
    BTCEllipticCurveKey* key = [[BTCEllipticCurveKey alloc] initWithSecretKey:secret];
    
    BTCAddress* pubkeyAddress = [BTCPublicKeyAddress addressWithData:[key.publicKey BTCHash160]];
    BTCAddress* privkeyAddress = [BTCPrivateKeyAddress addressWithData:key.secretKey];
    
    NSAssert([pubkeyAddress.base58String isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"");
    NSAssert([privkeyAddress.base58String isEqual:@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"], @"");
    
//    [key signatureForHash:<#(NSData *)#>]
}

@end
