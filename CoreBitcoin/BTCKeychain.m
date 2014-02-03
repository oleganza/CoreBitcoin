// Oleg Andreev <oleganza@gmail.com>

#import "BTCKeychain.h"
#import "BTCData.h"
#import "BTCKey.h"
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
        
#warning TODO: read extended key
    }
    return self;
}


#pragma mark - Properties


- (BTCKey*) key
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
    
    uint32_t childindex = OSSwapHostToBigInt32(_index);
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

// Returns a derived keychain. If index is >= 0x80000000, uses private derivation (possible only when private key is present; otherwise returns nil).
- (BTCKeychain*) childKeychainAtIndex:(uint32_t)index
{
    #warning TODO: derive the child keychain
    
}

// Returns a key from a derived keychain. This is a convenient way to access [... chuldKeychainAtIndex:i].key
// If the receiver contains private key, child key will also contain a private key.
// If the receiver contains only public key, child key will only contain public key (nil is returned if index >= 0x80000000).
- (BTCKey*) childKeyAtIndex:(uint32_t)index
{
    return [[self childKeychainAtIndex:index] key];
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
    
    return keychain;
}

- (BOOL) isEqual:(BTCKeychain*)other
{
    if (self == other) return YES;
    
    if (self.isPrivate != other.isPrivate) return NO;
    if (self.fingerprint != other.fingerprint) return NO;
    if (self.parentFingerprint != other.parentFingerprint) return NO;
    if (self.index != other.index) return NO;
    
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



@end


