// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.
// Implementation of blind signatures for Bitcoin transactions:
// http://oleganza.com/blind-ecdsa-draft-v2.pdf

#import "BTCBlindSignature+Tests.h"

#import "BTCData.h"
#import "BTCBigNumber.h"
#import "BTCCurvePoint.h"
#import "BTCKey.h"


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
    
}

@end
