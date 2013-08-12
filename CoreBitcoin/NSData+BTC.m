// Oleg Andreev <oleganza@gmail.com>

#import "NSData+BTC.h"
#import <CommonCrypto/CommonCrypto.h>
#include <openssl/ripemd.h>

// This is designed to be not optimized out by compiler like memset
void *BTCSecureMemset(void *v, int c, size_t n)
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

void *NSData_BTCRandomData(size_t length)
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


@implementation NSData (BTC)

- (id) initRandomWithLength:(NSUInteger)length
{
    void *bytes = NSData_BTCRandomData(length);
    if (!bytes) return nil;
    return [self initWithBytesNoCopy:bytes length:length];
}

- (id) initWithUTF8String:(const char*)utf8string
{
    return [self initWithBytes:utf8string length:strlen(utf8string)];
}

- (id) initWithHexString:(NSString*)hexString
{
    return [self initWithHexCString:[hexString cStringUsingEncoding:NSASCIIStringEncoding]];
}

- (id) initWithHexCString:(const char *)hexCString
{
    if (!hexCString) return [self init];

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
    
    return [self initWithBytesNoCopy:buf length:len/2];
}

- (NSData*) reversedData
{
    return [self reversedMutableData];
}

- (NSMutableData*) reversedMutableData
{
    NSMutableData* md = [self mutableCopy];
    [md reverse];
    return md;
}

+ (NSMutableData*) encryptData:(NSData*)data key:(NSData*)key
{
    return [self cryptData:data key:key iv:nil operation:kCCEncrypt];
}

+ (NSMutableData*) decryptData:(NSData*)data key:(NSData*)key
{
    return [self cryptData:data key:key iv:nil operation:kCCDecrypt];
}

+ (NSMutableData*) encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector
{
    return [self cryptData:data key:key iv:initializationVector operation:kCCEncrypt];
}

+ (NSMutableData*) decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector
{
    return [self cryptData:data key:key iv:initializationVector operation:kCCDecrypt];
}


+ (NSMutableData*) cryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv operation:(CCOperation)operation
{
    if (!data || !key) return nil;
    
    int blockSize = kCCBlockSizeAES128;
    int encryptedDataCapacity = (int)(data.length / blockSize + 1) * blockSize;
    NSMutableData* encryptedData = [[NSMutableData alloc] initWithLength:encryptedDataCapacity];
    
    // Treat empty IV as nil
    if (iv.length == 0)
    {
        iv = nil;
    }
    
    // If IV is supplied, validate it.
    if (iv)
    {
        if (iv.length == blockSize)
        {
            // perfect.
        }
        else if (iv.length > blockSize)
        {
            // IV is bigger than the block size. CCCrypt will take only the first 16 bytes.
        }
        else
        {
            // IV is smaller than needed. This should not happen. It's better to crash than to leak something.
            @throw [NSException exceptionWithName:@"NSData+BTC IV is invalid"
                                           reason:[NSString stringWithFormat:@"Invalid size of IV: %d", (int)iv.length]
                                         userInfo:nil];
        }
    }
    
    size_t dataOutMoved = 0;
    CCCryptorStatus cryptstatus = CCCrypt(
      operation,                   // CCOperation op,         /* kCCEncrypt, kCCDecrypt */
      kCCAlgorithmAES128,          // CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
      kCCOptionPKCS7Padding,       // CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
      key.bytes,                   // const void *key,
      key.length,                  // size_t keyLength,
      iv ? iv.bytes : NULL,        // const void *iv,         /* optional initialization vector */
      data.bytes,                  // const void *dataIn,     /* optional per op and alg */
      data.length,                 // size_t dataInLength,
      encryptedData.mutableBytes,  // void *dataOut,          /* data RETURNED here */
      encryptedData.length,        // size_t dataOutAvailable,
      &dataOutMoved                // size_t *dataOutMoved
    );
    
    if (cryptstatus == kCCSuccess)
    {
        // Resize the result key to the correct size.
        encryptedData.length = dataOutMoved;
        return encryptedData;
    }
    else
    {
        //kCCSuccess          = 0,
        //kCCParamError       = -4300,
        //kCCBufferTooSmall   = -4301,
        //kCCMemoryFailure    = -4302,
        //kCCAlignmentError   = -4303,
        //kCCDecodeError      = -4304,
        //kCCUnimplemented    = -4305,
        //kCCOverflow         = -4306
        @throw [NSException exceptionWithName:@"NSData+BTC CCCrypt failed"
                                       reason:[NSString stringWithFormat:@"error: %d", cryptstatus] userInfo:nil];
        return nil;
    }
}

- (NSData*) SHA256
{
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData*) doubleSHA256
{
    unsigned char digest1[CC_SHA256_DIGEST_LENGTH];
    unsigned char digest2[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest1);
    CC_SHA256(digest1, CC_SHA256_DIGEST_LENGTH, digest2);
    return [NSData dataWithBytes:digest2 length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData*) SHA256RIPEMD160
{
    unsigned char digest1[CC_SHA256_DIGEST_LENGTH];
    unsigned char digest2[RIPEMD160_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest1);
    RIPEMD160(digest1, CC_SHA256_DIGEST_LENGTH, digest2);
    return [NSData dataWithBytes:digest2 length:RIPEMD160_DIGEST_LENGTH];
}

- (NSData*) RIPEMD160
{
    unsigned char digest[RIPEMD160_DIGEST_LENGTH];
    RIPEMD160([self bytes], (size_t)[self length], digest);
    return [NSData dataWithBytes:digest length:RIPEMD160_DIGEST_LENGTH];
}

- (NSString*) hexString
{
    return [self hexStringWithFormat:"%02x"];
}

- (NSString*) hexUppercaseString
{
    return [self hexStringWithFormat:"%02X"];
}

- (NSString*) hexStringWithFormat:(const char*)format
{
    if (self.length == 0) return @"";
    
    NSUInteger length = self.length;
    NSMutableData* data = [NSMutableData dataWithLength:length * 2];
    char *dest = data.mutableBytes;
    unsigned const char *src = self.bytes;
    for (int i = 0; i < length; ++i)
    {
        sprintf(dest + i*2, format, (unsigned int)(src[i]));
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


+ (void) reverseBytes:(void*)bytes length:(NSUInteger)length
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

@end



@implementation NSMutableData (BTC)

- (void) reverse
{
    [NSData reverseBytes:self.mutableBytes length:self.length];
}

- (void) clear
{
    [self resetBytesInRange:NSMakeRange(0, self.length)];
}

@end
