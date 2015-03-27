// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

// An API to parse and encode protocol buffers.
// Currently incomplete and only supports BIP70 / BTCPaymentProtocol
@interface BTCProtocolBuffers : NSObject

// Reading

// Returns a variable-length integer value at a given offset in source data.
+ (uint64_t) varIntAtOffset:(NSInteger*)offset fromData:(NSData*)src;

// Returns a length-delimited data at a given offset in source data.
+ (NSData *) lenghtDelimitedDataAtOffset:(NSInteger *)offset fromData:(NSData*)src;

// Returns either int or data depending on field type, and returns a field key.
+ (NSInteger) fieldAtOffset:(NSInteger *)offset int:(uint64_t *)i data:(NSData **)d fromData:(NSData*)src;


// Writing

+ (void) writeVarInt:(uint64_t)i toData:(NSMutableData*)dst;
+ (void) writeInt:(uint64_t)i withKey:(NSInteger)key toData:(NSMutableData*)dst;
+ (void) writeLengthDelimitedData:(NSData*)data toData:(NSMutableData*)dst;
+ (void) writeData:(NSData*)d withKey:(NSInteger)key toData:(NSMutableData*)dst;
+ (void) writeString:(NSString*)string withKey:(NSInteger)key toData:(NSMutableData*)dst;

@end
