// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// Change to 0 to disable code that requires OpenSSL (if you need some of these routines in your own project and you don't need OpenSSL)
#define BTCDataRequiresOpenSSL 1

// Use this subclass to make sure data is zeroed
@interface BTCMutableDataZeroedOnDealloc : NSMutableData
+ (instancetype) dataWithData:(NSData *)data;
@end

// Securely overwrites memory buffer with a specified character.
void *BTCSecureMemset(void *v, unsigned char c, size_t n);

// Securely overwrites string with zeros.
void BTCSecureClearCString(char *s);

// Returns data with securely random bytes of the specified length. Uses /dev/random.
NSData* BTCRandomDataWithLength(NSUInteger length);

// Returns data produced by flipping the coin as proposed by Dan Kaminsky:
// https://gist.github.com/PaulCapestany/6148566
NSData* BTCCoinFlipDataWithLength(NSUInteger length);

// Creates data with zero-terminated string in UTF-8 encoding.
NSData* BTCDataWithUTF8String(const char* utf8string);

// Init with hex string (lower- or uppercase, with optional 0x prefix)
NSData* BTCDataWithHexString(NSString* hexString);

// Init with zero-terminated hex string (lower- or uppercase, with optional 0x prefix)
NSData* BTCDataWithHexCString(const char* hexString);

// Returns a copy of data with reversed byte order.
// This is useful in Bitcoin: things get reversed here and there all the time.
NSData* BTCReversedData(NSData* data);

// Returns a reversed mutable copy so you wouldn't need to make another mutable copy from -reversedData
NSMutableData* BTCReversedMutableData(NSData* data);

// Reverses byte order in the internal buffer of mutable data object.
void BTCDataReverse(NSMutableData* data);

// Clears contents of the data to prevent leaks through swapping or buffer-overflow attacks.
void BTCDataClear(NSMutableData* data);

// Core hash functions that we need.
// If the argument is nil, returns nil.
NSData* BTCSHA1(NSData* data);
NSData* BTCSHA256(NSData* data);
NSData* BTCHash256(NSData* data); // == SHA256(SHA256(data)) (aka Hash in BitcoinQT)

#if BTCDataRequiresOpenSSL
// RIPEMD160 today is provided only by OpenSSL. SHA1 and SHA2 are provided by CommonCrypto framework.
NSData* BTCRIPEMD160(NSData* data);
NSData* BTCHash160(NSData* data); // == RIPEMD160(SHA256(data)) (aka Hash160 in BitcoinQT)
#endif

// Converts data to a hex string
NSString* BTCHexStringFromData(NSData* data);
NSString* BTCUppercaseHexStringFromData(NSData* data); // more efficient than calling -uppercaseString on a lower-case result.
