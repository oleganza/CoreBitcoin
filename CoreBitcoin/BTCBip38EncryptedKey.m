//
//  BTCBip38EncryptedKey.m
//  CoreBitcoin
//
//  Created by Alex Zak on 16/11/2015.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

#import "BTCBip38EncryptedKey.h"

#import "BTCBase58.h"
#import "BTCData.h"
#import "BTCAddress.h"
#import <CommonCrypto/CommonCrypto.h>

#import <openssl/ec.h>
#import <openssl/evp.h>
#import <openssl/bn.h>


// adapted from: https://github.com/voisine/breadwallet/blob/master/BreadWallet/BRKey%2BBIP38.m

#define rotl(a, b) (((a) << (b)) | ((a) >> (32 - (b))))

// encoding (39 bytes)
// header (7 bytes) = prefix (2) + flags (1) + addressHash (4)
//
// non-EC = encryptedHalf1 (16) + encryptedHalf2 (16)
// EC     = ownerEntropy + encrypted1[0...7] + encrypted2

const NSUInteger                BTCBip38EncryptedKeyLength                = 39;
const NSUInteger                BTCBip38EncryptedKeyHeaderLength          = 7;

const NSUInteger                BTCBip38EncryptedKeyPrefixNonEC           = 0x0142;
const NSUInteger                BTCBip38EncryptedKeyPrefixEC              = 0x0143;

const NSUInteger                BTCBip38EncryptedKeyFlagsNonEC            = 0x80 | 0x40;
const NSUInteger                BTCBip38EncryptedKeyFlagsCompressed       = 0x20;
const NSUInteger                BTCBip38EncryptedKeyFlagsLotSequence      = 0x04;
const NSUInteger                BTCBip38EncryptedKeyFlagsInvalid          = 0x10 | 0x08 | 0x02 | 0x01;

static const NSUInteger         BTCBip38EncryptedKeySecretLength          = 32;
static const int64_t            BTCBip38EncryptedKeyScryptN               = 16384;    // 0x4000
static const uint32_t           BTCBip38EncryptedKeyScryptR               = 8;
static const uint32_t           BTCBip38EncryptedKeyScryptP               = 8;
static const int64_t            BTCBip38EncryptedKeyScryptECN             = 1024;     // 0x400
static const uint32_t           BTCBip38EncryptedKeyScryptECR             = 1;
static const uint32_t           BTCBip38EncryptedKeyScryptECP             = 1;
static const NSUInteger         BTCBip38EncryptedKeyScryptLength          = 64;

static void salsa20_8(uint32_t b[16]);
static void blockmix_salsa8(uint64_t *dest, const uint64_t *src, uint64_t *b, uint32_t r);
static NSData *scrypt(NSData *password, NSData *salt, int64_t n, uint32_t r, uint32_t p, NSUInteger length);
static NSData *normalize_passphrase(NSString *passphrase);
static void derive_passfactor(BIGNUM *passfactor, uint8_t flag, uint64_t entropy, NSString *passphrase);
static NSData *derive_key(NSData *passpoint, uint32_t addresshash, uint64_t entropy);
static NSData *point_multiply(NSData *point, const BIGNUM *factor, BOOL compressed, BN_CTX *ctx);




@interface BTCBip38EncryptedKey ()
@property (nonatomic, copy) NSData *encryptedData;
@end


@class BTCPublicKeyAddress;
@class BTCAddress;
@implementation BTCBip38EncryptedKey

- (instancetype)initWithEncrypted:(NSString *)encrypted {
	
	if (!encrypted) return nil;
	NSData *encryptedData = BTCDataFromBase58Check(encrypted);
	if (encryptedData.length != BTCBip38EncryptedKeyLength) return nil;
	
	const uint16_t prefix = CFSwapInt16BigToHost(*(const uint16_t *)encryptedData.bytes);
	
	if ((prefix != BTCBip38EncryptedKeyPrefixNonEC) && (prefix != BTCBip38EncryptedKeyPrefixEC)) return nil;
	
	
	if ((self = [super init])) {
		self.encryptedData = encryptedData;
	}
	return self;
}

- (instancetype)initWithKey:(BTCKey *)key passphrase:(NSString *)passphrase {
	
	if (!key) return nil;
	if (!passphrase) return nil;
	
	NSMutableData* encryptedData = [[NSMutableData alloc] initWithLength:0];
	
	const uint16_t prefix = CFSwapInt16HostToBig(BTCBip38EncryptedKeyPrefixNonEC);
	uint8_t flags = BTCBip38EncryptedKeyFlagsNonEC;
	
	NSData *password = normalize_passphrase(passphrase);
		
	[[key address] data];
	NSData *addressData = [[[key address] string] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *salt = [BTCHash256(addressData) subdataWithRange:NSMakeRange(0, 4)];
	
	NSData *derivedData = scrypt(password, salt, BTCBip38EncryptedKeyScryptN, BTCBip38EncryptedKeyScryptR, BTCBip38EncryptedKeyScryptP, BTCBip38EncryptedKeyScryptLength);
	const uint64_t *derivedBytes1 = (const uint64_t *)derivedData.bytes;
	const uint64_t *derivedBytes2 = &derivedBytes1[4];
	
	//
	// encryptedData1 = AES256Encrypt(secret[ 0...15] xor derivedData1[ 0...15], derivedData2)
	// encryptedData2 = AES256Encrypt(secret[16...31] xor derivedData1[16...31], derivedData2)
	//
	
	NSMutableData *secret = [[NSMutableData alloc] initWithLength:BTCBip38EncryptedKeySecretLength];
	for (size_t i = 0; i < secret.length / sizeof(uint64_t); ++i) {
		((uint64_t *)secret.mutableBytes)[i] = ((const uint64_t *)(const uint8_t *)key.privateKey.bytes)[i] ^ derivedBytes1[i];
	}
	
	const NSUInteger secretLength = BTCBip38EncryptedKeySecretLength;
	const NSUInteger halfSecretLength = BTCBip38EncryptedKeySecretLength / 2;
	size_t moved;
	
	NSMutableData *encryptedHalf1 = [[NSMutableData alloc] initWithLength:halfSecretLength];
	NSMutableData *encryptedHalf2 = [[NSMutableData alloc] initWithLength:halfSecretLength];
	
	CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
			secret.bytes, halfSecretLength, encryptedHalf1.mutableBytes, halfSecretLength, &moved);
	
	CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
			(const uint8_t *)secret.bytes + halfSecretLength, halfSecretLength, encryptedHalf2.mutableBytes, halfSecretLength, &moved);
	
	if ([key isPublicKeyCompressed]) {
		flags |= BTCBip38EncryptedKeyFlagsCompressed;
	}
	
	[encryptedData appendBytes:&prefix length:sizeof(prefix)];
	[encryptedData appendBytes:&flags length:sizeof(flags)];
	[encryptedData appendData:salt];
	[encryptedData appendData:encryptedHalf1];
	[encryptedData appendData:encryptedHalf2];
	
	
	if ((self = [super init])) {
		self.encryptedData = encryptedData;
	}
	return self;
}




- (NSString *)encrypted {
	
	return BTCBase58CheckStringWithData(self.encryptedData);
}

- (uint16_t)prefix {
	
	return CFSwapInt16BigToHost(*(const uint16_t *)self.encryptedData.bytes);
}

- (uint8_t)flags {
	
	return ((const uint8_t *)self.encryptedData.bytes)[2];
}

- (uint32_t)addressHash {
	
	return *(const uint32_t *)((const uint8_t *)self.encryptedData.bytes + 3);
}

- (BOOL)isEC {
	
	return (self.prefix == BTCBip38EncryptedKeyPrefixEC);
}

- (BOOL)isCompressed {
	
	return (self.flags & BTCBip38EncryptedKeyFlagsCompressed) == BTCBip38EncryptedKeyFlagsCompressed;
}

- (NSString *)description {
	
	return self.encrypted;
}






- (BTCKey *)decryptedKeyWithPassphrase:(NSString *)passphrase
{
	const uint8_t flags = self.flags;
	const uint32_t addressHash = self.addressHash;
	NSData *salt = [NSData dataWithBytesNoCopy:(void *)&addressHash length:sizeof(addressHash) freeWhenDone:NO];
	
	NSMutableData *secret = [[NSMutableData alloc] initWithLength:BTCBip38EncryptedKeySecretLength];
	
	if (![self isEC]) {
		NSData *password = normalize_passphrase(passphrase);
		
		NSData *derivedData = scrypt(password, salt, BTCBip38EncryptedKeyScryptN, BTCBip38EncryptedKeyScryptR, BTCBip38EncryptedKeyScryptP, BTCBip38EncryptedKeyScryptLength);
		const uint64_t *derivedBytes1 = (const uint64_t *)derivedData.bytes;
		const uint64_t *derivedBytes2 = &((const uint64_t *)derivedData.bytes)[4];
		
		const NSUInteger secretLength = BTCBip38EncryptedKeySecretLength;
		const NSUInteger halfSecretLength = BTCBip38EncryptedKeySecretLength / 2;
		size_t moved;
		
		const uint8_t *encryptedHalf1 = (const uint8_t *)self.encryptedData.bytes + BTCBip38EncryptedKeyHeaderLength;
		const uint8_t *encryptedHalf2 = (const uint8_t *)self.encryptedData.bytes + BTCBip38EncryptedKeyHeaderLength + halfSecretLength;
		
		CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
				encryptedHalf1, halfSecretLength, secret.mutableBytes, halfSecretLength, &moved);
		
		CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
				encryptedHalf2, halfSecretLength, (uint8_t *)secret.mutableBytes + halfSecretLength, halfSecretLength, &moved);
		
		for (size_t i = 0; i < secret.length / sizeof(uint64_t); ++i) {
			((uint64_t *)secret.mutableBytes)[i] ^= derivedBytes1[i];
		}
	}
	else {
		BN_CTX *ctx = BN_CTX_new();
		BN_CTX_start(ctx);
		
		const uint64_t entropy = *(const uint64_t *)((const uint8_t *)self.encryptedData.bytes + BTCBip38EncryptedKeyHeaderLength);
		const NSUInteger secretLength = BTCBip38EncryptedKeySecretLength;
		const NSUInteger halfSecretLength = BTCBip38EncryptedKeySecretLength / 2;
		
		NSMutableData *encryptedData1 = [[NSMutableData alloc] init];
		[encryptedData1 appendBytes:(const uint8_t *)self.encryptedData.bytes + 15 length:8];
		encryptedData1.length = halfSecretLength;
		
		const uint8_t *encryptedBytes2 = (const uint8_t *)self.encryptedData.bytes + BTCBip38EncryptedKeyHeaderLength + halfSecretLength;
		
		BIGNUM *passfactor = BN_CTX_get(ctx);
		BIGNUM *factorb = BN_CTX_get(ctx);
		BIGNUM *priv = BN_CTX_get(ctx);
		BIGNUM *order = BN_CTX_get(ctx);
		
		derive_passfactor(passfactor, flags, entropy, passphrase);
		
		// passpoint = G * passfactor
		NSData *passpoint = point_multiply(nil, passfactor, YES, ctx);
		NSData *derivedData = derive_key(passpoint, addressHash, entropy);
		const uint64_t *derivedBytes1 = (const uint64_t *)derivedData.bytes;
		const uint64_t *derivedBytes2 = &derivedBytes1[4];
		
		NSMutableData *seedb = [[NSMutableData alloc] initWithLength:24];
		NSMutableData *o = [[NSMutableData alloc] initWithLength:16];
		EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
		
		size_t moved;
		
		// o = (encrypted1[8...15] + seedb[16...23]) xor derivedBytes1[16...31]
		
		CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
				encryptedBytes2, 16, o.mutableBytes, o.length, &moved);
		
		((uint64_t *)encryptedData1.mutableBytes)[1] = ((const uint64_t *)o.bytes)[0] ^ derivedBytes1[2];
		((uint64_t *)seedb.mutableBytes)[2] = ((const uint64_t *)o.bytes)[1] ^ derivedBytes1[3];
		
		// o = seedb[0...15] xor derivedBytes1[0...15]
		
		CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode, derivedBytes2, secretLength, NULL,
				encryptedData1.bytes, encryptedData1.length, o.mutableBytes, o.length, &moved);
		
		((uint64_t *)seedb.mutableBytes)[0] = ((const uint64_t *)o.bytes)[0] ^ derivedBytes1[0];
		((uint64_t *)seedb.mutableBytes)[1] = ((const uint64_t *)o.bytes)[1] ^ derivedBytes1[1];
		
		EC_GROUP_get_order(group, order, ctx);
		
		// factorb = SHA256(SHA256(seedb))
		BN_bin2bn(BTCHash256(seedb).bytes, CC_SHA256_DIGEST_LENGTH, factorb);
		
		// secret = passfactor*factorb mod N
		BN_mod_mul(priv, passfactor, factorb, order, ctx);
		
		BN_bn2bin(priv, (unsigned char *)secret.mutableBytes + secret.length - BN_num_bytes(priv));
		
		EC_GROUP_free(group);
		BN_CTX_end(ctx);
		BN_CTX_free(ctx);
	}
	
	
	BTCKey *key = [[BTCKey alloc] initWithPrivateKey:secret];
	[key setPublicKeyCompressed:[self isCompressed]];
	
	NSData *decryptedAddressData = [[[key address] string] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *decryptedSalt = [BTCHash256(decryptedAddressData) subdataWithRange:NSMakeRange(0, 4)];
	
	if (![decryptedSalt isEqualToData:salt]) {
		return nil;
	}
	
	return key;
}




@end













// salsa20/8 stream cypher: http://cr.yp.to/snuffle.html
static void salsa20_8(uint32_t b[16])
{
	uint32_t x00 = b[0], x01 = b[1], x02 = b[2], x03 = b[3], x04 = b[4], x05 = b[5], x06 = b[6], x07 = b[7],
	x08 = b[8], x09 = b[9], x10 = b[10], x11 = b[11], x12 = b[12], x13 = b[13], x14 = b[14], x15 = b[15];
	
	for (int i = 0; i < 8; i += 2) {
		// operate on columns
		x04 ^= rotl(x00 + x12, 7), x08 ^= rotl(x04 + x00, 9), x12 ^= rotl(x08 + x04, 13), x00 ^= rotl(x12 + x08, 18);
		x09 ^= rotl(x05 + x01, 7), x13 ^= rotl(x09 + x05, 9), x01 ^= rotl(x13 + x09, 13), x05 ^= rotl(x01 + x13, 18);
		x14 ^= rotl(x10 + x06, 7), x02 ^= rotl(x14 + x10, 9), x06 ^= rotl(x02 + x14, 13), x10 ^= rotl(x06 + x02, 18);
		x03 ^= rotl(x15 + x11, 7), x07 ^= rotl(x03 + x15, 9), x11 ^= rotl(x07 + x03, 13), x15 ^= rotl(x11 + x07, 18);
		
		// operate on rows
		x01 ^= rotl(x00 + x03, 7), x02 ^= rotl(x01 + x00, 9), x03 ^= rotl(x02 + x01, 13), x00 ^= rotl(x03 + x02, 18);
		x06 ^= rotl(x05 + x04, 7), x07 ^= rotl(x06 + x05, 9), x04 ^= rotl(x07 + x06, 13), x05 ^= rotl(x04 + x07, 18);
		x11 ^= rotl(x10 + x09, 7), x08 ^= rotl(x11 + x10, 9), x09 ^= rotl(x08 + x11, 13), x10 ^= rotl(x09 + x08, 18);
		x12 ^= rotl(x15 + x14, 7), x13 ^= rotl(x12 + x15, 9), x14 ^= rotl(x13 + x12, 13), x15 ^= rotl(x14 + x13, 18);
	}
	
	b[0] += x00, b[1] += x01, b[2] += x02, b[3] += x03, b[4] += x04, b[5] += x05, b[6] += x06, b[7] += x07;
	b[8] += x08, b[9] += x09, b[10] += x10, b[11] += x11, b[12] += x12, b[13] += x13, b[14] += x14, b[15] += x15;
}

static void blockmix_salsa8(uint64_t *dest, const uint64_t *src, uint64_t *b, uint32_t r)
{
	memcpy(b, &src[(2*r - 1)*8], 64);
	
	for (uint32_t i = 0; i < 2*r; i += 2) {
		for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i*8 + j];
		salsa20_8((uint32_t *)b);
		memcpy(&dest[i*4], b, 64);
		for (uint32_t j = 0; j < 8; j++) b[j] ^= src[i*8 + 8 + j];
		salsa20_8((uint32_t *)b);
		memcpy(&dest[i*4 + r*8], b, 64);
	}
}

// scrypt key derivation: http://www.tarsnap.com/scrypt.html
static NSData *scrypt(NSData *password, NSData *salt, int64_t n, uint32_t r, uint32_t p, NSUInteger length)
{
	NSMutableData *d = [[NSMutableData alloc] initWithLength:length];
	uint8_t b[128*r*p];
	uint64_t x[16*r], y[16*r], z[8], *v = malloc(128*r*(int)n), m;
	
	CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, 1,
						 b, sizeof(b));
	
	for (uint32_t i = 0; i < p; i++) {
		for (uint32_t j = 0; j < 32*r; j++) {
			((uint32_t *)x)[j] = CFSwapInt32LittleToHost(*(uint32_t *)&b[i*128*r + j*4]);
		}
		
		for (uint64_t j = 0; j < n; j += 2) {
			memcpy(&v[j*(16*r)], x, 128*r);
			blockmix_salsa8(y, x, z, r);
			memcpy(&v[(j + 1)*(16*r)], y, 128*r);
			blockmix_salsa8(x, y, z, r);
		}
		
		for (uint64_t j = 0; j < n; j += 2) {
			m = CFSwapInt64LittleToHost(x[(2*r - 1)*8]) & (n - 1);
			for (uint32_t k = 0; k < 16*r; k++) x[k] ^= v[m*(16*r) + k];
			blockmix_salsa8(y, x, z, r);
			m = CFSwapInt64LittleToHost(y[(2*r - 1)*8]) & (n - 1);
			for (uint32_t k = 0; k < 16*r; k++) y[k] ^= v[m*(16*r) + k];
			blockmix_salsa8(x, y, z, r);
		}
		
		for (uint32_t j = 0; j < 32*r; j++) {
			*(uint32_t *)&b[i*128*r + j*4] = CFSwapInt32HostToLittle(((uint32_t *)x)[j]);
		}
	}
	
	CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, b, sizeof(b), kCCPRFHmacAlgSHA256, 1,
						 d.mutableBytes, d.length);
	
	bzero(b, sizeof(b));
	bzero(x, sizeof(x));
	bzero(y, sizeof(y));
	bzero(z, sizeof(z));
	bzero(v, 128*r*(int)n);
	//    CC_XFREE(v, 128*r*(int)n);
	free(v);
	bzero(&m, sizeof(m));
	return d;
}

static NSData *normalize_passphrase(NSString *passphrase)
{
	NSData *password;
	CFMutableStringRef pw = CFStringCreateMutableCopy(NULL, passphrase.length, (CFStringRef)passphrase);
	
	CFStringNormalize(pw, kCFStringNormalizationFormC);
	password = CFBridgingRelease(CFStringCreateExternalRepresentation(NULL, pw, kCFStringEncodingUTF8, 0));
	CFRelease(pw);
	return password;
}

static void derive_passfactor(BIGNUM *passfactor, uint8_t flags, uint64_t entropy, NSString *passphrase)
{
	NSData *password = normalize_passphrase(passphrase);
	NSData *salt = [NSData dataWithBytesNoCopy:&entropy length:(flags & BTCBip38EncryptedKeyFlagsLotSequence) ? 4 : 8 freeWhenDone:NO];
	NSData *prefactor = scrypt(password, salt, BTCBip38EncryptedKeyScryptN, BTCBip38EncryptedKeyScryptR, BTCBip38EncryptedKeyScryptP, 32);
	NSMutableData *d;
	
	if (flags & BTCBip38EncryptedKeyFlagsLotSequence) { // passfactor = SHA256(SHA256(prefactor + entropy))
		d = [[NSMutableData alloc] initWithData:prefactor];
		[d appendBytes:&entropy length:sizeof(entropy)];
		BN_bin2bn(BTCHash256(d).bytes, CC_SHA256_DIGEST_LENGTH, passfactor);
	}
	else {
		BN_bin2bn(prefactor.bytes, (int)prefactor.length, passfactor); // passfactor = prefactor
	}
}

static NSData *derive_key(NSData *passpoint, uint32_t addresshash, uint64_t entropy)
{
	NSMutableData *salt = [[NSMutableData alloc] init];
	
	[salt appendBytes:&addresshash length:sizeof(addresshash)];
	[salt appendBytes:&entropy length:sizeof(entropy)]; // salt = addresshash + entropy
	
	return scrypt(passpoint, salt, BTCBip38EncryptedKeyScryptECN, BTCBip38EncryptedKeyScryptECR, BTCBip38EncryptedKeyScryptECP, 64);
}

static NSData *point_multiply(NSData *point, const BIGNUM *factor, BOOL compressed, BN_CTX *ctx)
{
	NSMutableData *d = [[NSMutableData alloc] init];
	EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
	EC_POINT *r = EC_POINT_new(group), *p;
	point_conversion_form_t form = compressed ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED;
	
	if (point) {
		p = EC_POINT_new(group);
		EC_POINT_oct2point(group, p, point.bytes, point.length, ctx);
		EC_POINT_mul(group, r, NULL, p, factor, ctx); // r = point*factor
		EC_POINT_clear_free(p);
	}
	else EC_POINT_mul(group, r, factor, NULL, NULL, ctx); // r = G*factor
	
	d.length = EC_POINT_point2oct(group, r, form, NULL, 0, ctx);
	EC_POINT_point2oct(group, r, form, d.mutableBytes, d.length, ctx);
	EC_POINT_clear_free(r);
	EC_GROUP_free(group);
	return d;
}




@implementation BTCKey (bip38)

- (BTCBip38EncryptedKey *)encryptedBIP38KeyWithPassphrase:(NSString *)passphrase {
	
	return [[BTCBip38EncryptedKey alloc] initWithKey:self passphrase:passphrase];
}

@end
