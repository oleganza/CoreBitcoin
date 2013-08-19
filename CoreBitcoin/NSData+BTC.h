// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

void *BTCSecureMemset(void *v, int c, size_t n);
void BTCSecureClearCString(char *s);

// TODO: rewrite all of these into functions to avoid issues with losing category methods during linking.
@interface NSData (BTC)

// Init with securely random byte string from /dev/random
- (id) initRandomWithLength:(NSUInteger)length;

// Init with zero-terminated string in UTF-8 encoding.
- (id) initWithUTF8String:(const char*)utf8string;

// Init with hex string (lower- or uppercase, with optional 0x prefix)
- (id) initWithHexString:(NSString*)hexString;

// Init with zero-terminated hex raw string (lower- or uppercase, with optional 0x prefix)
- (id) initWithHexCString:(const char*)hexCString;

// Returns a copy of data with reversed byte order.
// This is useful in Bitcoin: things get reversed here and there all the time.
- (NSData*) reversedData;
// Returns a reversed mutable copy so you wouldn't need to make another mutable copy from -reversedData
- (NSMutableData*) reversedMutableData;

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

// Reverses byte order in a buffer with a specified length.
+ (void) reverseBytes:(void*)bytes length:(NSUInteger)length;

@end

@interface NSMutableData (BTC)

// Reverses byte order in the internal buffer.
- (void) reverse;

// Clears contents of the data to prevent leaks through swapping or buffer-overflow attacks.
- (void) clear;
@end
