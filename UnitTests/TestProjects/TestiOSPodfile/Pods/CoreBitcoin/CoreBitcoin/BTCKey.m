// Oleg Andreev <oleganza@gmail.com>

#import "BTCKey.h"
#import "BTCData.h"
#import "BTCAddress.h"
#import "BTCCurvePoint.h"
#import "BTCProtocolSerialization.h"
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>
#include <openssl/bn.h>
#include <openssl/rand.h>

#define BTCCompressedPubkeyLength   (33)
#define BTCUncompressedPubkeyLength (65)

static BOOL    BTCCheckPrivateKeyRange(const unsigned char *secret);
static int     BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key);
static NSData* BTCSignatureHashForBinaryMessage(NSData* data);
static int     ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check);

@interface BTCKey ()
@end

@implementation BTCKey {
    EC_KEY* _key;
    NSMutableData* _publicKey;
    BOOL _compressedPublicKey;
}

- (id) initWithNewKeyPair:(BOOL)createKeyPair
{
    if (self = [super init])
    {
        [self prepareKeyIfNeeded];
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

- (id) initWithCurvePoint:(BTCCurvePoint*)curvePoint
{
    if (self = [super init])
    {
        if (!curvePoint) return nil;
        [self prepareKeyIfNeeded];
        EC_KEY_set_public_key(_key, curvePoint.EC_POINT);
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
    ECDSA_SIG *sig = ECDSA_do_sign((unsigned char*)hash.bytes, (int)hash.length, _key);
    if (sig == NULL)
    {
        return nil;
    }
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    const EC_GROUP *group = EC_KEY_get0_group(_key);
    BIGNUM *order = BN_CTX_get(ctx);
    BIGNUM *halforder = BN_CTX_get(ctx);
    EC_GROUP_get_order(group, order, ctx);
    BN_rshift1(halforder, order);
    if (BN_cmp(sig->s, halforder) > 0)
    {
        // enforce low S values, by negating the value (modulo the order) if above order/2.
        BN_sub(sig->s, order, sig->s);
    }
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    unsigned int sigSize = ECDSA_size(_key);
    
    NSMutableData* signature = [NSMutableData dataWithLength:sigSize + 16]; // Make sure it is big enough
    
    unsigned char *pos = (unsigned char *)signature.mutableBytes;
    sigSize = i2d_ECDSA_SIG(sig, &pos);
    ECDSA_SIG_free(sig);
    [signature setLength:sigSize];  // Shrink to fit actual size
    
    return signature;
    
//    unsigned int sigSize = ECDSA_size(_key);
//    NSMutableData* signature = [NSMutableData dataWithLength:sigSize];
//    
//    if (!ECDSA_sign(0, (unsigned char*)hash.bytes, (int)hash.length, signature.mutableBytes, &sigSize, _key))
//    {
//        BTCDataClear(signature);
//        return nil;
//    }
//    [signature setLength:sigSize];
//    
//    return signature;
}

- (NSMutableData*) publicKey
{
    return [NSMutableData dataWithData:[self publicKeyCached]];
}

- (NSData*) publicKeyCached
{
    if (!_publicKey)
    {
        _publicKey = [self publicKeyCompressed:_compressedPublicKey];
    }
    return _publicKey;
}

- (NSMutableData*) publicKeyCompressed:(BOOL)compressed
{
    if (!_key) return nil;
    EC_KEY_set_conv_form(_key, compressed ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED);
    int length = i2o_ECPublicKey(_key, NULL);
    if (!length) return nil;
    NSAssert(length <= 65, @"Pubkey length must be up to 65 bytes.");
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(_key, &bytes) != length) return nil;
    return data;
}

- (BTCCurvePoint*) curvePoint
{
    const EC_POINT* ecpoint = EC_KEY_get0_public_key(_key);
    BTCCurvePoint* cp = [[BTCCurvePoint alloc] initWithEC_POINT:ecpoint];
    return cp;
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
    _publicKey = [NSMutableData dataWithData:publicKey];
    
    _compressedPublicKey = ([self lengthOfPubKey:_publicKey] == BTCCompressedPubkeyLength);
    
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = publicKey.bytes;
    if (!o2i_ECPublicKey(&_key, &bytes, publicKey.length)) @throw [NSException exceptionWithName:@"BTCKey Exception"
                                                                                            reason:@"o2i_ECPublicKey failed. " userInfo:nil];
}

- (void) setDERPrivateKey:(NSData *)DERPrivateKey
{
    if (!DERPrivateKey) return;
    
    BTCDataClear(_publicKey); _publicKey = nil;
    [self prepareKeyIfNeeded];
    
    const unsigned char* bytes = DERPrivateKey.bytes;
    if (!d2i_ECPrivateKey(&_key, &bytes, DERPrivateKey.length)) @throw [NSException exceptionWithName:@"BTCKey Exception"
                                                                                              reason:@"d2i_ECPrivateKey failed. " userInfo:nil];
}

- (void) setPrivateKey:(NSData *)privateKey
{
    if (!privateKey) return;
    
    BTCDataClear(_publicKey); _publicKey = nil;
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
    NSMutableData* secret = [NSMutableData dataWithLength:32];
    unsigned char* bytes = secret.mutableBytes;
    do {
        RAND_bytes(bytes, 32);
    } while (!BTCCheckPrivateKeyRange(bytes));
    [self setPrivateKey:secret];
    BTCDataClear(secret);
}

- (void) prepareKeyIfNeeded
{
    if (_key) return;
    _key = EC_KEY_new_by_curve_name(NID_secp256k1);
    if (!_key) @throw [NSException exceptionWithName:@"BTCKey Exception"
                                              reason:@"EC_KEY_new_by_curve_name failed. " userInfo:nil];
}




#pragma mark - NSObject



- (id) copy
{
    BTCKey* newKey = [[BTCKey alloc] initWithNewKeyPair:NO];
    if (_key) newKey->_key = EC_KEY_dup(_key);
    return newKey;
}

- (BOOL) isEqual:(BTCKey*)otherKey
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
    return [NSString stringWithFormat:@"<BTCKey:0x%p %@>", self, BTCHexStringFromData(self.publicKeyCached)];
}

- (NSString*) debugDescription
{
    return [NSString stringWithFormat:@"<BTCKey:0x%p pubkey:%@ privkey:%@>", self, BTCHexStringFromData(self.publicKeyCached), BTCHexStringFromData(self.privateKey)];
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





#pragma mark - BTCAddress Import/Export




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







#pragma mark - Compact Signature






// Returns a compact signature for 256-bit hash. Aka "CKey::SignCompact" in BitcoinQT.
// Initially used for signing text messages.
//
// The format is one header byte, followed by two times 32 bytes for the serialized r and s values.
// The header byte: 0x1B = first key with even y, 0x1C = first key with odd y,
//                  0x1D = second key with even y, 0x1E = second key with odd y,
//                  add 0x04 for compressed keys.
- (NSData*) compactSignatureForHash:(NSData*)hash
{
    NSMutableData* sigdata = [NSMutableData dataWithLength:65];
    unsigned char* sigbytes = sigdata.mutableBytes;
    const unsigned char* hashbytes = hash.bytes;
    int hashlength = (int)hash.length;
    
    int rec = -1;
    
    unsigned char *p64 = (sigbytes + 1); // first byte is reserved for header.
    
    ECDSA_SIG *sig = ECDSA_do_sign(hashbytes, hashlength, _key);
    if (sig==NULL)
    {
        return nil;
    }
    memset(p64, 0, 64);
    int nBitsR = BN_num_bits(sig->r);
    int nBitsS = BN_num_bits(sig->s);
    if (nBitsR <= 256 && nBitsS <= 256)
    {
        NSData* pubkey = [self publicKeyCompressed:YES];
        BOOL foundMatchingPubkey = NO;
        for (int i=0; i < 4; i++)
        {
            // It will be updated via direct access to _key ivar.
            BTCKey* key2 = [[BTCKey alloc] initWithNewKeyPair:NO];
            if (ECDSA_SIG_recover_key_GFp(key2->_key, sig, hashbytes, hashlength, i, 1) == 1)
            {
                NSData* pubkey2 = [key2 publicKeyCompressed:YES];
                if ([pubkey isEqual:pubkey2])
                {
                    rec = i;
                    foundMatchingPubkey = YES;
                    break;
                }
            }
        }
        NSAssert(foundMatchingPubkey, @"At least one signature must work.");
        BN_bn2bin(sig->r,&p64[32-(nBitsR+7)/8]);
        BN_bn2bin(sig->s,&p64[64-(nBitsS+7)/8]);
    }
    ECDSA_SIG_free(sig);
    
    // First byte is a header
    sigbytes[0] = 0x1b + rec + (self.isCompressedPublicKey ? 4 : 0);
    return sigdata;
}

// Verifies digest against given compact signature. On success returns a public key.
// Reconstruct public key from a compact signature
// This is only slightly more CPU intensive than just verifying it.
// If this function succeeds, the recovered public key is guaranteed to be valid
// (the signature is a valid signature of the given data for that key).
+ (BTCKey*) verifyCompactSignature:(NSData*)compactSignature forHash:(NSData*)hash
{
    if (compactSignature.length != 65) return nil;
    
    const unsigned char* sigbytes = compactSignature.bytes;
    BOOL compressedPubKey = (sigbytes[0] - 0x1b) & 4;
    int rec = (sigbytes[0] - 0x1b) & ~4;
    const unsigned char* p64 = sigbytes + 1;
    
    // It will be updated via direct access to _key ivar.
    BTCKey* key = [[BTCKey alloc] initWithNewKeyPair:NO];
    key.compressedPublicKey = compressedPubKey;
    
    if (rec<0 || rec>=3)
    {
        // Invalid variant of a pubkey.
        return nil;
    }
    ECDSA_SIG *sig = ECDSA_SIG_new();
    BN_bin2bn(&p64[0],  32, sig->r);
    BN_bin2bn(&p64[32], 32, sig->s);
    BOOL result = (1 == ECDSA_SIG_recover_key_GFp(key->_key, sig, (unsigned char*)hash.bytes, (int)hash.length, rec, 0));
    ECDSA_SIG_free(sig);
    
    // Failed to recover a pubkey.
    if (!result) return nil;
    
    return key;
}

// Verifies signature of the hash with its public key.
- (BOOL) isValidCompactSignature:(NSData*)signature forHash:(NSData*)hash
{
    BTCKey* key = [[self class] verifyCompactSignature:signature forHash:hash];
    return [key isEqual:self];
}















#pragma mark - Bitcoin Signed Message





// Returns a signature for a message prepended with "Bitcoin Signed Message:\n" line.
- (NSData*) signatureForMessage:(NSString*)message
{
    return [self signatureForBinaryMessage:[message dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSData*) signatureForBinaryMessage:(NSData*)data
{
    if (!data) return nil;
    return [self compactSignatureForHash:BTCSignatureHashForBinaryMessage(data)];
}

// Verifies message against given signature. On success returns a public key.
+ (BTCKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message
{
    return [self verifySignature:signature forBinaryMessage:[message dataUsingEncoding:NSASCIIStringEncoding]];
}

+ (BTCKey*) verifySignature:(NSData*)signature forBinaryMessage:(NSData *)data
{
    if (!signature || !data) return nil;
    return [self verifyCompactSignature:signature forHash:BTCSignatureHashForBinaryMessage(data)];
}

- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message
{
    return [self isValidSignature:signature forBinaryMessage:[message dataUsingEncoding:NSASCIIStringEncoding]];
}

- (BOOL) isValidSignature:(NSData*)signature forBinaryMessage:(NSData *)data
{
    BTCKey* key = [[self class] verifySignature:signature forBinaryMessage:data];
    return [key isEqual:self];
}



@end



static BOOL BTCCheckPrivateKeyRange(const unsigned char *secret)
{
    // Do not convert to OpenSSL's data structures for range-checking keys,
    // it's easy enough to do directly.
    static const unsigned char maxPrivateKey[32] = {
        0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE,
        0xBA,0xAE,0xDC,0xE6,0xAF,0x48,0xA0,0x3B,0xBF,0xD2,0x5E,0x8C,0xD0,0x36,0x41,0x40
    };
    BOOL isZero = YES;
    for (int i = 0; i < 32 && isZero; i++)
    {
        if (secret[i] != 0)
        {
            isZero = NO;
        }
    }
    if (isZero) return NO;
    
    for (int i = 0; i < 32; i++)
    {
        if (secret[i] < maxPrivateKey[i]) return YES;
        if (secret[i] > maxPrivateKey[i]) return NO;
    }
    return YES;
}


static NSData* BTCSignatureHashForBinaryMessage(NSData* msg)
{
    NSMutableData* data = [NSMutableData data];
    [data appendData:[BTCProtocolSerialization dataForVarString:[@"Bitcoin Signed Message:\n" dataUsingEncoding:NSASCIIStringEncoding]]];
    [data appendData:[BTCProtocolSerialization dataForVarString:msg ?: [NSData data]]];
    return BTCHash256(data);
}



static int BTCRegenerateKey(EC_KEY *eckey, BIGNUM *priv_key)
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





// Perform ECDSA key recovery (see SEC1 4.1.6) for curves over (mod p)-fields
// recid selects which key is recovered
// if check is non-zero, additional checks are performed
static int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check)
{
    if (!eckey) return 0;
    
    int ret = 0;
    BN_CTX *ctx = NULL;
    
    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    int n = 0;
    int i = recid / 2;
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, ecsig->r)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check)
    {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
    if (!BN_zero(zero)) { ret=-1; goto err; }
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, ecsig->r, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, ecsig->s, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }
    
    ret = 1;
    
err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    return ret;
}


