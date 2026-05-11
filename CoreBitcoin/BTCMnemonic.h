// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

typedef NS_ENUM(int8_t, BTCMnemonicWordListType) {
    /** English wordlist specified by BIP39. */
    BTCMnemonicWordListTypeEnglish = 0,

    /** Unknown wordlist. When importing a mnemonic, the checksum cannot be verified. */
    BTCMnemonicWordListTypeUnknown = -1,
};

@class BTCKeychain;

/**
 * Implements BIP39 mnemonic codes for generating deterministic keys.
 */
@interface BTCMnemonic : NSObject

/** Type of the wordlist being used. */
@property(nonatomic, readonly) BTCMnemonicWordListType wordListType;

/** Raw entropy buffer used as input. */
@property(nonatomic, readonly) NSData* entropy;

/**
 * List of words composed from the receiver's entropy using the specified wordlist.
 *
 * These words can be written down by the user and used to recover the seed.
 */
@property(nonatomic, readonly) NSArray* words;

/** Optional password. If no password was specified, returns an empty string. */
@property(nonatomic, readonly) NSString* password;

/**
 * Wallet seed computed from words and password for use with BIP32 or similar schemes.
 *
 * @discussion In this API, "seed" means an input for an external key derivation
 * scheme, such as BIP32. The inputs for this mnemonic implementation are
 * `entropy`, `password`, and `wordListType`.
 */
@property(nonatomic, readonly) NSData* seed;

/** Root keychain instantiated with the receiver's seed. */
@property(nonatomic, readonly) BTCKeychain* keychain;

/** Compact binary representation of the mnemonic. */
@property(nonatomic, readonly) NSData* data;

/** Binary representation of the mnemonic with the computed seed appended for caching. */
@property(nonatomic, readonly) NSData* dataWithSeed;

/**
 * Initializes a mnemonic with a raw entropy buffer, optional password, and wordlist.
 *
 * @param entropy Raw entropy. Its length in bits must be divisible by 32:
 * 128, 160, 192, 224, or 256 bits.
 * @param password Optional password. If `nil`, it is treated as an empty string.
 * @param wordListType Wordlist used to encode the mnemonic words.
 *
 * @return Initialized mnemonic, or `nil` if entropy has an incorrect size or
 * the wordlist is not supported.
 */
- (id) initWithEntropy:(NSData*)entropy password:(NSString*)password wordListType:(BTCMnemonicWordListType)wordListType;

/**
 * Initializes a mnemonic with user-provided words, optional password, and wordlist type.
 *
 * @param words Mnemonic words to import.
 * @param password Optional password. If `nil`, it is treated as an empty string.
 * @param wordListType Wordlist used by the words. If this is
 * `BTCMnemonicWordListTypeUnknown`, the checksum is not verified.
 *
 * @return Initialized mnemonic, or `nil` if the checksum is invalid.
 */
- (id) initWithWords:(NSArray*)words password:(NSString*)password wordListType:(BTCMnemonicWordListType)wordListType;

/**
 * Deserializes a mnemonic from its binary representation.
 *
 * @param data Binary representation containing wordlist type, raw entropy,
 * password, and optional computed seed.
 *
 * @return Initialized mnemonic. If the data was produced by `-dataWithSeed`,
 * the seed is loaded from data and is not recomputed.
 */
- (id) initWithData:(NSData*)data;

/** Clears all sensitive information from memory. */
- (void) clear;

@end
