// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCSignatureHashType.h"

@class BTCCurvePoint;
@class BTCPublicKeyAddress;
@class BTCPrivateKeyAddress;

// BTCKey encapsulates EC public and private keypair (or only public part) on curve secp256k1.
// You can sign data and verify signatures.
// When instantiated with a public key, only signature verification is possible.
// When instantiated with a private key, all operations are available.
@interface BTCKey : NSObject

// Newly generated random key pair.
- (id) init;

// Instantiates a key without a secret counterpart.
// You can use -isValidSignature:hash:
- (id) initWithPublicKey:(NSData*)publicKey;

// Initializes public key using a point on elliptic curve secp256k1.
- (id) initWithCurvePoint:(BTCCurvePoint*)curvePoint;

// Instantiates a key with either a DER private key (279 bytes) or a secret parameter (32 bytes).
// Usually only secret parameter is used and private key is derived from it on the fly because other parameters are known (curve secp256k1).
- (id) initWithPrivateKey:(NSData*)privateKey;
- (id) initWithDERPrivateKey:(NSData*)DERPrivateKey;

// These properties return mutable copy of data so you can clear it if needed.

// publicKey is compressed if -publicKeyCompressed is YES.
@property(nonatomic, readonly) NSMutableData* publicKey;

// These are returning explicitly compressed or uncompressed copies of the public key.
@property(nonatomic, readonly) NSMutableData* compressedPublicKey;
@property(nonatomic, readonly) NSMutableData* uncompressedPublicKey;
@property(nonatomic, readonly) NSMutableData* privateKey; // 32-byte secret parameter. That's all you need to get full key pair on secp256k1
@property(nonatomic, readonly) NSMutableData* DERPrivateKey; // 279-byte private key including secret and all curve parameters.

// When you set public key, this property reflects whether it is compressed or not.
// To set this property you must have private counterpart. Then, -publicKey will be compressed/uncompressed accordingly.
@property(nonatomic, getter=isPublicKeyCompressed) BOOL publicKeyCompressed;

// Returns public key as a point on secp256k1 curve.
@property(nonatomic, readonly) BTCCurvePoint* curvePoint;

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash;

// Returns a signature data for a 256-bit hash using private key.
// Returns nil if signing failed or a private key is not present.
- (NSData*)signatureForHash:(NSData*)hash;

// Same as above, but also appends a hash type byte to the signature.
- (NSData*)signatureForHash:(NSData*)hash withHashType:(BTCSignatureHashType)hashType;

// Clears all key data from memory making receiver invalid.
- (void) clear;




// BTCAddress Import/Export


// Instantiate with a private key in a form of address. Also takes care about compressing pubkey if needed.
- (id) initWithPrivateKeyAddress:(BTCPrivateKeyAddress*)privateKeyAddress;

// Public key hash. Refers to a compressed public key if was initialized with
// private key serialization marked with "private" flag. See -publicKeyCompressed property.
// This is deprecated because actual result depends on a separate flag (-publicKeyCompressed)
// forgetting about which may cause confusion and hard to trace bugs.
@property(nonatomic, readonly) BTCPublicKeyAddress* publicKeyAddress DEPRECATED_ATTRIBUTE;

// Returns address for a public key (Hash160(pubkey)).
@property(nonatomic, readonly) BTCPublicKeyAddress* uncompressedPublicKeyAddress;
@property(nonatomic, readonly) BTCPublicKeyAddress* compressedPublicKeyAddress;

// Private key encoded in sipa format (base58 with compression flag).
@property(nonatomic, readonly) BTCPrivateKeyAddress* privateKeyAddress;





// Compact Signature
// 65 byte signature, which allows reconstructing the used public key.

// Returns a compact signature for 256-bit hash. Aka "CKey::SignCompact" in BitcoinQT.
// Initially used for signing text messages (see BTCKey+BitcoinSignedMessage).
- (NSData*) compactSignatureForHash:(NSData*)data;

// Verifies digest against given compact signature. On success returns a public key.
+ (BTCKey*) verifyCompactSignature:(NSData*)compactSignature forHash:(NSData*)hash;

// Verifies signature of the hash with its public key.
- (BOOL) isValidCompactSignature:(NSData*)signature forHash:(NSData*)hash;





// Bitcoin Signed Message
// BitcoinQT-compatible textual message signing API



// Returns a signature for message prepended with "Bitcoin Signed Message:\n" line.
- (NSData*) signatureForMessage:(NSString*)message;
- (NSData*) signatureForBinaryMessage:(NSData*)data;

// Verifies message against given signature. On success returns a public key.
+ (BTCKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message;
+ (BTCKey*) verifySignature:(NSData*)signature forBinaryMessage:(NSData*)data;

// Verifies signature of the message with its public key.
- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message;
- (BOOL) isValidSignature:(NSData*)signature forBinaryMessage:(NSData*)data;


// Canonical checks

// Used by BitcoinQT within OP_CHECKSIG to not relay transactions with non-canonical signature or a public key.
// Normally, signatures and pubkeys are encoded in a canonical form and majority of the transactions are good.
// Unfortunately, sometimes OpenSSL segfaults on some garbage data in place of a signature or a pubkey.
// Read more on that here: https://bitcointalk.org/index.php?topic=8392.80

// Note: non-canonical pubkey could still be valid for EC internals of OpenSSL and thus accepted by Bitcoin nodes.
+ (BOOL) isCanonicalPublicKey:(NSData*)data error:(NSError**)errorOut;

// Checks if the script signature is canonical.
// The signature is assumed to include hash type byte (see BTCSignatureHashType).
+ (BOOL) isCanonicalSignatureWithHashType:(NSData*)data verifyLowerS:(BOOL)verifyLowerS error:(NSError**)errorOut;

+ (BOOL) isCanonicalSignatureWithHashType:(NSData*)data verifyEvenS:(BOOL)verifyEvenS error:(NSError**)errorOut DEPRECATED_ATTRIBUTE;


@end


