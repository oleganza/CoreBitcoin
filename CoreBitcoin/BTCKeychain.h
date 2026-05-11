// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

/**
 * Maximum non-hardened child index accepted by derivation APIs.
 */

static const uint32_t BTCKeychainMaxIndex = 0x7fffffff;

@class BTCKey;
@class BTCBigNumber;
@class BTCAddress;
@class BTCNetwork;

/**
 * Implements BIP32 Hierarchical Deterministic Wallets.
 *
 * @discussion A keychain encapsulates either a pair of extended keys (private
 * and public), or only a public extended key. An extended key is a key plus
 * 256 bits of chain-code entropy and metadata describing its position in the
 * derivation tree: depth, parent fingerprint, and child index.
 *
 * Keychains support normal derivation, which allows public keys to be derived
 * independently from private keys, and hardened derivation, which requires a
 * private key.
 *
 * See BIP32: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
 */
@interface BTCKeychain : NSObject<NSCopying>

/**
 * Initializes the master keychain from a seed.
 *
 * @param seed Seed bytes used to create the root keychain.
 *
 * @return Root keychain for the entire hierarchy. The network defaults to
 * mainnet. To specify testnet, use `-initWithSeed:network:`.
 */
- (id) initWithSeed:(NSData*)seed;

/**
 * Initializes the master keychain from a seed for a specific network.
 *
 * @param seed Seed bytes used to create the root keychain.
 * @param network Network used when formatting extended keys.
 *
 * @return Root keychain for the entire hierarchy.
 */
- (id) initWithSeed:(NSData*)seed network:(BTCNetwork*)network;

/**
 * Initializes a keychain from a Base58Check-encoded extended key.
 *
 * @param extendedKey Extended public or private key.
 *
 * @return Initialized keychain. The network is inferred from the formatted key.
 */
- (id) initWithExtendedKey:(NSString*)extendedKey;

/**
 * Initializes a keychain with serialized extended-key data.
 *
 * @param extendedKeyData Serialized extended-key data. Use
 * `BTCDataFromBase58Check()` to convert from a Base58 string.
 *
 * @return Initialized keychain.
 */
- (id) initWithExtendedKeyData:(NSData*)extendedKeyData DEPRECATED_ATTRIBUTE;

/** Clears all sensitive data from the keychain and makes the receiver invalid. */
- (void) clear;

/** Network used for formatting extended keys. Defaults to mainnet. */
@property(nonatomic) BTCNetwork* network;

/** Deprecated because of the badly chosen name. Use `-key` instead. */
@property(nonatomic, readonly) BTCKey* rootKey DEPRECATED_ATTRIBUTE;

/**
 * Head key for this keychain.
 *
 * If the keychain is public-only, the key does not have a private component.
 */
@property(nonatomic, readonly) BTCKey* key;

/** Chain code associated with the key. */
@property(nonatomic, readonly) NSData* chainCode;

/** Base58Check-encoded extended public key. */
@property(nonatomic, readonly) NSString* extendedPublicKey;

/** Base58Check-encoded extended private key, or `nil` for a public-only keychain. */
@property(nonatomic, readonly) NSString* extendedPrivateKey;

/**
 * Raw binary data for the serialized extended public key.
 *
 * Use `BTCBase58CheckStringWithData()` to convert to Base58 form.
 */
@property(nonatomic, readonly) NSData* extendedPublicKeyData DEPRECATED_ATTRIBUTE;

/**
 * Raw binary data for the serialized extended private key.
 *
 * @return Serialized extended private key data, or `nil` for a public-only
 * keychain. Use `BTCBase58CheckStringWithData()` to convert to Base58 form.
 */
@property(nonatomic, readonly) NSData* extendedPrivateKeyData DEPRECATED_ATTRIBUTE;

/** 160-bit keychain identifier: RIPEMD160(SHA256(public key)). */
@property(nonatomic, readonly) NSData* identifier;

/** Fingerprint of the keychain. */
@property(nonatomic, readonly) uint32_t fingerprint;

/** Fingerprint of the parent keychain. For the master keychain, this is always 0. */
@property(nonatomic, readonly) uint32_t parentFingerprint;

/** Index in the parent keychain. For the master keychain, this is 0. */
@property(nonatomic, readonly) uint32_t index;

/** Depth in the derivation hierarchy. The master keychain has depth 0. */
@property(nonatomic, readonly) uint8_t depth;

/** Returns `YES` if the keychain can derive private keys. */
@property(nonatomic, readonly) BOOL isPrivate;

/**
 * Returns `YES` if the keychain was derived from its parent via hardened derivation.
 *
 * @discussion Hardened derivation stores the child number internally as
 * `0x80000000 | self.index`. For the master keychain, the index is 0 and
 * `isHardened` is `NO`.
 */
@property(nonatomic, readonly) BOOL isHardened;

/**
 * Copy of the keychain stripped of its private key.
 *
 * Equivalent to `[[BTCKeychain alloc] initWithExtendedKey:keychain.extendedPublicKey]`.
 */
@property(nonatomic, readonly) BTCKeychain* publicKeychain;

/**
 * Returns a normally derived child keychain at `index`.
 *
 * @param index Child index. Must be less than or equal to
 * `BTCKeychainMaxIndex`.
 *
 * @return Derived child keychain, or `nil` for the extremely rare case where
 * hashing leads to invalid EC points.
 */
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index;

/**
 * Returns a derived child keychain at `index`.
 *
 * @param index Child index. Must be less than or equal to
 * `BTCKeychainMaxIndex`; larger values raise an exception.
 * @param hardened If `YES`, uses hardened derivation, which requires the
 * receiver to contain a private key. If the receiver is public-only, returns
 * `nil`.
 *
 * @return Derived child keychain, or `nil` for the extremely rare case where
 * hashing leads to invalid EC points. In that case, use another index.
 */
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index hardened:(BOOL)hardened;

/**
 * Returns a derived child keychain and optionally reports the private-key tweak.
 *
 * @param index Child index. Must be less than or equal to
 * `BTCKeychainMaxIndex`; larger values raise an exception.
 * @param hardened If `YES`, uses hardened derivation.
 * @param factorOut If not `NULL`, receives the number added to the private key.
 * This is used by the `BTCBlindSignature` protocol.
 *
 * @return Derived child keychain, or `nil` if derivation is impossible or invalid.
 */
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index hardened:(BOOL)hardened factor:(BTCBigNumber**)factorOut;

/**
 * Parses a BIP32 path and derives the corresponding keychain.
 *
 * @param path Path with syntax `(m?/)?([0-9]+'?(/[0-9]+'?)*)?`.
 *
 * @return Derived keychain, root keychain for an empty/root path, or `nil` if
 * the path is invalid.
 *
 * @discussion Valid root paths include `""`, `"m"`, and `"/"`. Valid child
 * paths include `"m/0'"`, `"/0'"`, `"0'"`, `"m/44'/1'/2'"`,
 * `"/44'/1'/2'"`, and `"44'/1'/2'"`. Invalid paths include strings with
 * spaces, alphabetical path components, or illegal characters.
 */
- (BTCKeychain*) derivedKeychainWithPath:(NSString*)path;

/**
 * Returns the key at a BIP32 path.
 *
 * Equivalent to `[keychain derivedKeychainWithPath:@"..."].key`.
 */
- (BTCKey*) keyWithPath:(NSString*)path;

/**
 * Returns a normally derived key at `index`.
 *
 * Equivalent to `[keychain derivedKeychainAtIndex:index].key`.
 */
- (BTCKey*) keyAtIndex:(uint32_t)index;

/**
 * Returns a derived key from this keychain.
 *
 * @discussion If the receiver contains a private key, the child key also
 * contains a private key. If the receiver is public-only, the child key is
 * public-only, or `nil` is returned when `hardened` is `YES`.
 */
- (BTCKey*) keyAtIndex:(uint32_t)index hardened:(BOOL)hardened;


/**
 * @name BIP44 Helpers
 */

/** Subchain with path `m/44'/0'`. */
@property(nonatomic, readonly) BTCKeychain* bitcoinMainnetKeychain;

/** Subchain with path `m/44'/1'`. */
@property(nonatomic, readonly) BTCKeychain* bitcoinTestnetKeychain;

/**
 * Returns a hardened derivation for the given account index.
 *
 * Equivalent to `[keychain derivedKeychainAtIndex:accountIndex hardened:YES]`.
 */
- (BTCKeychain*) keychainForAccount:(uint32_t)accountIndex;

/**
 * Returns a key from an external chain path `/0/index`.
 *
 * The returned key may be public-only if the receiver is a public-only keychain.
 */
- (BTCKey*) externalKeyAtIndex:(uint32_t)index;

/**
 * Returns a key from an internal change chain path `/1/index`.
 *
 * The returned key may be public-only if the receiver is a public-only keychain.
 */
- (BTCKey*) changeKeyAtIndex:(uint32_t)index;



/**
 * @name Scanning Child Keys
 */

/**
 * Scans child keychains for one matching an address.
 *
 * @param address Address to find. Only `BTCPublicKeyAddress` and
 * `BTCPrivateKeyAddress` are supported.
 * @param hardened Whether to scan hardened child keychains.
 * @param limit Maximum number of child keychains to scan.
 *
 * @return Matching child keychain, or `nil` if none is found, the address type
 * is unsupported, or the receiver does not contain a private key.
 */
- (BTCKeychain*) findKeychainForAddress:(BTCAddress*)address hardened:(BOOL)hardened limit:(NSUInteger)limit;

/**
 * Scans child keychains from `startIndex` for one matching an address.
 *
 * @param address Address to find. Only `BTCPublicKeyAddress` and
 * `BTCPrivateKeyAddress` are supported.
 * @param hardened Whether to scan hardened child keychains.
 * @param startIndex First child index to scan.
 * @param limit Maximum number of child keychains to scan.
 *
 * @return Matching child keychain, or `nil` if none is found, the address type
 * is unsupported, or the receiver does not contain a private key.
 */
- (BTCKeychain*) findKeychainForAddress:(BTCAddress*)address hardened:(BOOL)hardened from:(uint32_t)startIndex limit:(NSUInteger)limit;

/**
 * Scans child keychains for one matching a public key.
 *
 * @param pubkey Public key to find.
 * @param hardened Whether to scan hardened child keychains.
 * @param limit Maximum number of child keychains to scan.
 *
 * @return Matching child keychain, or `nil` if none is found or the receiver
 * does not contain a private key.
 */
- (BTCKeychain*) findKeychainForPublicKey:(BTCKey*)pubkey hardened:(BOOL)hardened limit:(NSUInteger)limit;

/**
 * Scans child keychains from `startIndex` for one matching a public key.
 *
 * @param pubkey Public key to find.
 * @param hardened Whether to scan hardened child keychains.
 * @param startIndex First child index to scan.
 * @param limit Maximum number of child keychains to scan.
 *
 * @return Matching child keychain, or `nil` if none is found or the receiver
 * does not contain a private key.
 */
- (BTCKeychain*) findKeychainForPublicKey:(BTCKey*)pubkey hardened:(BOOL)hardened from:(uint32_t)startIndex limit:(NSUInteger)limit;

@end
