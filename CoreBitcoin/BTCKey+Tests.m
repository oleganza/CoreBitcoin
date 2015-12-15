// Oleg Andreev <oleganza@gmail.com>

#import "BTCKey+Tests.h"
#import "BTCKey.h"
#import "BTCAddress.h"
#import "NSData+BTCData.h"

@implementation BTCKey (Tests)

+ (void) runAllTests {
    [self testRFC6979];
    [self testDiffieHellman];
    [self testCanonicality];
    [self testRandomKeys];
    [self testBasicSigning];
    [self testECDSA];
    [self testBitcoinSignedMessage];
}

+ (void) testRFC6979 {

    void(^verifyRFC6979)(NSString*, id, NSString*, NSString*) = ^(NSString* keyhex, id msg, NSString* khex, NSString* sighex) {
        NSData* hash = [msg isKindOfClass:[NSString class]] ? BTCSHA256([msg dataUsingEncoding:NSUTF8StringEncoding]) : msg;
        BTCKey* key = [[BTCKey alloc] initWithPrivateKey:BTCDataFromHex(keyhex)];
        NSData* k = [key signatureNonceForHash:hash];
        NSAssert([BTCDataFromHex(khex) isEqual:k], @"Must produce matching k nonce.");
        NSData* sig = [key signatureForHash:hash];
        NSAssert([BTCDataFromHex(sighex) isEqual:sig], @"Must produce matching signature.");
    };

    verifyRFC6979(@"cca9fbcc1b41e5a95d369eaa6ddcff73b61a4efaa279cfc6567e8daa39cbaf50",
                  @"sample",
                  @"2df40ca70e639d89528a6b670d9d48d9165fdc0febc0974056bdce192b8e16a3",
                  @"3045022100af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b384202205009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124");
    verifyRFC6979(@"0000000000000000000000000000000000000000000000000000000000000001",
                  @"Satoshi Nakamoto",
                  @"8f8a276c19f4149656b280621e358cce24f5f52542772691ee69063b74f15d15",
                  @"3045022100934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d802202442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5");
    verifyRFC6979(@"fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140",
                  @"Satoshi Nakamoto",
                  @"33a19b60e25fb6f4435af53a3d42d493644827367e6453928554f43e49aa6f90",
                  @"3045022100fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d002206b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5");
    verifyRFC6979(@"f8b8af8ce3c7cca5e300d33939540c10d45ce001b8f252bfbc57ba0342904181",
                  @"Alan Turing",
                  @"525a82b70e67874398067543fd84c83d30c175fdc45fdeee082fe13b1d7cfdf1",
                  @"304402207063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c022058dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea");
    verifyRFC6979(@"0000000000000000000000000000000000000000000000000000000000000001",
                  @"All those moments will be lost in time, like tears in rain. Time to die...",
                  @"38aa22d72376b4dbc472e06c3ba403ee0a394da63fc58d88686c611aba98d6b3",
                  @"30450221008600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b0220547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21");
    verifyRFC6979(@"e91671c46231f833a6406ccbea0e3e392c76c167bac1cb013f6f1013980455c2",
                  @"There is a computer disease that anybody who works with computers knows about. It's a very serious disease and it interferes completely with the work. The trouble with computers is that you 'play' with them!",
                  @"1f4b84c23a86a221d233f2521be018d9318639d5b8bbd6374a8a59232d16ad3d",
                  @"3045022100b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b0220279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6");

    // Test from [btcd/btcec example](https://github.com/btcsuite/btcd/blob/master/btcec/example_test.go)
    verifyRFC6979(@"22a47fa09a223f2aa079edf85a7c2d4f8720ee63e502ee2869afab7de234b80c",
                  BTCHash256([@"test message" dataUsingEncoding:NSUTF8StringEncoding]),
                  @"c5186174691d589ad5fec3d34deac8a1a2b4156fd87a27ea8961dffe5d056ae9",
                  @"304402201008e236fa8cd0f25df4482dddbb622e8a8b26ef0ba731719458de3ccd93805b022032f8ebe514ba5f672466eba334639282616bb3c2f0ab09998037513d1f9e3d6d");
}

+ (void) testDiffieHellman {

    BTCKey* alice = [[BTCKey alloc] initWithPrivateKey:BTCDataFromHex(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")];
    alice.publicKeyCompressed = YES;

    BTCKey* bob = [[BTCKey alloc] initWithPrivateKey:BTCDataFromHex(@"2db963f0fe106f483d9afa73bd4e39a8ac4bbcb1fbec99d65bf59d85c8cb62ee")];
    bob.publicKeyCompressed = YES;

    BTCKey* dh1 = [alice diffieHellmanWithPrivateKey:bob];
    BTCKey* dh2 = [bob diffieHellmanWithPrivateKey:alice];

    NSAssert([dh1.publicKey isEqual:dh2.publicKey], @"");
    NSAssert([dh1.publicKey isEqual:BTCDataFromHex(@"03735932754bc16e10febe40ee0280906d29459d477442f1838dcf27de3b5d9699")], @"");
    NSAssert([dh2.publicKey isEqual:BTCDataFromHex(@"03735932754bc16e10febe40ee0280906d29459d477442f1838dcf27de3b5d9699")], @"");
}

+ (void) testCanonicality
{
    {
        NSData* data = BTCDataFromHex(@"304402207f5561ac3cfb05743cab6ca914f7eb93c489f276f10cdf4549e7f0b0ef4e85cd02200191c0c2fd10f10158973a0344fdaf2438390e083a509d2870bcf2b05445612b01");

        NSError* error = nil;
        if (![BTCKey isCanonicalSignatureWithHashType:data verifyLowerS:YES error:&error]) {
            NSLog(@"error: %@", error);
        }
    }

    {
        NSData* data = BTCDataFromHex(@"3045022100e81a33ac22d0ef25d359a5353977f0f953608b2733141239ec02363237ab6781022045c71237e95b56079e9fa88591060e4c1a4bb02c0cad1ebeb092749d4aa9754701");

        NSError* error = nil;
        if (![BTCKey isCanonicalSignatureWithHashType:data verifyLowerS:YES error:&error]) {
            NSLog(@"error: %@", error);
        }
    }

    {
        NSData* data = BTCDataFromHex(@"304402202692ad36ae12652c3f4bf068bd05477d867f654f2edf2cb15d335b25305d56b802206a4b51939b4b54fa62186e7bb78b4da8fe91475e5805897df11553dd1e08eb3e01");

        NSError* error = nil;
        if (![BTCKey isCanonicalSignatureWithHashType:data verifyLowerS:YES error:&error]) {
            NSLog(@"error: %@", error);
        }
    }

}

+ (void) testRandomKeys {
    NSMutableArray* arr = [NSMutableArray array];
    // just a sanity check, not a serious randomness
    for (int i = 0; i < 32; i++) {
        BTCKey* k = [[BTCKey alloc] init];
        //NSLog(@"key = %@", BTCHexFromData(k.privateKey));
        
        // Note: this test may fail, but very rarely.
        NSData* subkey = [k.privateKey subdataWithRange:NSMakeRange(0, 4)];
        NSAssert(![arr containsObject:subkey], @"Should not repeat");
        NSAssert(k.privateKey.length == 32, @"Should be 32 bytes");
        
        [arr addObject:subkey];
    }
}

+ (void) testECDSA {
    for (int n = 0; n < 1000; n++) {
        NSString* message = [NSString stringWithFormat:@"Test message %d", n];
        NSData* messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSData* messageHash = messageData.SHA256;
        
        NSData* secret = [[NSString stringWithFormat:@"Key %d", n] dataUsingEncoding:NSUTF8StringEncoding].SHA256;
        BTCKey* key = [[BTCKey alloc] initWithPrivateKey:secret];
        key.publicKeyCompressed = YES;
        
        NSData* signature = [key signatureForHash:messageHash];
        
        BTCKey* key2 = [[BTCKey alloc] initWithPublicKey:key.publicKey];
        NSAssert([key2 isValidSignature:signature hash:messageHash], @"Signature must be valid");
    }
}

+ (void) testBasicSigning {
    NSString* message = @"Test message";
    NSData* messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData* secret = BTCDataFromHex(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a");
    
    NSAssert(secret.length == 32, @"secret must be 32 bytes long");
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:secret];
    key.publicKeyCompressed = NO;
    
    //NSLog(@"key.publicKey = %@", key.publicKey);
    
    BTCAddress* pubkeyAddress = [BTCPublicKeyAddress addressWithData:[key.publicKey BTCHash160]];
    BTCAddress* privkeyAddress = [BTCPrivateKeyAddress addressWithData:key.privateKey];
    
    //NSLog(@"pubkeyAddress.base58String = %@", pubkeyAddress.base58String);
    
    NSAssert([pubkeyAddress.string isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"");
    NSAssert([privkeyAddress.string isEqual:@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"], @"");
    
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
    if (0) {
        NSData* digest = messageData.SHA256;
        NSMutableData* sig = [signature mutableCopy];
        unsigned char* buf = sig.mutableBytes;
        for (int i = 0; i < signature.length; i++) {
            for (int j = 0; j < 8; j++) {
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




+ (void) testBitcoinSignedMessage {
    NSString* message = @"Test message";
    NSData* secret = BTCDataFromHex(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a");
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
        NSData* signature = BTCDataFromHex(@"1B158259BD8EEB198BABBCC4308CDFB8E8068F0A712CAC634257933A072EA6DB7"
                                            "BEB3308F4C937D4F397A2A782BF12884045C27430719A2890F0127B4732D9CF0D");
        
        BTCKey* key = [BTCKey verifySignature:signature forMessage:@"Test message"];
        NSAssert([key isValidSignature:signature forMessage:@"Test message"], @"Should validate signature");
        NSAssert([key.uncompressedPublicKeyAddress.string isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Should be signed with 1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T");
    }
    
}



@end
