// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// This is raw unencrypted EC key with methods to convert secret to a pubkey,
// sign messages and perform math operations on elliptic curve.
@interface BTCEllipticCurveKey : NSObject

// Newly generated random key pair.
- (id) init;

// Instantiates a key without a secret counterpart.
// You can use -isValidSignature:hash:
- (id) initWithPublicKey:(NSData*)publicKey;

// Instantiates a key with either a private key (279 bytes) or a secret (32 bytes).
// Usually secret parameter is used and private key is derived from it on the fly because other parameters are predefined.
- (id) initWithPrivateKey:(NSData*)privateKey;
- (id) initWithSecretKey:(NSData*)secretKey;

@property(nonatomic, readonly) NSData* publicKey;
@property(nonatomic, readonly) NSData* privateKey; // 279-byte private key with secret and all parameters.
@property(nonatomic, readonly) NSData* secretKey; // 32-byte secret parameter. That's all you need to get full key pair on secp256k1 curve.

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash;

// Returns a signature data for a 256-bit hash using private key.
// Returns nil if signing failed or private key is not present.
- (NSData*)signatureForHash:(NSData*)hash;

// Clears all key data from memory making receiver invalid.
- (void) clear;

@end
