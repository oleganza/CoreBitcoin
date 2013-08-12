// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// This is raw unencrypted EC key with methods to convert secret to a pubkey,
// sign messages and perform math operations on elliptic curve.
// Wallet stores encrypted keys with extra metadata using BTCWalletKey.
@interface BTCEllipticCurveKey : NSObject

// Newly generated key pair.
- (id) init;

// Instantiates a key without secret counterpart.
- (id) initWithPublicKey:(NSData*)publicKey;

- (id) initWithPrivateKey:(NSData*)privateKey;
- (id) initWithSecretKey:(NSData*)secretKey;

@property(nonatomic) NSData* publicKey;
@property(nonatomic) NSData* privateKey; // 279-byte private key with secret and all parameters.
@property(nonatomic) NSData* secretKey; // 32-byte secret parameter. That's all you need to get full key pair on secp256k1 curve.

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash;

// Returns a signature data for a 256-bit hash using private key.
- (NSData*)signatureForHash:(NSData*)hash;

// Clear all key data from memory making receiver invalid.
- (void) clear;

@end
