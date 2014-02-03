// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// Implementation of BIP32 "Hierarchical Deterministic Wallets" (HDW)
// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
//
// BTCKeychain encapsulates either a pair of "extended" keys (private and public), or only a public extended key.
// "Extended key" means the key (private or public) is accompanied by extra 256 bits of entropy called "chain code".
// Keychain has two modes of operation:
// - "public derivation" which allows to derive public keys separately from the private ones (for indexes below 0x80000000).
// - "private derivation" which derives only private keys (for indexes >= 0x80000000).
// Derivation can be treated as a single key or as an new branch of keychains.
@class BTCKey;
@interface BTCKeychain : NSObject<NSCopying>

// The root key of the keychain. If this is a public-only keychain, key does not have a private key.
@property(nonatomic, readonly) BTCKey* rootKey;

// Chain code associated with the key.
@property(nonatomic, readonly) NSData* chainCode;

// Serialized extended public key.
// Use BTCBase58CheckStringWithData to convert to Base58 form.
@property(nonatomic, readonly) NSData* extendedPublicKey;

// Serialized extended private key or nil if the receiver is public keychain.
// Use BTCBase58CheckStringWithData to convert to Base58 form.
@property(nonatomic, readonly) NSData* extendedPrivateKey;

// 160-bit identifier (aka "hash") of the keychain (RIPEMD160(SHA256(pubkey))).
@property(nonatomic, readonly) NSData* identifier;

// Fingerprint of the keychain.
@property(nonatomic, readonly) uint32_t fingerprint;

// Fingerprint of the parent keychain. For master keychain it is always 0.
@property(nonatomic, readonly) uint32_t parentFingerprint;

// Index in the parent keychain (if highest bit is 1, it is a private derivation).
// If this is a master keychain, index is 0.
@property(nonatomic, readonly) uint32_t index;

// Depth. Master keychain has depth = 0.
@property(nonatomic, readonly) uint8_t depth;

// Initializes master keychain from a seed. This is the "root" keychain of the entire hierarchy.
- (id) initWithSeed:(NSData*)seed;

// Initializes keychain with a serialized extended key.
- (id) initWithExtendedKey:(NSData*)extendedKey;

// Returns YES if the keychain can derive private keys.
- (BOOL) isPrivate;

// Returns a copy of the keychain stripped of the private key.
// Equivalent to [[BTCKeychain alloc] initWithExtendedKey:keychain.extendedPublicKey]
- (BTCKeychain*) publicKeychain;

// Returns a derived keychain. If index is >= 0x80000000, uses private derivation (possible only when private key is present; otherwise returns nil).
// May return nil for some indexes (when hashing leads to invalid EC points) which is very rare, but must be expected. In such case, simply use another index.
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index;

// Returns a derived key from this keychain. This is a convenient way to access [... derivedKeychainAtIndex:i].key
// If the receiver contains a private key, child key will also contain a private key.
// If the receiver contains only a public key, child key will only contain a public key (nil is returned if index >= 0x80000000 - as private derivation is impossible).
- (BTCKey*) keyAtIndex:(uint32_t)index;

@end

