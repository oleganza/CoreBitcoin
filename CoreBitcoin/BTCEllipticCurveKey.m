// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey.h"
#import "BTCData.h"
#import "BTCAddress.h"
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>

#define BTCCompressedPubkeyLength   (33)
#define BTCUncompressedPubkeyLength (65)

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

@interface BTCEllipticCurveKey ()
@end

@implementation BTCEllipticCurveKey {
    EC_KEY* _key;
    NSMutableData* _publicKey;
    BOOL _compressedPublicKey;
}

- (void) dealloc
{
    [self clear];
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
        if (![self isValidPubKey:publicKey]) return nil;
        [self setPublicKey:publicKey];
    }
    return self;
}

- (id) initWithDERPrivateKey:(NSData*)DERPrivateKey
{
    if (self = [super init])
    {
        [self setDERPrivateKey:DERPrivateKey];
    }
    return self;
}

- (id) initWithPrivateKey:(NSData*)privateKey
{
    if (self = [super init])
    {
        [self setPrivateKey:privateKey];
    }
    return self;
}

// Verifies signature for a given hash with a public key.
- (BOOL) isValidSignature:(NSData*)signature hash:(NSData*)hash
{
    if (hash.length == 0 || signature.length == 0) return NO;
    
    // -1 = error, 0 = bad sig, 1 = good
    if (ECDSA_verify(0, (unsigned char*)hash.bytes,      (int)hash.length,
                        (unsigned char*)signature.bytes, (int)signature.length,
                        _key) != 1)
    {
        return NO;
    }
    
    return YES;
}

// Returns a signature data for a 256-bit hash using private key.
- (NSData*)signatureForHash:(NSData*)hash
{
    unsigned int sigSize = ECDSA_size(_key);
    NSMutableData* signature = [NSMutableData dataWithLength:sigSize];
    
    if (!ECDSA_sign(0, (unsigned char*)hash.bytes, (int)hash.length, signature.mutableBytes, &sigSize, _key))
    {
        BTCDataClear(signature);
        return nil;
    }
    [signature setLength:sigSize];
    
    return signature;
}

- (NSMutableData*) publicKey
{
    return [[self publicKeyCached] mutableCopy];
}

- (NSData*) publicKeyCached
{
    if (!_publicKey)
    {
        if (!_key) return nil;
        
        // TODO: produce a compressed pubkey if needed.
        
        int length = i2o_ECPublicKey(_key, NULL);
        if (!length) return nil;
        NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
        unsigned char* bytes = [data mutableBytes];
        if (i2o_ECPublicKey(_key, &bytes) != length) return nil;
        _publicKey = data;
    }
    return _publicKey;
}

- (NSMutableData*) DERPrivateKey
{
    if (!_key) return nil;
    int length = i2d_ECPrivateKey(_key, NULL);
    if (!length) return nil;
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2d_ECPrivateKey(_key, &bytes) != length) return nil;
    return data;
}

- (NSMutableData*) privateKey
{
    const BIGNUM *bignum = EC_KEY_get0_private_key(_key);
    if (!bignum) return nil;
    int num_bytes = BN_num_bytes(bignum);
    NSMutableData* data = [[NSMutableData alloc] initWithLength:32];
    int copied_bytes = BN_bn2bin(bignum, &data.mutableBytes[32 - num_bytes]);
    if (copied_bytes != num_bytes) return nil;
    return data;
}

- (void) setPublicKey:(NSData *)publicKey
{
    if (publicKey.length == 0) return;
    _publicKey = [publicKey mutableCopy];
    
    _compressedPublicKey = ([self lengthOfPubKey:_publicKey] == BTCCompressedPubkeyLength);
    
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = publicKey.bytes;
    if (!o2i_ECPublicKey(&_key, &bytes, publicKey.length)) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                                                                            reason:@"o2i_ECPublicKey failed. " userInfo:nil];
}

- (void) setDERPrivateKey:(NSData *)DERPrivateKey
{
    if (!DERPrivateKey) return;
    
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = DERPrivateKey.bytes;
    if (!d2i_ECPrivateKey(&_key, &bytes, DERPrivateKey.length)) @throw [NSException exceptionWithName:@"BTCEllipticCurveKey Exception"
                                                                                              reason:@"d2i_ECPrivateKey failed. " userInfo:nil];
}

- (void) setPrivateKey:(NSData *)privateKey
{
    if (!privateKey) return;
    
    [self prepareKeyIfNeeded];

    if (!_key) return;
    
    BIGNUM *bignum = BN_bin2bn(privateKey.bytes, (int)privateKey.length, BN_new());
    
    if (!bignum) return;
    
    BTCRegenerateKey(_key, bignum);
    BN_clear_free(bignum);
}

- (BOOL) isCompressedPublicKey
{
    return _compressedPublicKey;
}

- (void) setCompressedPublicKey:(BOOL)flag
{
    _publicKey = nil;
    _compressedPublicKey = flag;
}

- (void) clear
{
    BTCDataClear(_publicKey);
    _publicKey = nil;
    
    // I couldn't find how to clear sensitive key data in OpenSSL,
    // so I just replace existing key with a new one.
    // Correct me if I'm doing it wrong.
    [self generateKeyPair];
    
    if (_key) EC_KEY_free(_key);
    _key = NULL;
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

- (BOOL) isEqual:(BTCEllipticCurveKey*)otherKey
{
    if (![otherKey isKindOfClass:[self class]]) return NO;
    return [self.publicKeyCached isEqual:otherKey.publicKeyCached];
}

- (NSUInteger) hash
{
    return [self.publicKeyCached hash];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<BTCEllipticCurveKey:0x%p %@>", self, BTCHexStringFromData(self.publicKeyCached)];
}

- (NSString*) debugDescription
{
    return [NSString stringWithFormat:@"<BTCEllipticCurveKey:0x%p pubkey:%@ privkey:%@>", self, BTCHexStringFromData(self.publicKeyCached), BTCHexStringFromData(self.privateKey)];
}



- (NSUInteger) lengthOfPubKey:(NSData*)data
{
    if (data.length == 0) return 0;
    
    unsigned char header = ((const unsigned char*)data.bytes)[0];
    if (header == 2 || header == 3)
        return BTCCompressedPubkeyLength;
    if (header == 4 || header == 6 || header == 7)
        return BTCUncompressedPubkeyLength;
    return 0;
}

- (BOOL) isValidPubKey:(NSData*)data
{
    NSUInteger length = data.length;
    return length > 0 && [self lengthOfPubKey:data] == length;
}


@end




@implementation BTCEllipticCurveKey (BTCAddress)

- (id) initWithPrivateKeyAddress:(BTCPrivateKeyAddress*)privateKeyAddress
{
    if (self = [self initWithNewKeyPair:NO])
    {
        [self setPrivateKey:privateKeyAddress.data];
        [self setCompressedPublicKey:privateKeyAddress.compressedPublicKey];
    }
    return self;
}

- (BTCPublicKeyAddress*) publicKeyAddress
{
    NSData* pubkey = [self publicKeyCached];
    if (pubkey.length == 0) return nil;
    return [BTCPublicKeyAddress addressWithData:BTCHash160(pubkey)];
}

- (BTCPrivateKeyAddress*) privateKeyAddress
{
    NSMutableData* privkey = [self privateKey];
    if (privkey.length == 0) return nil;
    
    BTCPrivateKeyAddress* result = [BTCPrivateKeyAddress addressWithData:privkey compressedPublicKey:[self isCompressedPublicKey]];
    BTCDataClear(privkey);
    return result;
}

@end







