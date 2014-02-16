// Oleg Andreev <oleganza@gmail.com>

#import "BTCKeychain.h"
#import "BTCData.h"
#import "BTCKey.h"
#import "BTCCurvePoint.h"
#import "BTCBigNumber.h"
#import "BTCBase58.h"

#define BTCKeychainPrivateExtendedKeyVersion 0x0488ADE4
#define BTCKeychainPublicExtendedKeyVersion  0x0488B21E

@interface BTCKeychain ()
@property(nonatomic, readwrite) NSData* chainCode;
@property(nonatomic, readwrite) NSData* extendedPublicKey;
@property(nonatomic, readwrite) NSData* extendedPrivateKey;
@property(nonatomic, readwrite) NSData* identifier;
@property(nonatomic, readwrite) uint32_t fingerprint;
@property(nonatomic, readwrite) uint32_t parentFingerprint;
@property(nonatomic, readwrite) uint32_t index;
@property(nonatomic, readwrite) uint8_t depth;
@property(nonatomic, readwrite) BOOL hardened;

@property(nonatomic) NSData* privateKey;
@property(nonatomic) NSData* publicKey;
@end

@implementation BTCKeychain {
    NSData* _chainCode;
}

- (id) initWithSeed:(NSData*)seed
{
    if (self = [super init])
    {
        if (!seed) return nil;
        
        NSData* hmac = BTCHMACSHA512([@"Bitcoin seed" dataUsingEncoding:NSASCIIStringEncoding], seed);
        _privateKey = [hmac subdataWithRange:NSMakeRange(0, 32)];
        _chainCode  = [hmac subdataWithRange:NSMakeRange(32, 32)];
    }
    return self;
}

- (id) initWithExtendedKey:(NSData*)extendedKey
{
    if (self = [super init])
    {
        if (extendedKey.length != 78) return nil;

        const uint8_t* bytes = extendedKey.bytes;
        uint32_t version = OSSwapBigToHostInt32(*((uint32_t*)bytes));

        uint32_t keyprefix = bytes[45];
        
        if (version == BTCKeychainPrivateExtendedKeyVersion)
        {
            // Should have 0-prefixed private key (1 + 32 bytes).
            if (keyprefix != 0) return nil;
            _privateKey = [extendedKey subdataWithRange:NSMakeRange(46, 32)];
        }
        else
        {
            // Should have a 33-byte public key with non-zero first byte.
            if (keyprefix == 0) return nil;
            _publicKey = [extendedKey subdataWithRange:NSMakeRange(45, 33)];
        }

        _depth = *(bytes + 4);
        _parentFingerprint = OSSwapBigToHostInt32(*((uint32_t*)(bytes + 5)));
        _index = OSSwapBigToHostInt32(*((uint32_t*)(bytes + 9)));
        
        if ((0x80000000 & _index) != 0)
        {
            _index = (~0x80000000) & _index;
            _hardened = YES;
        }
        
        _chainCode = [extendedKey subdataWithRange:NSMakeRange(13, 32)];
    }
    return self;
}


#pragma mark - Properties


- (BTCKey*) rootKey
{
    if (_privateKey)
    {
        BTCKey* key = [[BTCKey alloc] initWithPrivateKey:_privateKey];
        key.compressedPublicKey = YES;
        return key;
    }
    else
    {
        return [[BTCKey alloc] initWithPublicKey:self.publicKey];
    }
}

- (NSData*) extendedPrivateKey
{
    if (!_privateKey) return nil;
    
    if (!_extendedPrivateKey)
    {
        NSMutableData* data = [self extendedKeyPrefixWithVersion:BTCKeychainPrivateExtendedKeyVersion];
        
        uint8_t padding = 0;
        [data appendBytes:&padding length:1];
        [data appendData:_privateKey];
        
        _extendedPrivateKey = data;
    }
    return _extendedPrivateKey;
}

- (NSData*) extendedPublicKey
{
    if (!_extendedPublicKey)
    {
        NSData* pubkey = self.publicKey;
        
        if (!pubkey) return nil;
        
        NSMutableData* data = [self extendedKeyPrefixWithVersion:BTCKeychainPublicExtendedKeyVersion];
        
        [data appendData:pubkey];
        
        _extendedPublicKey = data;
    }
    return _extendedPublicKey;
}

- (NSMutableData*) extendedKeyPrefixWithVersion:(uint32_t)version
{
    NSMutableData* data = [NSMutableData data];
    
    version = OSSwapHostToBigInt32(version);
    [data appendBytes:&version length:sizeof(version)];
    
    [data appendBytes:&_depth length:1];
    
    uint32_t parentfp = OSSwapHostToBigInt32(_parentFingerprint);
    [data appendBytes:&parentfp length:sizeof(parentfp)];
    
    uint32_t childindex = OSSwapHostToBigInt32(_hardened ? (0x80000000 | _index) : _index);
    [data appendBytes:&childindex length:sizeof(childindex)];
    
    [data appendData:_chainCode];
    
    return data;
}

- (NSData*) identifier
{
    if (!_identifier)
    {
        _identifier = BTCHash160(self.publicKey);
    }
    return _identifier;
}

- (uint32_t) fingerprint
{
    if (_fingerprint == 0)
    {
        const uint32_t* bytes = self.identifier.bytes;
        _fingerprint = OSSwapBigToHostInt32(bytes[0]);
    }
    return _fingerprint;
}

- (NSData*) publicKey
{
    if (!_publicKey)
    {
        _publicKey = [[[BTCKey alloc] initWithPrivateKey:_privateKey] publicKeyCompressed:YES];
    }
    return _publicKey;
}

- (BOOL) isPrivate
{
    return !!_privateKey;
}

- (BOOL) isHardened
{
    return _hardened;
}

- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index
{
    return [self derivedKeychainAtIndex:index hardened:NO];
}

- (BTCKeychain*) derivedKeychainAtIndex:(uint32_t)index hardened:(BOOL)hardened
{
    // As we use explicit parameter "hardened", do not allow higher bit set.
    if ((0x80000000 & index) != 0)
    {
        @throw [NSException exceptionWithName:@"BTCKeychain Exception"
                                       reason:@"Indexes >= 0x80000000 are invalid. Use hardened:YES argument instead." userInfo:nil];
        return nil;
    }
    
    if (!_privateKey && hardened)
    {
        // Not possible to derive hardened keychain without a private key.
        return nil;
    }

    BTCKeychain* derivedKeychain = [[BTCKeychain alloc] init];

    NSMutableData* data = [NSMutableData data];
    
    if (hardened)
    {
        uint8_t padding = 0;
        [data appendBytes:&padding length:1];
        [data appendData:_privateKey];
    }
    else
    {
        [data appendData:self.publicKey];
    }
    
    uint32_t indexBE = OSSwapHostToBigInt32(hardened ? (0x80000000 | index) : index);
    [data appendBytes:&indexBE length:sizeof(indexBE)];
    
    NSData* digest = BTCHMACSHA512(_chainCode, data);
    
    BTCBigNumber* factor = [[BTCBigNumber alloc] initWithUnsignedData:[digest subdataWithRange:NSMakeRange(0, 32)]];
    
    // Factor is too big, this derivation is invalid.
    if ([factor greaterOrEqual:[BTCCurvePoint curveOrder]])
    {
        return nil;
    }
    
    derivedKeychain.chainCode = [digest subdataWithRange:NSMakeRange(32, 32)];
    
    if (_privateKey)
    {
        BTCMutableBigNumber* pkNumber = [[BTCMutableBigNumber alloc] initWithUnsignedData:_privateKey];
        [pkNumber add:factor mod:[BTCCurvePoint curveOrder]];
        
        // Check for invalid derivation.
        if ([pkNumber isEqual:[BTCBigNumber zero]]) return nil;
        
        derivedKeychain.privateKey = pkNumber.unsignedData;
    }
    else
    {
        BTCCurvePoint* point = [[BTCCurvePoint alloc] initWithData:_publicKey];
        [point addGeneratorMultipliedBy:factor];
        
        // Check for invalid derivation.
        if ([point isInfinity]) return nil;
        
        derivedKeychain.publicKey = point.data;
    }
    
    derivedKeychain.depth = _depth + 1;
    derivedKeychain.parentFingerprint = self.fingerprint;
    derivedKeychain.index = index;
    derivedKeychain.hardened = hardened;
    
    return derivedKeychain;
}

- (BTCKey*) keyAtIndex:(uint32_t)index
{
    return [self keyAtIndex:index hardened:NO];
}
- (BTCKey*) keyAtIndex:(uint32_t)index hardened:(BOOL)hardened
{
    return [[self derivedKeychainAtIndex:index hardened:NO] rootKey];
}

- (BTCKeychain*) publicKeychain
{
    BTCKeychain* keychain = [[BTCKeychain alloc] init];
    
    keychain.chainCode = self.chainCode;
    keychain.publicKey = self.publicKey;
    keychain.parentFingerprint = self.parentFingerprint;
    keychain.index = self.index;
    keychain.depth = self.depth;
    keychain.hardened = self.hardened;
    
    return keychain;
}



#pragma mark - NSObject


- (id) copyWithZone:(NSZone *)zone
{
    BTCKeychain* keychain = [[BTCKeychain alloc] init];
    
    keychain.chainCode = self.chainCode;
    keychain.privateKey = self.privateKey;
    if (!_privateKey) keychain.publicKey = self.publicKey;
    keychain.parentFingerprint = self.parentFingerprint;
    keychain.index = self.index;
    keychain.depth = self.depth;
    keychain.hardened = self.hardened;
    
    return keychain;
}

- (BOOL) isEqual:(BTCKeychain*)other
{
    if (self == other) return YES;
    
    if (self.isPrivate != other.isPrivate) return NO;
    if (self.fingerprint != other.fingerprint) return NO;
    if (self.parentFingerprint != other.parentFingerprint) return NO;
    if (self.index != other.index) return NO;
    if (self.hardened != other.hardened) return NO;
    
    if (self.isPrivate)
    {
        if (![self.privateKey isEqual:other.privateKey]) return NO;
    }
    else
    {
        if (![self.publicKey isEqual:other.publicKey]) return NO;
    }
    
    if (![self.chainCode isEqual:other.chainCode]) return NO;
    
    return YES;
}

- (NSUInteger) hash
{
    return self.fingerprint;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@:0x%p %@>", [self class], self, BTCBase58CheckStringWithData(self.extendedPublicKey)];
}

- (NSString*) debugDescription
{
    return [NSString stringWithFormat:@"<%@:0x%p depth:%d index:%x%@ parentFingerprint:%x fingerprint:%x privkey:%@ pubkey:%@ chainCode:%@>", [self class], self,
            (int)_depth,
            _index,
            _hardened ? @" hardened:YES" : @"",
            _parentFingerprint,
            self.fingerprint,
            [BTCHexStringFromData(self.privateKey) substringToIndex:8],
            [BTCHexStringFromData(self.publicKey) substringToIndex:8],
            [BTCHexStringFromData(self.chainCode) substringToIndex:8]
            ];
}



@end


