// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.
// Implementation of blind signatures for Bitcoin transactions:
// http://oleganza.com/blind-ecdsa-draft-v2.pdf

#import "BTCBlindSignature+Tests.h"

#import "BTCKey.h"
#import "BTCKeychain.h"
#import "BTCData.h"
#import "BTCBigNumber.h"
#import "BTCCurvePoint.h"


@implementation BTCBlindSignature (Tests)

+ (void) runAllTests
{
    [self testCoreAlgorithm];
    [self testConvenienceAPI];
}

+ (void) testCoreAlgorithm
{
    BTCBlindSignature* api = [[BTCBlindSignature alloc] init];
    
    BTCBigNumber* a = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"a" dataUsingEncoding:NSUTF8StringEncoding])];
    BTCBigNumber* b = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"b" dataUsingEncoding:NSUTF8StringEncoding])];
    BTCBigNumber* c = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"c" dataUsingEncoding:NSUTF8StringEncoding])];
    BTCBigNumber* d = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"d" dataUsingEncoding:NSUTF8StringEncoding])];
    BTCBigNumber* p = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"p" dataUsingEncoding:NSUTF8StringEncoding])];
    BTCBigNumber* q = [[BTCBigNumber alloc] initWithUnsignedData:BTCHash256([@"q" dataUsingEncoding:NSUTF8StringEncoding])];
    
    NSArray* PQ = [api bob_P_and_Q_for_p:p q:q];
    BTCCurvePoint* P = PQ.firstObject;
    BTCCurvePoint* Q = PQ.lastObject;

    NSAssert(P, @"sanity check");
    NSAssert(Q, @"sanity check");

    NSArray* KT = [api alice_K_and_T_for_a:a b:b c:c d:d P:P Q:Q];
    BTCCurvePoint* K = KT.firstObject;
    BTCCurvePoint* T = KT.lastObject;
    
    NSAssert(K, @"sanity check");
    NSAssert(T, @"sanity check");
    
    // In real life we'd use T in a destination script and keep K.x around for redeeming it later.
    // ...
    // It's time to redeem funds! Lets do it by asking Bob to sign stuff for Alice.
    
    NSData* hash = BTCHash256([@"some transaction" dataUsingEncoding:NSUTF8StringEncoding]);
    
    // Alice computes and sends to Bob.
    BTCBigNumber* blindedHash = [api aliceBlindedHashForHash:[[BTCBigNumber alloc] initWithUnsignedData:hash] a:a b:b];
    
    NSAssert(blindedHash, @"sanity check");
    
    // Bob computes and sends to Alice.
    BTCBigNumber* blindedSig = [api bobBlindedSignatureForHash:blindedHash p:p q:q];
    
    NSAssert(blindedSig, @"sanity check");
    
    // Alice unblinds and uses in the final signature.
    BTCBigNumber* unblindedSignature = [api aliceUnblindedSignatureForSignature:blindedSig c:c d:d];
    
    NSAssert(unblindedSignature, @"sanity check");
    
    NSData* finalSignature = [api aliceCompleteSignatureForKx:K.x unblindedSignature:unblindedSignature];
    
    NSAssert(finalSignature, @"sanity check");
    
    BTCKey* pubkey = [[BTCKey alloc] initWithCurvePoint:T];
    
    NSAssert([pubkey isValidSignature:finalSignature hash:hash], @"should have created a valid signature after all that trouble");
}



+ (void) testConvenienceAPI
{
    BTCKeychain* aliceKeychain = [[BTCKeychain alloc] initWithSeed:[@"Alice" dataUsingEncoding:NSUTF8StringEncoding]];
    BTCKeychain* bobKeychain = [[BTCKeychain alloc] initWithSeed:[@"Bob" dataUsingEncoding:NSUTF8StringEncoding]];
    BTCKeychain* bobPublicKeychain = [[BTCKeychain alloc] initWithExtendedKey:bobKeychain.extendedPublicKey];

    NSAssert(aliceKeychain, @"sanity check");
    NSAssert(bobKeychain, @"sanity check");
    NSAssert(bobPublicKeychain, @"sanity check");

    BTCBlindSignature* alice = [[BTCBlindSignature alloc] initWithClientKeychain:aliceKeychain custodianKeychain:bobPublicKeychain];
    BTCBlindSignature* bob = [[BTCBlindSignature alloc] initWithCustodianKeychain:bobKeychain];
    
    NSAssert(alice, @"sanity check");
    NSAssert(bob, @"sanity check");
    
    for (uint32_t i = 0; i < 32; i++)
    {
        // This will be Alice's pubkey that she can use in a destination script.
        BTCKey* pubkey = [alice publicKeyAtIndex:i];
        NSAssert(pubkey, @"sanity check");
        
        //NSLog(@"pubkey = %@", pubkey);
        
        // This will be a hash of Alice's transaction.
        NSData* hash = BTCHash256([[NSString stringWithFormat:@"transaction %ul", i] dataUsingEncoding:NSUTF8StringEncoding]);
        
        //NSLog(@"hash = %@", hash);
        
        // Alice will send this to Bob.
        NSData* blindedHash = [alice blindedHashForHash:hash index:i];
        NSAssert(blindedHash, @"sanity check");
        
        // Bob computes the signature for Alice and sends it back to her.
        NSData* blindSig = [bob blindSignatureForBlindedHash:blindedHash];
        NSAssert(blindSig, @"sanity check");
        
        // Alice receives the blind signature and computes the complete ECDSA signature ready to use in a redeeming transaction.
        NSData* finalSig = [alice unblindedSignatureForBlindSignature:blindSig verifyHash:hash];
        NSAssert(finalSig, @"sanity check");
        
        NSAssert([pubkey isValidSignature:finalSig hash:hash], @"Check that the resulting signature is valid for our original hash and pubkey.");
    }
}


@end
