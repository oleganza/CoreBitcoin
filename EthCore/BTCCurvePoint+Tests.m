// Oleg Andreev <oleganza@gmail.com>

#import "BTCData.h"
#import "BTCKey.h"
#import "BTCBigNumber.h"
#import "BTCCurvePoint+Tests.h"

@implementation BTCCurvePoint (Tests)

+ (void) runAllTests {
    [self testPublicKey];
    [self testDiffieHellman];
}

+ (void) testPublicKey {
    // Should be able to create public key N = n*G via BTCKey API as well as raw EC arithmetic using BTCCurvePoint.
    
    NSData* privateKeyData = BTCHash256([@"Private Key Seed" dataUsingEncoding:NSUTF8StringEncoding]);
    
    // 1. Make the pubkey using BTCKey API.
    
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKeyData];
    
    
    // 2. Make the pubkey using BTCCurvePoint API.
    
    BTCBigNumber* bn = [[BTCBigNumber alloc] initWithUnsignedBigEndian:privateKeyData];
    
    BTCCurvePoint* generator = [BTCCurvePoint generator];
    BTCCurvePoint* pubkeyPoint = [[generator copy] multiply:bn];
    BTCKey* keyFromPoint = [[BTCKey alloc] initWithCurvePoint:pubkeyPoint];
    
    // 2.1. Test serialization
    
    NSAssert([pubkeyPoint isEqual:[[BTCCurvePoint alloc] initWithData:pubkeyPoint.data]], @"test serialization");
    
    // 3. Compare the two pubkeys.
    
    NSAssert([keyFromPoint isEqual:key], @"pubkeys should be equal");
    NSAssert([key.curvePoint isEqual:pubkeyPoint], @"points should be equal");
}

+ (void) testDiffieHellman {
    // Alice: a, A=a*G. Bob: b, B=b*G.
    // Test shared secret: a*B = b*A = (a*b)*G.
    
    NSData* alicePrivateKeyData = BTCHash256([@"alice private key" dataUsingEncoding:NSUTF8StringEncoding]);
    NSData* bobPrivateKeyData = BTCHash256([@"bob private key" dataUsingEncoding:NSUTF8StringEncoding]);
    
//    NSLog(@"Alice privkey: %@", BTCHexFromData(alicePrivateKeyData));
//    NSLog(@"Bob privkey:   %@", BTCHexFromData(bobPrivateKeyData));
    
    BTCBigNumber* aliceNumber = [[BTCBigNumber alloc] initWithUnsignedBigEndian:alicePrivateKeyData];
    BTCBigNumber* bobNumber = [[BTCBigNumber alloc] initWithUnsignedBigEndian:bobPrivateKeyData];
    
//    NSLog(@"Alice number: %@", aliceNumber.hexString);
//    NSLog(@"Bob number:   %@", bobNumber.hexString);
    
    BTCKey* aliceKey = [[BTCKey alloc] initWithPrivateKey:alicePrivateKeyData];
    BTCKey* bobKey = [[BTCKey alloc] initWithPrivateKey:bobPrivateKeyData];
    
    NSAssert([aliceKey.privateKey isEqual:aliceNumber.unsignedBigEndian], @"");
    NSAssert([bobKey.privateKey isEqual:bobNumber.unsignedBigEndian], @"");
    
    BTCCurvePoint* aliceSharedSecret = [bobKey.curvePoint multiply:aliceNumber];
    BTCCurvePoint* bobSharedSecret   = [aliceKey.curvePoint multiply:bobNumber];
    
//    NSLog(@"(a*B).x = %@", aliceSharedSecret.x.decimalString);
//    NSLog(@"(b*A).x = %@", bobSharedSecret.x.decimalString);
    
    BTCBigNumber* sharedSecretNumber = [[aliceNumber mutableCopy] multiply:bobNumber mod:[BTCCurvePoint curveOrder]];
    BTCCurvePoint* sharedSecret = [[BTCCurvePoint generator] multiply:sharedSecretNumber];
    
    NSAssert([aliceSharedSecret isEqual:bobSharedSecret], @"Should have the same shared secret");
    NSAssert([aliceSharedSecret isEqual:sharedSecret], @"Multiplication of private keys should yield a private key for the shared point");
}


@end
