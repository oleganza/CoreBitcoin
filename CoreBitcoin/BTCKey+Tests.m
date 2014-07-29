// Oleg Andreev <oleganza@gmail.com>

#import "BTCKey+Tests.h"
#import "BTCKey.h"
#import "BTCAddress.h"
#import "NSData+BTCData.h"

@implementation BTCKey (Tests)

+ (void) runAllTests
{
    [self testRandomKeys];
    [self testBasicSigning];
    [self testBitcoinSignedMessage];
}

+ (void) testRandomKeys
{
    NSMutableArray* arr = [NSMutableArray array];
    // just a sanity check, not a serious randomness
    for (int i = 0; i < 32; i++)
    {
        BTCKey* k = [[BTCKey alloc] init];
        //NSLog(@"key = %@", BTCHexStringFromData(k.privateKey));
        
        // Note: this test may fail, but very rarely.
        NSData* subkey = [k.privateKey subdataWithRange:NSMakeRange(0, 4)];
        NSAssert(![arr containsObject:subkey], @"Should not repeat");
        NSAssert(k.privateKey.length == 32, @"Should be 32 bytes");
        
        [arr addObject:subkey];
    }
}

+ (void) testBasicSigning
{
    NSString* message = @"Test message";
    NSData* messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData* secret = BTCDataWithHexString(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a");
    
    NSAssert(secret.length == 32, @"secret must be 32 bytes long");
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:secret];
    
    BTCAddress* pubkeyAddress = [BTCPublicKeyAddress addressWithData:[key.publicKey BTCHash160]];
    BTCAddress* privkeyAddress = [BTCPrivateKeyAddress addressWithData:key.privateKey];
    
    NSAssert([pubkeyAddress.base58String isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"");
    NSAssert([privkeyAddress.base58String isEqual:@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"], @"");
    
    NSData* signature = [key signatureForHash:messageData.SHA256];
    //    NSLog(@"Signature: %@ (%d bytes)", [signature hexString], (int)signature.length);
    //    NSLog(@"Valid: %d", (int)[key isValidSignature:signature hash:messageData.SHA256]);
    
    NSAssert([key isValidSignature:signature hash:messageData.SHA256], @"Signature must be valid");
    
    // Re-instantiate the key.
    NSData* pubkey = [key.publicKey copy];
    BTCKey* key2 = [[BTCKey alloc] initWithPublicKey:pubkey];
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




+ (void) testBitcoinSignedMessage
{
    NSString* message = @"Test message";
    NSData* secret = BTCDataWithHexString(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a");
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:secret];
    key.publicKeyCompressed = NO;
    //key.publicKeyCompressed = YES;
    //NSLog(@"Pubkey 1: %@ (%d bytes)", key.publicKey, (int)key.publicKey.length);
    
    {
        NSData* signature = [key signatureForMessage:message];
        //NSLog(@"Signature: %@ (%d bytes)", [signature hexString], (int)signature.length);
        BTCKey* key2 = [BTCKey verifySignature:signature forMessage:message];
        //NSLog(@"Pubkey 2: %@ (%d bytes)", key2.publicKey, (int)key2.publicKey.length);
        //NSLog(@"Valid: %d", (int)[key isValidSignature:signature forMessage:message]);
        
        NSAssert([key2.publicKey isEqual:key.publicKey], @"Recovered pubkeys should match");
        NSAssert([key isValidSignature:signature forMessage:message], @"Signature must be valid");
    }
    
    {
        NSData* signature = BTCDataWithHexString(@"1B158259BD8EEB198BABBCC4308CDFB8E8068F0A712CAC634257933A072EA6DB7"
                                                  "BEB3308F4C937D4F397A2A782BF12884045C27430719A2890F0127B4732D9CF0D");
        
        BTCKey* key = [BTCKey verifySignature:signature forMessage:@"Test message"];
        NSAssert([key isValidSignature:signature forMessage:@"Test message"], @"Should validate signature");
        NSAssert([key.uncompressedPublicKeyAddress.base58String isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Should be signed with 1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T");
    }
    
}



@end
