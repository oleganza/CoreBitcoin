// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// Securely overwrites memory buffer with a specified character.
void *BTCSecureMemset(void *v, unsigned char c, size_t n);

// Securely overwrites string with zeros.
void BTCSecureClearCString(char *s);

// Returns data with securely random bytes of the specified length. Uses /dev/random.
NSData* BTCRandomDataWithLength(NSUInteger length);

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


// TODO: rewrite all of these into functions to avoid issues with losing category methods during linking.
@interface NSData (BTC)


// Core hash functions that we need
- (NSData*) SHA256;
- (NSData*) RIPEMD160;
- (NSData*) doubleSHA256;    // aka Hash in BitcoinQT, more efficient than .SHA256.SHA256
- (NSData*) SHA256RIPEMD160; // aka Hash160 in BitcoinQT, more efficient than .SHA256.RIPEMD160

// Formats data as a lowercase hex string
- (NSString*) hexString;
- (NSString*) hexUppercaseString;

// Encrypts/decrypts data using the key.
+ (NSMutableData*) encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector;
+ (NSMutableData*) decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector;

@end

