// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCSignatureHashType.h"

@class BTCCurvePoint;
@class BTCPublicKeyAddress;
@class BTCPublicKeyAddressTestnet;
@class BTCPrivateKeyAddress;
@class BTCPrivateKeyAddressTestnet;

/**
 * Encapsulates an EC keypair, or public key only, on the secp256k1 curve.
 *
 * @discussion A key initialized with a public key can only verify signatures.
 * A key initialized with a private key can sign, verify, derive addresses, and
 * export private-key formats.
 */
@interface BTCKey : NSObject

/** Initializes a newly generated random keypair. */
- (id) init;

/**
 * Initializes a public-only key.
 *
 * @param publicKey Serialized public key data.
 *
 * @return Public-only key suitable for signature verification.
 */
- (id) initWithPublicKey:(NSData*)publicKey;

/**
 * Initializes a public-only key using a point on secp256k1.
 *
 * @param curvePoint Curve point representing the public key.
 */
- (id) initWithCurvePoint:(BTCCurvePoint*)curvePoint;

/**
 * Initializes a keypair with a 32-byte secp256k1 secret parameter.
 *
 * @param privateKey 32-byte private key.
 */
- (id) initWithPrivateKey:(NSData*)privateKey;

/**
 * Initializes a keypair with a WIF-encoded private key.
 *
 * @param wifString WIF string, such as
 * `5znkrJzL5GTFCaXWufUCUaPzDmLj2Pe2pWtAcSzg4hRUVxS2XqHa`.
 *
 * @see initWithPrivateKeyAddress:
 */
- (id) initWithWIF:(NSString*)wifString;

/**
 * Initializes a keypair with a DER-encoded private key.
 *
 * @param DERPrivateKey DER-encoded private key data.
 */
- (id) initWithDERPrivateKey:(NSData*)DERPrivateKey;

/**
 * @name Public and Private Key Material
 */

/**
 * Serialized public key.
 *
 * The returned data is mutable so callers can clear it if needed. The key is
 * compressed when `publicKeyCompressed` is `YES`.
 */
@property(nonatomic, readonly) NSMutableData* publicKey;

/** Explicitly compressed serialized public key. */
@property(nonatomic, readonly) NSMutableData* compressedPublicKey;

/** Explicitly uncompressed serialized public key. */
@property(nonatomic, readonly) NSMutableData* uncompressedPublicKey;

/**
 * 32-byte secret parameter.
 *
 * This is all that is needed to reconstruct the full keypair on secp256k1.
 */
@property(nonatomic, readonly) NSMutableData* privateKey;

/** DER-encoded private key data that includes the secret and curve parameters. */
@property(nonatomic, readonly) NSMutableData* DERPrivateKey;

/** Base58Check-encoded mainnet private key, or `nil` when no private key is available. */
@property(nonatomic, readonly) NSString* WIF;

/** Base58Check-encoded testnet private key, or `nil` when no private key is available. */
@property(nonatomic, readonly) NSString* WIFTestnet;

/**
 * Whether the public key is compressed.
 *
 * @discussion When a public key is set, this property reflects its serialized
 * form. To change it, the receiver must contain a private key. Then
 * `-publicKey` returns compressed or uncompressed data accordingly.
 */
@property(nonatomic, getter=isPublicKeyCompressed) BOOL publicKeyCompressed;

/** Public key represented as a point on the secp256k1 curve. */
@property(nonatomic, readonly) BTCCurvePoint* curvePoint;

/**
 * Verifies a signature for a 256-bit hash with the receiver's public key.
 *
 * @param signature DER-encoded signature.
 * @param hash 256-bit hash that was signed.
 */
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash;

/**
 * Performs ECDH multiplication with another private key.
 *
 * @param privkey Private key used as the scalar.
 *
 * @return Public-only key for the resulting curve point. The public-key
 * compression flag matches the receiver.
 */
- (BTCKey*) diffieHellmanWithPrivateKey:(BTCKey*)privkey;

/**
 * Signs a 256-bit hash with the receiver's private key.
 *
 * @return DER-encoded signature, or `nil` if signing fails or no private key is present.
 */
- (NSData*) signatureForHash:(NSData*)hash;

/**
 * Signs a 256-bit hash and appends a Bitcoin signature hash-type byte.
 *
 * @param hash 256-bit hash to sign.
 * @param hashType Signature hash type appended to the returned signature.
 */
- (NSData*) signatureForHash:(NSData*)hash hashType:(BTCSignatureHashType)hashType;

/** Deprecated alias for `-signatureForHash:hashType:`. */
- (NSData*) signatureForHash:(NSData*)hash withHashType:(BTCSignatureHashType)hashType DEPRECATED_ATTRIBUTE;

/**
 * Returns the deterministic RFC6979 signature nonce for a hash.
 *
 * @param hash 256-bit hash that will be signed.
 *
 * @return Mutable 32-byte `k` nonce generated from `hash` and the private key,
 * so callers can clear it when finished.
 *
 * @see https://tools.ietf.org/html/rfc6979
 */
- (NSMutableData*) signatureNonceForHash:(NSData*)hash;

/** Clears all key data from memory and makes the receiver invalid. */
- (void) clear;


/**
 * @name BTCAddress Import and Export
 */

/**
 * Initializes a keypair from a private-key address.
 *
 * Also configures public-key compression according to the address.
 */
- (id) initWithPrivateKeyAddress:(BTCPrivateKeyAddress*)privateKeyAddress;

/**
 * Public-key hash address.
 *
 * The resulting address depends on whether `publicKeyCompressed` is `YES`.
 */
@property(nonatomic, readonly) BTCPublicKeyAddress* publicKeyAddress DEPRECATED_ATTRIBUTE;

/**
 * Public-key hash address.
 *
 * The resulting address depends on whether `publicKeyCompressed` is `YES`.
 */
@property(nonatomic, readonly) BTCPublicKeyAddress* address;

/** Testnet public-key hash address. */
@property(nonatomic, readonly) BTCPublicKeyAddressTestnet* addressTestnet;

/** Address for the uncompressed public key: Hash160(public key). */
@property(nonatomic, readonly) BTCPublicKeyAddress* uncompressedPublicKeyAddress;

/** Address for the compressed public key: Hash160(public key). */
@property(nonatomic, readonly) BTCPublicKeyAddress* compressedPublicKeyAddress;

/** Mainnet private key address encoded in WIF/SIPA format. */
@property(nonatomic, readonly) BTCPrivateKeyAddress* privateKeyAddress;

/** Testnet private key address encoded in WIF/SIPA format. */
@property(nonatomic, readonly) BTCPrivateKeyAddressTestnet* privateKeyAddressTestnet;





/**
 * @name Compact Signatures
 */

/**
 * Returns a compact signature for a 256-bit hash.
 *
 * Compact signatures are 65 bytes and allow reconstruction of the public key
 * used to sign. This is also known as `CKey::SignCompact` in Bitcoin Core.
 */
- (NSData*) compactSignatureForHash:(NSData*)data;

/**
 * Verifies a hash against a compact signature.
 *
 * @return Recovered public key on success, otherwise `nil`.
 */
+ (BTCKey*) verifyCompactSignature:(NSData*)compactSignature forHash:(NSData*)hash;

/** Verifies a compact signature for a hash with the receiver's public key. */
- (BOOL) isValidCompactSignature:(NSData*)signature forHash:(NSData*)hash;





/**
 * @name Bitcoin Signed Messages
 */


/**
 * Returns a signature for a Bitcoin Signed Message string.
 *
 * The message is signed using the Bitcoin Signed Message prefix.
 */
- (NSData*) signatureForMessage:(NSString*)message;

/** Returns a signature for binary message data using the Bitcoin Signed Message prefix. */
- (NSData*) signatureForBinaryMessage:(NSData*)data;

/**
 * Verifies a textual Bitcoin Signed Message.
 *
 * @return Recovered public key on success, otherwise `nil`.
 */
+ (BTCKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message;

/**
 * Verifies a binary Bitcoin Signed Message.
 *
 * @return Recovered public key on success, otherwise `nil`.
 */
+ (BTCKey*) verifySignature:(NSData*)signature forBinaryMessage:(NSData*)data;

/** Verifies a textual Bitcoin Signed Message with the receiver's public key. */
- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message;

/** Verifies a binary Bitcoin Signed Message with the receiver's public key. */
- (BOOL) isValidSignature:(NSData*)signature forBinaryMessage:(NSData*)data;


/**
 * @name Canonical Encoding Checks
 */

/**
 * Checks whether public-key data uses canonical Bitcoin encoding.
 *
 * @discussion Used by Bitcoin Core within `OP_CHECKSIG` relay policy. A
 * non-canonical public key can still be valid to OpenSSL EC internals and may
 * be accepted by Bitcoin nodes.
 *
 * See https://bitcointalk.org/index.php?topic=8392.80
 */
+ (BOOL) isCanonicalPublicKey:(NSData*)data error:(NSError**)errorOut;

/**
 * Checks whether a script signature uses canonical encoding.
 *
 * @param data Signature data including the hash-type byte.
 * @param verifyLowerS If `YES`, also enforces lower-S normalization.
 * @param errorOut Optional error output.
 */
+ (BOOL) isCanonicalSignatureWithHashType:(NSData*)data verifyLowerS:(BOOL)verifyLowerS error:(NSError**)errorOut;

/** Deprecated alias for canonical signature checking with even-S verification. */
+ (BOOL) isCanonicalSignatureWithHashType:(NSData*)data verifyEvenS:(BOOL)verifyEvenS error:(NSError**)errorOut DEPRECATED_ATTRIBUTE;


@end

