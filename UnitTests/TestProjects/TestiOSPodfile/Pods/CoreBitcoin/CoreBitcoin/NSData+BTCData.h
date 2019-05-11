// EthCore by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCData.h"

// This category is for user's convenience only.
// For documentation look into BTCData.h.
// If you link EthCore library without categories enabled, nothing will break.
// This is also used in unit tests in EthCore.
@interface NSData (BTCData)

// Core hash functions
- (NSData*) SHA1;
- (NSData*) SHA256;
- (NSData*) BTCHash256;  // SHA256(SHA256(self)) aka Hash or Hash256 in BitcoinQT

#if BTCDataRequiresOpenSSL
- (NSData*) RIPEMD160;
- (NSData*) BTCHash160; // RIPEMD160(SHA256(self)) aka Hash160 in BitcoinQT
#endif

// Formats data as a lowercase hex string
- (NSString*) hexString;
- (NSString*) hexUppercaseString;

// Encrypts/decrypts data using the key.
+ (NSMutableData*) encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector;
+ (NSMutableData*) decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector;

@end
