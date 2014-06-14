// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

// Implementation of BIP32 "Hierarchical Deterministic Wallets" (HDW)
// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
//
// BTCKeychain encapsulates either a pair of "extended" keys (private and public), or only a public extended key.
// "Extended key" means the key (private or public) is accompanied by extra 256 bits of entropy called "chain code" and
// some metadata about it's position in a tree of keys (depth, parent fingerprint, index).
// Keychain has two modes of operation:
// - "normal derivation" which allows to derive public keys separately from the private ones (internally i below 0x80000000).
// - "hardened derivation" which derives only private keys (for i >= 0x80000000).
// Derivation can be treated as a single key or as an new branch of keychains.

static const uint32_t BTCKeychainMaxIndex = 0x7fffffff;

@class BTCKey;
@class BTCBigNumber;
@interface BTCKeychain : NSObject<NSCopying>

// The root key of the keychain. If this is a public-only keychain, key does not have a private key.
@property(nonatomic, readonly) BTCKey* rootKey;

// Chain code associated with the key.
@property(nonatomic, readonly) NSData* chainCode;

// Serialized extended public key.
// Use BTCBase58CheckStringWithData() to convert to Base58 form.
@property(nonatomic, readonly) NSData* extendedPublicKey;

// Serialized extended private key or nil if the receiver is public-only keychain.
// Use BTCBase58CheckStringWithData() to convert to Base58 form.
@property(nonatomic, readonly) NSData* extendedPrivateKey;

// 160-bit identifier (aka "hash") of the keychain (RIPEMD160(SHA256(pubkey))).
@property(nonatomic, readonly) NSData* identifier;

// Fingerprint of the keychain.
@property(nonatomic, readonly) uint32_t fingerprint;

// Fingerprint of the parent keychain. For master keychain it is always 0.
@property(nonatomic, readonly) uint32_t parentFingerprint;

// Index in the parent keychain.
// If this is a master keychain, index is 0.
@property(nonatomic, readonly) uint32_t index;

// Depth. Master keychain has depth = 0.
@property(nonatomic, readonly) uint8_t depth;

// Initializes master keychain from a seed. This is the "root" keychain of the entire hierarchy.
- (id) initWithSeed:(NSData*)seed;

// Initializes keychain with a serialized extended key.
// Use BTCDataFromBase58Check() to convert from Base58 string.
- (id) initWithExtendedKey:(NSData*)extendedKey;

// Returns YES if the keychain can derive private keys.
- (BOOL) isPrivate;

// Returns YES if the keychain was derived via hardened derivation from its parent.
// This means internally parameter i = 0x80000000 | self.index
// For the master keychain index is zero and isHardened=NO.
- (BOOL) isHardened;

// Returns a copy of the keychain stripped of the private key.
// Equivalent to [[BTCKeychain alloc] initWithExtendedKey:keychain.extendedPublicKey]
- (BTCKeychain*) publicKeychain;

// Returns a derived keychain.
// If hardened = YES, uses hardened derivation (possible only when private key is present; otherwise returns nil).
// Index must be less of equal BTCKeychainMaxIndex, otherwise throws an exception.
// May return nil for some indexes (when hashing leads to invalid EC points) which is very rare (chance is below 2^-127), but must be expected. In such case, simply use another index.
// By default, a normal (non-hardened) derivation is used.
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index;
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index hardened:(BOOL)hardened;

// If factorOut is not NULL, it will be contain a number that is being added to the private key.
// This is useful when BIP32 is used in blind signatures protocol.
- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index hardened:(BOOL)hardened factor:(BTCBigNumber**)factorOut;

// Returns a derived key from this keychain. This is a convenient way to access [... derivedKeychainAtIndex:i hardened:YES/NO].rootKey
// If the receiver contains a private key, child key will also contain a private key.
// If the receiver contains only a public key, child key will only contain a public key. (Or nil will be returned if hardened = YES.)
// By default, a normal (non-hardened) derivation is used.
- (BTCKey*) keyAtIndex:(uint32_t)index;
- (BTCKey*) keyAtIndex:(uint32_t)index hardened:(BOOL)hardened;

// Clears sensitive data from keychain
- (void) clear;

@end

