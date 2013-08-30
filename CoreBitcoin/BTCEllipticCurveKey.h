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

// Instantiates a key with either a DER private key (279 bytes) or a secret parameter (32 bytes).
// Usually only secret parameter is used and private key is derived from it on the fly because other parameters are known (curve secp256k1).
- (id) initWithPrivateKey:(NSData*)privateKey;
- (id) initWithDERPrivateKey:(NSData*)DERPrivateKey;

// These properties return mutable copy of data so you can clear it if needed.
@property(nonatomic, readonly) NSMutableData* publicKey;
@property(nonatomic, readonly) NSMutableData* privateKey; // 32-byte secret parameter. That's all you need to get full key pair on secp256k1
@property(nonatomic, readonly) NSMutableData* DERPrivateKey; // 279-byte private key with secret and all parameters.curve.

// Returns YES if the public key is compressed.
- (BOOL) isCompressedPublicKey;

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash;

// Returns a signature data for a 256-bit hash using private key.
// Returns nil if signing failed or private key is not present.
- (NSData*)signatureForHash:(NSData*)hash;

// Clears all key data from memory making receiver invalid.
- (void) clear;

@end


// Export and import keypair using Bitcoin address format.
@class BTCPublicKeyAddress;
@class BTCPrivateKeyAddress;
@interface BTCEllipticCurveKey (BTCAddress)

- (id) initWithPrivateKeyAddress:(BTCPrivateKeyAddress*)privateKeyAddress;

@property(nonatomic, readonly) BTCPublicKeyAddress* publicKeyAddress;
@property(nonatomic, readonly) BTCPrivateKeyAddress* privateKeyAddress;
@end

