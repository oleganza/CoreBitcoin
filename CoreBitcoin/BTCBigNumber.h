// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

// Bitcoin-flavoured big number wrapping OpenSSL BIGNUM.
@interface BTCBigNumber : NSObject

@property(nonatomic) uint32_t compact; // compact representation used for the difficulty target
@property(nonatomic) uint32_t uint32value;
@property(nonatomic) int32_t int32value;
@property(nonatomic) uint64_t uint64value;
@property(nonatomic) int64_t int64value;
@property(nonatomic) NSData* data;
@property(nonatomic) NSString* hexString;
@property(nonatomic) NSString* decimalString;

+ (id) zero;
+ (id) one;

- (id) init;
- (id) initWithCompact:(uint32_t)compact;
- (id) initWithUInt32:(uint32_t)value;
- (id) initWithInt32:(int32_t)value;
- (id) initWithUInt64:(uint64_t)value;
- (id) initWithInt64:(int64_t)value;
- (id) initWithData:(NSData*)data;

// Inits with setString:base:
- (id) initWithString:(NSString*)string base:(NSUInteger)base;

// Same as initWithString:base:16
- (id) initWithHexString:(NSString*)hexString;

// Same as initWithString:base:10
- (id) initWithDecimalString:(NSString*)decimalString;

// Supports bases from 2 to 36. For base 2 allows optional 0b prefix, base 16 allows optional 0x prefix. Spaces are ignored.
- (void) setString:(NSString*)string base:(NSUInteger)base;
- (NSString*) stringInBase:(NSUInteger)base;

// TODO: add support for hash, figure out what the heck is that.
//void set_hash(hash_digest load_hash);
//hash_digest hash() const;

- (BOOL) less:(BTCBigNumber*)other;
- (BOOL) lessOrEqual:(BTCBigNumber*)other;
- (BOOL) greater:(BTCBigNumber*)other;
- (BOOL) greaterOrEqual:(BTCBigNumber*)other;

// Operators modify the receiver and return self.
// To create a new instance z = x + y use copy method: z = [[x copy] add:y]
- (instancetype) add:(BTCBigNumber*)other; // +=
- (instancetype) subtract:(BTCBigNumber*)other; // -=
- (instancetype) multiply:(BTCBigNumber*)other; // *=
- (instancetype) divide:(BTCBigNumber*)other; // /=
- (instancetype) mod:(BTCBigNumber*)other; // %=
- (instancetype) lshift:(unsigned int)shift; // <<=
- (instancetype) rshift:(unsigned int)shift; // >>=

// Divides receiver by another bignum.
// Returns an array of two new BTCBigNumber instances: @[ quotient, remainder ]
- (NSArray*) divmod:(BTCBigNumber*)other;

// Destroys sensitive data and sets the value to 0.
// It is also called on dealloc.
- (void) clear;

@end
