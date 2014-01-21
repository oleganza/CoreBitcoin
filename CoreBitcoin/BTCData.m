// Oleg Andreev <oleganza@gmail.com>

#import "BTCData.h"
#import <CommonCrypto/CommonCrypto.h>
#if BTCDataRequiresOpenSSL
#include <openssl/ripemd.h>
#endif

// Use this subclass to make sure data is zeroed
@implementation BTCMutableDataZeroedOnDealloc : NSMutableData
+ (instancetype) dataWithData:(NSData *)data
{
    if (!data) return nil;
    
    return [NSMutableData dataWithData:data];
    
//    BTCMutableDataZeroedOnDealloc* result = [[BTCMutableDataZeroedOnDealloc alloc] initWithBytes:data.bytes length:data.length];
    BTCMutableDataZeroedOnDealloc* result = [[BTCMutableDataZeroedOnDealloc alloc] init];
    [result appendBytes:data.bytes length:data.length];
    return result;
}
- (void) dealloc
{
    [self resetBytesInRange:NSMakeRange(0, self.length)];
}
@end


// This is designed to be not optimized out by compiler like memset
void *BTCSecureMemset(void *v, unsigned char c, size_t n)
{
    if (!v) return v;
    volatile unsigned char *p = v;
    while (n--)
        *p++ = c;
    
    return v;
}

void BTCSecureClearCString(char *s)
{
    if (!s) return;
    BTCSecureMemset(s, 0, strlen(s));
}

void *BTCCreateRandomBytesOfLength(size_t length)
{
    FILE *fp = fopen("/dev/random", "r");
    if (!fp)
    {
        NSLog(@"NSData+BTC: cannot fopen /dev/random");
        exit(-1);
        return NULL;
    }
    char* bytes = (char*)malloc(length);
    for (int i = 0; i < length; i++)
    {
        char c = fgetc(fp);
        bytes[i] = c;
    }
    
    fclose(fp);
    return bytes;
}

// Returns data with securely random bytes of the specified length. Uses /dev/random.
NSData* BTCRandomDataWithLength(NSUInteger length)
{
    void *bytes = BTCCreateRandomBytesOfLength(length);
    if (!bytes) return nil;
    return [[NSData alloc] initWithBytesNoCopy:bytes length:length];
}

// Returns data produced by flipping the coin as proposed by Dan Kaminsky:
// https://gist.github.com/PaulCapestany/6148566

static inline int BTCCoinFlip()
{
    __block int n = 0;
    //int c = 0;
    dispatch_time_t then = dispatch_time(DISPATCH_TIME_NOW, 999000ull);

    // We need to increase variance of number of flips, so we force system to schedule some threads
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (dispatch_time(DISPATCH_TIME_NOW, 0) <= then)
        {
            n = !n;
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (dispatch_time(DISPATCH_TIME_NOW, 0) <= then)
        {
            n = !n;
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (dispatch_time(DISPATCH_TIME_NOW, 0) <= then)
        {
            n = !n;
        }
    });

    while (dispatch_time(DISPATCH_TIME_NOW, 0) <= then)
    {
        //c++;
        n = !n; // flipping the coin
    }
    //NSLog(@"Flips: %d", c);
    return n;
}

// Simple Von Neumann debiasing - throwing away two flips that return the same value.
static inline int BTCFairCoinFlip()
{
    while(1)
    {
        int a = BTCCoinFlip();
        if (a != BTCCoinFlip())
        {
            return a;
        }
    }
}

NSData* BTCCoinFlipDataWithLength(NSUInteger length)
{
    NSMutableData* data = [NSMutableData dataWithLength:length];
    unsigned char* bytes = data.mutableBytes;
    for (int i = 0; i < length; i++)
    {
        unsigned char byte = 0;
        int bits = 8;
        while(bits--)
        {
            byte <<= 1;
            byte |= BTCFairCoinFlip();
        }
        bytes[i] = byte;
    }
    return data;
}


// Creates data with zero-terminated string in UTF-8 encoding.
NSData* BTCDataWithUTF8String(const char* utf8string)
{
    return [[NSData alloc] initWithBytes:utf8string length:strlen(utf8string)];
}

// Init with hex string (lower- or uppercase, with optional 0x prefix)
NSData* BTCDataWithHexString(NSString* hexString)
{
    return BTCDataWithHexCString([hexString cStringUsingEncoding:NSASCIIStringEncoding]);
}

// Init with zero-terminated hex string (lower- or uppercase, with optional 0x prefix)
NSData* BTCDataWithHexCString(const char* hexCString)
{
    if (hexCString == NULL) return nil;
    
    const unsigned char *psz = (const unsigned char*)hexCString;
    
    while (isspace(*psz)) psz++;
    
    // Skip optional 0x prefix
    if (psz[0] == '0' && tolower(psz[1]) == 'x') psz += 2;
        
        while (isspace(*psz)) psz++;
    
    size_t len = strlen((const char*)psz);
    
    // If the string is not full number of bytes (each byte 2 hex characters), return nil.
    if (len % 2 != 0) return nil;
    
    unsigned char* buf = (unsigned char*)malloc(len/2);
    
    static const signed char digits[256] = {
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
         0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,
        -1,0xa,0xb,0xc,0xd,0xe,0xf, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1,0xa,0xb,0xc,0xd,0xe,0xf, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
    };
    
    unsigned char* bufpointer = buf;
    
    while (1)
    {
        unsigned char c1 = (unsigned char)*psz++;
        signed char n1 = digits[c1];
        if (n1 == (signed char)-1) break; // break when null-terminator is hit
        
        unsigned char c2 = (unsigned char)*psz++;
        signed char n2 = digits[c2];
        if (n2 == (signed char)-1) break; // break when null-terminator is hit
        
        *bufpointer = (unsigned char)((n1 << 4) | n2);
        bufpointer++;
    }
    
    return [[NSData alloc] initWithBytesNoCopy:buf length:len/2];
}

NSData* BTCReversedData(NSData* data)
{
    return BTCReversedMutableData(data);
}

NSMutableData* BTCReversedMutableData(NSData* data)
{
    if (!data) return nil;
    NSMutableData* md = [NSMutableData dataWithData:data];
    BTCDataReverse(md);
    return md;
}

void BTCReverseBytesLength(void* bytes, NSUInteger length)
{
    // K&R
    if (length <= 1) return;
    unsigned char* buf = bytes;
    unsigned char byte;
    NSUInteger i, j;
    for (i = 0, j = length - 1; i < j; i++, j--)
    {
        byte = buf[i];
        buf[i] = buf[j];
        buf[j] = byte;
    }
}

// Reverses byte order in the internal buffer of mutable data object.
void BTCDataReverse(NSMutableData* self)
{
    BTCReverseBytesLength(self.mutableBytes, self.length);
}

// Clears contents of the data to prevent leaks through swapping or buffer-overflow attacks.
void BTCDataClear(NSMutableData* self)
{
    [self resetBytesInRange:NSMakeRange(0, self.length)];
}

NSData* BTCSHA1(NSData* data)
{
    if (!data) return nil;
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (CC_LONG)[data length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

NSData* BTCSHA256(NSData* data)
{
    if (!data) return nil;
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

NSData* BTCHash256(NSData* data)
{
    if (!data) return nil;
    unsigned char digest1[CC_SHA256_DIGEST_LENGTH];
    unsigned char digest2[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], digest1);
    CC_SHA256(digest1, CC_SHA256_DIGEST_LENGTH, digest2);
    return [NSData dataWithBytes:digest2 length:CC_SHA256_DIGEST_LENGTH];
}

#if BTCDataRequiresOpenSSL

NSData* BTCRIPEMD160(NSData* data)
{
    if (!data) return nil;
    unsigned char digest[RIPEMD160_DIGEST_LENGTH];
    RIPEMD160([data bytes], (size_t)[data length], digest);
    return [NSData dataWithBytes:digest length:RIPEMD160_DIGEST_LENGTH];
}

NSData* BTCHash160(NSData* data)
{
    if (!data) return nil;
    unsigned char digest1[CC_SHA256_DIGEST_LENGTH];
    unsigned char digest2[RIPEMD160_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], digest1);
    RIPEMD160(digest1, CC_SHA256_DIGEST_LENGTH, digest2);
    return [NSData dataWithBytes:digest2 length:RIPEMD160_DIGEST_LENGTH];
}

#endif



NSString* BTCHexStringFromDataWithFormat(NSData* data, const char* format)
{
    if (!data) return nil;
    
    NSUInteger length = data.length;
    if (length == 0) return @"";
    
    NSMutableData* resultdata = [NSMutableData dataWithLength:length * 2];
    char *dest = resultdata.mutableBytes;
    unsigned const char *src = data.bytes;
    for (int i = 0; i < length; ++i)
    {
        sprintf(dest + i*2, format, (unsigned int)(src[i]));
    }
    return [[NSString alloc] initWithData:resultdata encoding:NSASCIIStringEncoding];
}

NSString* BTCHexStringFromData(NSData* data)
{
    return BTCHexStringFromDataWithFormat(data, "%02x");
}

NSString* BTCUppercaseHexStringFromData(NSData* data)
{
    return BTCHexStringFromDataWithFormat(data, "%02X");
}



