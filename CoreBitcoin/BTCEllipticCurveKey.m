// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey.h"
#import "NSData+BTC.h"
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>

int BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key)
{
    BN_CTX *ctx = NULL;
    EC_POINT *pub_key = NULL;
    
    if (!eckey) return 0;
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
   
    BOOL success = NO;
    if ((ctx = BN_CTX_new()))
    {
        if ((pub_key = EC_POINT_new(group)))
        {
            if (EC_POINT_mul(group, pub_key, priv_key, NULL, NULL, ctx))
            {
                EC_KEY_set_private_key(eckey, priv_key);
                EC_KEY_set_public_key(eckey, pub_key);
                success = YES;
            }
        }
    }
    
    if (pub_key) EC_POINT_free(pub_key);
    if (ctx) BN_CTX_free(ctx);
    
    return success;
}

@implementation BTCEllipticCurveKey {
    EC_KEY* _key;
}

- (void) dealloc
{
    [self clear];
    if (_key) EC_KEY_free(_key);
}

- (id) initWithNewKeyPair:(BOOL)createKeyPair
{
    if (self = [super init])
    {
        if (createKeyPair) [self generateKeyPair];
    }
    return self;
}

- (id) init
{
    return [self initWithNewKeyPair:YES];
}

- (id) initWithPublicKey:(NSData*)publicKey
{
    if (self = [super init])
    {
        self.publicKey = publicKey;
    }
    return self;
}

- (id) initWithPrivateKey:(NSData*)privateKey
{
    if (self = [super init])
    {
        self.privateKey = privateKey;
    }
    return self;
}

- (id) initWithSecretKey:(NSData*)secretKey
{
    if (self = [super init])
    {
        self.secretKey = secretKey;
    }
    return self;
}

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash
{
    // -1 = error, 0 = bad sig, 1 = good
    if (ECDSA_verify(0, (unsigned char*)hash.bytes,      (int)hash.length,
                        (unsigned char*)signature.bytes, (int)signature.length,
                        _key) != 1)
    {
        return NO;
    }
    
    return true;
}

// Returns a signature data for a 256-bit hash using private key.
- (NSData*)signatureForHash:(NSData*)hash
{
    unsigned int sigSize = ECDSA_size(_key);
    NSMutableData* signature = [NSMutableData dataWithLength:sigSize];
    
    if (!ECDSA_sign(0, (unsigned char*)hash.bytes, (int)hash.length, signature.mutableBytes, &sigSize, _key))
    {
        [signature clear];
        return nil;
    }
    [signature setLength:sigSize];
    
    return signature;
}

- (NSData*) publicKey
{
    if (!_key) return nil;
    int length = i2o_ECPublicKey(_key, NULL);
    if (!length) return nil;
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(_key, &bytes) != length) return nil;
    return data;
}

- (NSData*) privateKey
{
    if (!_key) return nil;
    int length = i2d_ECPrivateKey(_key, NULL);
    if (!length) return nil;
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2d_ECPrivateKey(_key, &bytes) != length) return nil;
    return data;
}

- (NSData*) secretKey
{
    const BIGNUM *bignum = EC_KEY_get0_private_key(_key);
    int num_bytes = BN_num_bytes(bignum);
    if (!bignum) return nil;
    NSMutableData* data = [[NSMutableData alloc] initWithLength:32];
    int copied_bytes = BN_bn2bin(bignum, &data.mutableBytes[32 - num_bytes]);
    if (copied_bytes != num_bytes) return nil;
    return data;
}

- (void) setPublicKey:(NSData *)publicKey
{
    if (!publicKey) return;
    
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = [publicKey bytes];
    if (!o2i_ECPublicKey(&_key, &bytes, [publicKey length])) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                                                                            reason:@"o2i_ECPublicKey failed. " userInfo:nil];
}

- (void) setPrivateKey:(NSData *)privateKey
{
    if (!privateKey) return;
    
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = [privateKey bytes];
    if (!d2i_ECPrivateKey(&_key, &bytes, [privateKey length])) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                                                                              reason:@"d2i_ECPrivateKey failed. " userInfo:nil];
}

- (void) setSecretKey:(NSData *)secretKey
{
    if (!secretKey) return;
    
    [self prepareKeyIfNeeded];

    if (!_key) return;
    
    BIGNUM *bignum = BN_bin2bn(secretKey.bytes, (int)secretKey.length, BN_new());
    
    if (!bignum) return;
    
    BTCRegenerateKey(_key, bignum);
    BN_clear_free(bignum);
}

- (void) clear
{
    // I couldn't find how to clear sensitive key data in OpenSSL,
    // so I just replace existing key with a new one.
    // Correct me if I'm doing it wrong.
    [self generateKeyPair];
}


- (void) generateKeyPair
{
    [self prepareKeyIfNeeded];
    if (!EC_KEY_generate_key(_key)) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                                                   reason:@"EC_KEY_generate_key failed. " userInfo:nil];
}

- (void) prepareKeyIfNeeded
{
    if (_key) return;
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    if (!_key) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                              reason:@"EC_KEY_new_by_curve_name failed. " userInfo:nil];
}




#pragma mark - NSObject



- (id) copy
{
    BTCEllipticCurveKey* newKey = [[BTCEllipticCurveKey alloc] initWithNewKeyPair:NO];
    if (_key) newKey->_key = EC_KEY_dup(_key);
    return newKey;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<BTCEllipticCurveKey:0x%p>", self];
}



@end
