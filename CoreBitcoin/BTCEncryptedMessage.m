// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCEncryptedMessage.h"
#import "BTCData.h"
#import "BTCKey.h"
#import "BTCCurvePoint.h"
#import "BTCBigNumber.h"
#import "BTCProtocolSerialization.h"
#import <CommonCrypto/CommonCrypto.h>

static uint8_t BTCEMCompactTargetForFullTarget(uint32_t fullTarget);
static uint32_t BTCEMFullTargetForCompactTarget(uint8_t compactTarget);

@implementation BTCEncryptedMessage {
    NSData* _decryptedData;
}

// Instantiates unencrypted message with its content
- (id) initWithData:(NSData*)data
{
    if (!data) return nil;
    
    if (self = [super init])
    {
        _difficultyTarget = 0xFF;
        _addressLength = BTCEncryptedMessageAddressLengthNone;
        _decryptedData = data;
    }
    return self;
}

- (NSData*) encryptedDataWithKey:(BTCKey*)recipientKey seed:(NSData*)seed
{
    if (!seed) seed = BTCRandomDataWithLength(32);
    
    self.address = BTCHash160(recipientKey.publicKey);
    self.addressLength = MIN(self.address.length * 8, self.addressLength);
    
    self.timestamp = (uint32_t)[[NSData data] timeIntervalSince1970];
    
    // Transform seed into a unique per-message seed.
    seed = BTCSHA256Concat(self.address, BTCSHA256Concat(_decryptedData, seed));
    
    if (self.timestampVariance > 0)
    {
        NSData* varianceHash = BTCSHA256(seed); // extra hashing to not leak our seed that we'll use for private key nonce.
        uint32_t rand = *((uint32_t*)varianceHash.bytes);
        self.timestamp -= (rand % self.timestampVariance);
    }
    
    uint32_t fullTarget = BTCEMFullTargetForCompactTarget(_difficultyTarget);
    
    NSMutableData* messageData = [[NSMutableData alloc] initWithCapacity:100 + _decryptedData.length];
    
    // NOTE: this code could be greately optimized to avoid re-creating message prefix.
    // Also, if time variance is > 0 we can try some random values there to avoid recomputing the private key.
    uint64_t nonce = 0;
    do {
        
        BTCDataClear(messageData); // clear previous trial
        
        [messageData setLength:0];
        
        [messageData appendBytes:BTCEncryptedMessageVersion length:4];
        
        [messageData appendBytes:&_difficultyTarget length:1];
        
        [messageData appendBytes:&_addressLength length:1];
        
        uint8_t partialByte = _addressLength % 8;
        
        [messageData appendBytes:self.address.bytes length:_addressLength / 8];
        
        if (partialByte > 0)
        {
            // Add one more byte, but mask lower bits with zeros. (We kinda treat address as a big endian number.)
            
            uint8_t lastByte = ((uint8_t*)self.address.bytes)[_addressLength/8] & (0xFF << (8 - partialByte));
            [messageData appendBytes:&lastByte length:1];
        }
        
        // Compute the private key
        
        unsigned char digest[CC_SHA256_DIGEST_LENGTH];
        
        CC_SHA256_CTX ctx;
        CC_SHA256_Init(&ctx);
        CC_SHA256_Update(&ctx, [seed bytes], (CC_LONG)[seed length]);
        CC_SHA256_Update(&ctx, &nonce, sizeof(nonce));
        CC_SHA256_Final(digest, &ctx);
        
        NSData* privkey = [NSData dataWithBytesNoCopy:digest length:CC_SHA256_DIGEST_LENGTH freeWhenDone:NO]; // not copying data as it'll be copied into bignum right away anyway.

        BTCKey* nonceKey = [[BTCKey alloc] initWithPrivateKey:privkey];
        
        NSData* pubkey = [nonceKey publicKeyCompressed:YES];
        
        uint8_t pubkeyLength = pubkey.length;
        
        [messageData appendBytes:&pubkeyLength length:1];
        
        [messageData appendData:pubkey];
        
        
        // Create a shared secret
        
        BTCBigNumber* pk = [[BTCBigNumber alloc] initWithUnsignedData:privkey];
        
        BTCCurvePoint* curvePoint = recipientKey.curvePoint;
        
        // D-H happens here. We multiply our private key (bignum) by a recipient's key (curve point).
        // Recipient will multiply his private key (bignum) by our pubkey that we attach in the previous step.
        [curvePoint multiply:pk];
        
        NSData* pointX = curvePoint.x.unsignedData;
        
        // Hash the x-coordinate for better diffusion.
        CC_SHA256_Init(&ctx);
        CC_SHA256_Update(&ctx, [pointX bytes], (CC_LONG)[pointX length]);
        CC_SHA256_Final(digest, &ctx);

        int blockSize = kCCBlockSizeAES128;
        int encryptedDataCapacity = (int)(_decryptedData.length / blockSize + 1) * blockSize;
        NSMutableData* encryptedData = [[NSMutableData alloc] initWithLength:encryptedDataCapacity];
        
        size_t dataOutMoved = 0;
        CCCryptorStatus cryptstatus = CCCrypt(
                                              kCCEncrypt,                  // CCOperation op,         /* kCCEncrypt, kCCDecrypt */
                                              kCCAlgorithmAES,             // CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
                                              kCCOptionPKCS7Padding,       // CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
                                              digest,                      // const void *key,
                                              CC_SHA256_DIGEST_LENGTH,     // size_t keyLength,
                                              NULL,                        // const void *iv,         /* optional initialization vector */
                                              [_decryptedData bytes],      // const void *dataIn,     /* optional per op and alg */
                                              [_decryptedData length],     // size_t dataInLength,
                                              encryptedData.mutableBytes,  // void *dataOut,          /* data RETURNED here */
                                              encryptedDataCapacity,       // size_t dataOutAvailable,
                                              &dataOutMoved                // size_t *dataOutMoved
                                              );
        
        if (cryptstatus != kCCSuccess)
        {
            BTCDataClear(encryptedData);
            encryptedData = nil;
        }
        else
        {
            // Resize the result key to the correct size.
            encryptedData.length = dataOutMoved;
        }
        
        // Clear sensitive info from memory.
        
        if ([pointX isKindOfClass:[NSMutableData class]])
        {
            BTCDataClear((NSMutableData*)pointX);
        }
        [pk clear];
        [curvePoint clear];
        BTCSecureMemset(digest, 0, CC_SHA256_DIGEST_LENGTH);
        
        if (!encryptedData)
        {
            return nil;
        }
        
        [messageData appendData:[BTCProtocolSerialization dataForVarString:encryptedData]];
        
        NSData* messageHash = BTCHash256(messageData);
        
        uint32_t prefix = OSSwapBigToHostConstInt32(*((uint32_t*)[messageHash bytes]));
        
        if (prefix <= fullTarget)
        {
            [messageData appendData:[messageHash subdataWithRange:NSMakeRange(32-8, 8)]];
            return messageData;
        }
        
    } while (1);
}



// Instantiates encrypted message with binary frame. Checks version, checksum and if difficulty matches the actual proof of work.
// To decrypt the message, use -decryptedContentsForKey:
- (id) initWithEncryptedData:(NSData*)data
{
    // TODO.
    return nil;
}

// Attempts to decrypt the message with a given private key and returns result.
- (NSData*) decryptedDataWithKey:(BTCKey*)key
{
    // TODO.
    return nil;
}



// Returns 1-byte representation of a target not higher than a given one.
// Maximum difficulty is the minimum target and vice versa.
+ (uint8_t) compactTargetForTarget:(uint32_t)target
{
    return BTCEMCompactTargetForFullTarget(target);
}


// Returns a full 32-bit target from its compact representation.
+ (uint32_t) targetForCompactTarget:(uint8_t)compactTarget
{
    return BTCEMFullTargetForCompactTarget(compactTarget);
}



@end


static uint8_t BTCEMCompactTargetForFullTarget(uint32_t fullTarget)
{
    // Simply find the highest target that is not greater than a given one.
    for (uint8_t ct = 0xFF; ct >= 0; --ct)
    {
        if (BTCEMFullTargetForCompactTarget(ct) <= fullTarget)
        {
            return ct;
        }
    }
    return 0;
}

static uint32_t BTCEMFullTargetForCompactTarget(uint8_t compactTarget)
{
    // 8 bits: a b c d e f g h
    // a,b,c,d,e (higher bits) are used to determine the order (2^(0..31))
    // f,g,h are following the order bit. The rest are 1's till the lowest bit.
    
    uint32_t order = compactTarget >> 3;
    uint32_t tail = compactTarget & (1 + 2 + 4);
    
    // TODO: instead throwing out order when it's too small, consider throwing off tail and respecting order.
    if (order < 3) return tail;
    
    uint32_t fullTarget = (2 << order) +
                          (tail << (order - 3)) +  // move the tail behind the highest bit
                          ((2 << (order - 3)) - 1); // fill the rest after the tail with 1111...
    
    return fullTarget;
}



