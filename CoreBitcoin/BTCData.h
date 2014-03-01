// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

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
NSData* BTCSHA256Concat(NSData* data1, NSData* data2); // SHA256(data1 || data2)
NSData* BTCHash256(NSData* data); // == SHA256(SHA256(data)) (aka Hash() in BitcoinQT)
NSData* BTCHash256Concat(NSData* data1, NSData* data2);  // SHA256(SHA256(data1 || data2))
NSData* BTCHMACSHA512(NSData* key, NSData* data);

#if BTCDataRequiresOpenSSL
// RIPEMD160 today is provided only by OpenSSL. SHA1 and SHA2 are provided by CommonCrypto framework.
NSData* BTCRIPEMD160(NSData* data);
NSData* BTCHash160(NSData* data); // == RIPEMD160(SHA256(data)) (aka Hash160 in BitcoinQT)
#endif

// 160-bit zero string
NSData* BTCZero160();

// 256-bit zero string
NSData* BTCZero256();

// Pointer to a static array of zeros (256 bits long).
const unsigned char* BTCZeroString256();

// Converts data to a hex string
NSString* BTCHexStringFromData(NSData* data);
NSString* BTCUppercaseHexStringFromData(NSData* data); // more efficient than calling -uppercaseString on a lower-case result.

// Hashes input with salt using specified number of rounds and the minimum amount of memory (rounded up to a whole number of 256-bit blocks).
// Actual number of hash function computations is a number of rounds multiplied by a number of 256-bit blocks.
// So rounds=1 for 256 Mb of memory would mean 8M hash function calculations (8M blocks by 32 bytes to form 256 Mb total).
// Uses SHA256 as an internal hash function.
// Password and salt are hashed before being placed in the first block.
// The whole memory region is hashed after all rounds to generate the result.
// Based on proposal by Sergio Demian Lerner http://bitslog.files.wordpress.com/2013/12/memohash-v0-3.pdf
// Returns a mutable data, so you can cleanup the memory when needed.
NSMutableData* BTCMemoryHardKDF256(NSData* password, NSData* salt, unsigned int rounds, unsigned int numberOfBytes);


// Hashes input with salt using specified number of rounds and the minimum amount of memory (rounded up to a whole number of 128-bit blocks)
NSMutableData* BTCMemoryHardAESKDF(NSData* password, NSData* salt, unsigned int rounds, unsigned int numberOfBytes);

// Probabilistic memory-hard KDF with 256-bit output and only one difficulty parameter - amount of memory.
// Actual amount of memory is rounded to a whole number of 256-bit blocks.
// Uses SHA512 as internal hash function.
// Computational time is proportional to amount of memory.
// Brutefore with half the memory raises amount of hash computations quadratically.
NSMutableData* BTCJerk256(NSData* password, NSData* salt, unsigned int numberOfBytes);



