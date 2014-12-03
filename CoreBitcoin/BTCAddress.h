// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

// Addresses are Base58-encoded pieces of data representing various objects:
//
// 1. Public key (actually, a hash of a public key) address. Example: 19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ.
// 2. Private key for uncompressed public key. Example: 5KQntKuhYWSRXNqp2yhdXzjekYAR7US3MT1715Mbv5CyUKV6hVe.
// 3. Private key for compressed public key. Example: L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu.
// 4. Script address (P2SH). Example: 3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8.
//
// Testnet addresses are also supported with the following subclasses:
//   BTCPublicKeyAddressTestnet, 
//   BTCPrivateKeyAddressTestnet, 
//   BTCScriptHashAddressTestnet.
//
@class BTCKey;
@interface BTCAddress : NSObject

// Returns an instance of a specific subclass depending on version number.
// Returns nil for unsupported addresses.
+ (instancetype) addressWithString:(NSString*)string;

// Initializes address with raw data. Should only be used in subclasses, base class will raise exception.
+ (instancetype) addressWithData:(NSData*)data;

// Returns an instance of a specific subclass depending on version number.
// Returns nil for unsupported addresses.
// DEPRECATED! Use `-addressWithString:` instead.
+ (instancetype) addressWithBase58String:(NSString*)string;

// Returns binary contents of an address (without checksums or version number).
// 20 bytes for hashes, 32 bytes for private key.
@property(nonatomic, readonly) NSData* data;

// Returns representation in base58 encoding.
@property(nonatomic, readonly) NSString* string;

// Returns representation in base58 encoding.
// DEPRECATED! Use -string instead.
@property(nonatomic, readonly) NSString* base58String;

/*!
 * Returns a public version of this address. By default it's receiver itself.
 * PrivateKeyAddress returns appropriate PublicKeyAddress.
 */
@property(nonatomic, readonly) BTCAddress* publicAddress;

/*!
 * Returns YES if this address is intended for testnet.
 */
@property(nonatomic, readonly) BOOL isTestnet;

/*!
 * Clears contents of the data to prevent leaks.
 */
- (void) clear;

@end


// Standard pulic key address (19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ)
@interface BTCPublicKeyAddress : BTCAddress
@end
@interface BTCPublicKeyAddressTestnet : BTCPublicKeyAddress
@end


// Private key in WIF format (5KQntKuhYWSRXNq... or L3p8oAcQTtuokSC..., base58-encoded)
@interface BTCPrivateKeyAddress : BTCAddress
// Private key itself is not compressed, but it has extra 0x01 byte to indicate
// that derived pubkey must be compressed (as this affects the address derived from pubkey).
@property(nonatomic, getter=isPublicKeyCompressed) BOOL publicKeyCompressed;

// Returns BTCKey containing a key pair. Its public key is compressed as specified by the address.
@property(nonatomic, readonly) BTCKey* key;

// Creates address from raw private key data. If the public key must be compressed, pass YES to publicKeyCompressed:.
+ (instancetype) addressWithData:(NSData*)data publicKeyCompressed:(BOOL)compressedPubkey;
@end
@interface BTCPrivateKeyAddressTestnet : BTCPrivateKeyAddress
@end

// P2SH address (e.g. 3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8)
@interface BTCScriptHashAddress : BTCAddress
@end
@interface BTCScriptHashAddressTestnet : BTCScriptHashAddress
@end
