// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.
// Implementation of blind signatures for Bitcoin transactions:
// http://oleganza.com/blind-ecdsa-draft-v2.pdf

#import "BTCBlindSignature.h"
#import "BTCCurvePoint.h"
#import "BTCBigNumber.h"
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/bn.h>


@implementation BTCBlindSignature



// Core Algorithm
// Exposed as a public API for testing purposes. Use less verbose convenience API above for real usage.

// Alice wants Bob to sign her transactions blindly.
// Bob will provide Alice with blinded public keys and blinded signatures for each transaction.

// 1. Alice chooses random numbers a, b, c, d within [1, n – 1].
// 2. Bob chooses random numbers p, q within [1, n – 1]
//    and sends two EC points to Alice:
//    P = (p^-1·G) and Q = (q·p^-1·G).
// 3. Alice computes K = (c·a)^-1·P and public key T = (a·Kx)^-1·(b·G + Q + d·c^-1·P).
//    Bob cannot know if his parameters were involved in K or T without the knowledge of a, b, c and d.
//    Thus, Alice can safely publish T (e.g. in a Bitcoin transaction that locks funds with T).
// 4. When time comes to sign a message (e.g. redeeming funds locked in a Bitcoin transaction),
//    Alice computes the hash h of her message.
// 5. Alice blinds the hash and sends h2 = a·h + b (mod n) to Bob.
// 6. Bob verifies the identity of Alice via separate communications channel.
// 7. Bob signs the blinded hash and returns the signature to Alice: s1 = p·h2 + q (mod n).
// 8. Alice unblinds the signature: s2 = c·s1 + d (mod n).
// 9. Now Alice has (Kx, s2) which is a valid ECDSA signature of hash h verifiable by public key T.
//    If she uses it in a Bitcoin transaction, she will be able to redeem her locked funds without Bob knowing which transaction he just helped to sign.

// Step 2: P and Q from Bob as blinded "public keys". Both P and C are BTCCurvePoint instances.
- (NSArray*) bob_P_and_Q_for_p:(BTCBigNumber*)p q:(BTCBigNumber*)q
{
    if (!p || !q) return nil;
    
    BTCCurvePoint* P = nil;
    BTCCurvePoint* Q = nil;
    BTCBigNumber* invp = nil;
    
    invp = [[p mutableCopy] inverseMod:[BTCCurvePoint curveOrder]];
    
    P = [[BTCCurvePoint generator] multiply:invp];
    Q = [[P copy] multiply:q];
    
    NSAssert(P, @"P should be valid");
    NSAssert(Q, @"Q should be valid");
    
    [invp clear]; // clear sensitive data from temporary variable p^-1
    
    return @[P, Q];
}

// 3. Alice computes K = (c·a)^-1·P and public key T = (a·Kx)^-1·(b·G + Q + d·c^-1·P).
//    Bob cannot know if his parameters were involved in K or T without the knowledge of a, b, c and d.
- (NSArray*) alice_K_and_T_for_a:(BTCBigNumber*)a b:(BTCBigNumber*)b c:(BTCBigNumber*)c d:(BTCBigNumber*)d P:(BTCCurvePoint*)P Q:(BTCCurvePoint*)Q
{
    if (!a || !b || !c || !d || !P || !Q) return nil;
    
    // K = (c·a)^-1·P
    // K = (c^-1)·(a^-1)·P
    
    // T = (a·Kx)^-1·(b·G + Q + d·(c^-1)·P).
    // T = (a^-1)·(Kx^-1)·(b·G + Q + d·(c^-1)·P).
    
    // Temporary vars
    BTCBigNumber* curveOrder = [BTCCurvePoint curveOrder];
    BTCBigNumber* invc = nil;
    BTCBigNumber* inva = nil;
    BTCBigNumber* Kx = nil;
    BTCBigNumber* invKx = nil;
    
    // Results
    BTCCurvePoint* K = nil;
    BTCCurvePoint* T = nil;
    
    inva = [[a mutableCopy] inverseMod:curveOrder];
    invc = [[c mutableCopy] inverseMod:curveOrder];
    
    K = [[[P copy] multiply:inva] multiply:invc];
    
    NSAssert(K, @"K should be valid");
    
    Kx = K.x;
    
    invKx = [[Kx mutableCopy] inverseMod:curveOrder];
    
    T = [[[[[[[P copy] multiply:invc] multiply:d] add:Q] addGeneratorMultipliedBy:b] multiply:invKx] multiply:inva];
    
    NSAssert(T, @"T should be valid");
    
    // Clear temporary variables.
    [invc clear];
    [inva clear];
    [Kx clear];
    [invKx clear];
    
    return @[K, T];
}

// Helper for steps 5, 7, 8.
- (BTCBigNumber*) linearTransformOfNumber:(BTCBigNumber*)number multiply:(BTCBigNumber*)a add:(BTCBigNumber*)b
{
    if (!number || !a || !b) return nil;
    
    BTCBigNumber* curveOrder = [BTCCurvePoint curveOrder];
    BTCMutableBigNumber* result = [[[number mutableCopy] multiply:a mod:curveOrder] add:b mod:curveOrder];
    return result;
}

// 5. Alice blinds the hash and sends h2 = a·h + b (mod n) to Bob.
- (BTCBigNumber*) aliceBlindedHashForHash:(BTCBigNumber*)hash a:(BTCBigNumber*)a b:(BTCBigNumber*)b
{
    return [self linearTransformOfNumber:hash multiply:a add:b];
}

// 7. Bob signs the blinded hash and returns the signature to Alice: s1 = p·h2 + q (mod n).
- (BTCBigNumber*) bobBlindedSignatureForHash:(BTCBigNumber*)hash p:(BTCBigNumber*)p q:(BTCBigNumber*)q
{
    return [self linearTransformOfNumber:hash multiply:p add:q];
}

// 8. Alice unblinds the signature: s2 = c·s1 + d (mod n).
- (BTCBigNumber*) aliceUnblindedSignatureForSignature:(BTCBigNumber*)blindSignature c:(BTCBigNumber*)c d:(BTCBigNumber*)d
{
    return [self linearTransformOfNumber:blindSignature multiply:c add:d];
}

// DER signature:
// 3045022100d21bdec190e170c6a59a91e002d3a4f26d64afecce704249484d2eb24721358d0220303f16b06e03f0719cadb001ea55f6f2d4f96807291802c2f26c09eb19ca087401
// Segments:
// 0x30 - prefix
// 0x45 - remaining length (69 = 1 + 1 + 33 + 1 + 1 + 32)
// 0x02 - prefix
// 0x21 - r length (33)
// 0x00d21bdec190e170c6a59a91e002d3a4f26d64afecce704249484d2eb24721358d // prefixed by 0x00 because 0xd2 is > 0x7F but the number is unsigned.
// 0x02 - prefix
// 0x20 - s length (32)
// 0x303f16b06e03f0719cadb001ea55f6f2d4f96807291802c2f26c09eb19ca0874 // not prefixed by 0x00 because 0x30 is below 0x7F, so "sign bit" is 0.
// 0x01 - hash type
- (NSData*) aliceCompleteSignatureForKx:(BTCBigNumber*)Kx unblindedSignature:(BTCBigNumber*)unblindedSignature
{
    ECDSA_SIG sigValue;
    ECDSA_SIG *sig = &sigValue;
    
    BIGNUM r; BN_init(&r); BN_copy(&r, Kx.BIGNUM);
    BIGNUM s; BN_init(&s); BN_copy(&s, unblindedSignature.BIGNUM);
    
    sig->r = &r;
    sig->s = &s;
    
    // The remaining code is taken from BTCKey where we produce a canonical signature.
    
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    BIGNUM *order = BN_CTX_get(ctx);
    BIGNUM *halforder = BN_CTX_get(ctx);
    EC_GROUP_get_order(group, order, ctx);
    BN_rshift1(halforder, order);
    if (BN_cmp(sig->s, halforder) > 0)
    {
        // enforce low S values, by negating the value (modulo the order) if above order/2.
        BN_sub(sig->s, order, sig->s);
    }
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    EC_GROUP_free(group);
    
    unsigned int sigSize = 72; // typical size of a ECDSA signature (when both numbers are 33 bytes).
    
    NSMutableData* signature = [NSMutableData dataWithLength:sigSize + 16]; // Make sure it is big enough
    
    unsigned char *pos = (unsigned char *)signature.mutableBytes;
    sigSize = i2d_ECDSA_SIG(sig, &pos);

    // Do not free sig as its pointers belong to external parameters
    // ECDSA_SIG_free(sig);
    // Instead, clear individual bignums.
    BN_clear_free(&r);
    BN_clear_free(&s);
    
    // Shrink to fit actual size
    [signature setLength:sigSize];
    
    return signature;
}

@end
