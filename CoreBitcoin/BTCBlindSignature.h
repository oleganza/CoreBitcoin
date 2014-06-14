// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.
// Implementation of blind signatures for Bitcoin transactions:
// http://oleganza.com/blind-ecdsa-draft-v2.pdf

#import <Foundation/Foundation.h>

@class BTCBigNumber;
@class BTCCurvePoint;
@interface BTCBlindSignature : NSObject

// Convenience API
// This is BIP32-based API to keep track of just a single private key for multiple signatures.

// ...


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
- (NSArray*) bob_P_and_Q_for_p:(BTCBigNumber*)p q:(BTCBigNumber*)q;

// 3. Alice computes K = (c·a)^-1·P and public key T = (a·Kx)^-1·(b·G + Q + d·c^-1·P).
//    Bob cannot know if his parameters were involved in K or T without the knowledge of a, b, c and d.
- (NSArray*) alice_K_and_T_for_a:(BTCBigNumber*)a b:(BTCBigNumber*)b c:(BTCBigNumber*)c d:(BTCBigNumber*)d P:(BTCCurvePoint*)P Q:(BTCCurvePoint*)Q;

// 5. Alice blinds the hash and sends h2 = a·h + b (mod n) to Bob.
- (BTCBigNumber*) aliceBlindedHashForHash:(BTCBigNumber*)hash a:(BTCBigNumber*)a b:(BTCBigNumber*)b;

// 7. Bob signs the blinded hash and returns the signature to Alice: s1 = p·h2 + q (mod n).
- (BTCBigNumber*) bobBlindedSignatureForHash:(BTCBigNumber*)hash p:(BTCBigNumber*)p q:(BTCBigNumber*)q;

// 8. Alice unblinds the signature: s2 = c·s1 + d (mod n).
- (BTCBigNumber*) aliceUnblindedSignatureForSignature:(BTCBigNumber*)blindSignature c:(BTCBigNumber*)c d:(BTCBigNumber*)d;

// 9. Now Alice has (Kx, s2) which is a valid ECDSA signature of hash h verifiable by public key T.
// This returns final DER-encoded ECDSA signature ready to be used in a bitcoin transaction.
// Do not forget to add SIGHASH byte in the end when placing in a Bitcoin transaction.
- (NSData*) aliceCompleteSignatureForKx:(BTCBigNumber*)Kx unblindedSignature:(BTCBigNumber*)unblindedSignature;

@end
