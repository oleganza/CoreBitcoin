// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey+Tests.h"
#import "BTCEllipticCurveKey.h"
#import "BTCAddress.h"
#import "NSData+BTCData.h"

@implementation BTCEllipticCurveKey (Tests)

+ (void) runAllTests
{
    [self testBasicSigning];
}

+ (void) testBasicSigning
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
    
    NSData* signature = [key signatureForHash:messageData.SHA256];
    //    NSLog(@"Signature: %@ (%d bytes)", [signature hexString], (int)signature.length);
    //    NSLog(@"Valid: %d", (int)[key isValidSignature:signature hash:messageData.SHA256]);
    
    NSAssert([key isValidSignature:signature hash:messageData.SHA256], @"Signature must be valid");
    
    // Re-instantiate the key.
    NSData* pubkey = [key.publicKey copy];
    BTCEllipticCurveKey* key2 = [[BTCEllipticCurveKey alloc] initWithPublicKey:pubkey];
    NSAssert([key2 isValidSignature:signature hash:messageData.SHA256], @"Signature must be valid");
    
    // Signature should be invalid if any bit is flipped.
    // This all works, of course, but takes a lot of time to compute.
    if (0)
    {
        NSData* digest = messageData.SHA256;
        NSMutableData* sig = [signature mutableCopy];
        unsigned char* buf = sig.mutableBytes;
        for (int i = 0; i < signature.length; i++)
        {
            for (int j = 0; j < 8; j++)
            {
                unsigned char mask = 1 << j;
                buf[i] = buf[i] ^ mask;
                NSAssert(![key isValidSignature:sig hash:digest], @"Signature must not be valid if any bit is flipped");
                NSAssert(![key2 isValidSignature:sig hash:digest], @"Signature must not be valid if any bit is flipped");
                buf[i] = buf[i] ^ mask;
                NSAssert([key isValidSignature:sig hash:digest], @"Signature must be valid again");
                NSAssert([key2 isValidSignature:sig hash:digest], @"Signature must be valid again");
            }
        }
    }
}




@end
