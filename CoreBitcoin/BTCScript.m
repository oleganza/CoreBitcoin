// Oleg Andreev <oleganza@gmail.com>

#import "BTCScript.h"
#import "BTCAddress.h"
#import "BTCBigNumber.h"
#import "BTCErrors.h"

@interface BTCScript ()
@end

@implementation BTCScript {
    // An array of NSData objects (pushing data) and NSNumber objects (with opcodes)
    NSArray* _chunks;
    
    // Cached serialized representations for -data and -string methods.
    NSData* _data;
    NSString* _string;
    
    // Multisignature script attributes.
    // If multisig script is not detected, both are NULL.
    NSUInteger _multisigSignaturesRequired;
    NSArray* _multisigPublicKeys;
}

- (id) init
{
    if (self = [super init])
    {
        _chunks = @[];
    }
    return self;
}

- (id) initWithData:(NSData*)data
{
    if (self = [super init])
    {
        _chunks = [self parseData:data ?: [NSData data]];
    }
    return self;
}

- (id) initWithString:(NSString*)string
{
    if (self = [super init])
    {
        _chunks = [self parseString:string ?: @""];
    }
    return self;
}

- (id) initWithAddress:(BTCAddress*)address
{
    if ([address isKindOfClass:[BTCPublicKeyAddress class]])
    {
        // OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG
        NSMutableData* data = [NSMutableData data];
        
        BTCOpcode prefix[] = {OP_DUP, OP_HASH160};
        [data appendBytes:prefix length:sizeof(prefix)];
        
        unsigned char length = data.length;
        [data appendBytes:&length length:sizeof(length)];
        
        [data appendData:address.data];
        
        BTCOpcode suffix[] = {OP_EQUALVERIFY, OP_CHECKSIG};
        [data appendBytes:suffix length:sizeof(suffix)];
        
        return [self initWithData:data];
    }
    else if ([address isKindOfClass:[BTCScriptHashAddress class]])
    {
        // OP_HASH160 <hash> OP_EQUAL
        NSMutableData* data = [NSMutableData data];
        
        BTCOpcode prefix[] = {OP_HASH160};
        [data appendBytes:prefix length:sizeof(prefix)];
        
        unsigned char length = data.length;
        [data appendBytes:&length length:sizeof(length)];
        
        [data appendData:address.data];
        
        BTCOpcode suffix[] = {OP_EQUAL};
        [data appendBytes:suffix length:sizeof(suffix)];
        
        return [self initWithData:data];
    }
    else
    {
        return nil;
    }
}

// OP_<M> <pubkey1> ... <pubkeyN> OP_<N> OP_CHECKMULTISIG
- (id) initWithPublicKeys:(NSArray*)publicKeys signaturesRequired:(NSUInteger)signaturesRequired
{
    // First make sure the arguments make sense.
    
    // We need at least one signature
    if (signaturesRequired == 0) return nil;
    
    // And we cannot have more signatures than available pubkeys.
    if (signaturesRequired > publicKeys.count) return nil;
    
    // Both M and N should map to OP_<1..16>
    BTCOpcode m_opcode = BTCOpcodeForSmallInteger(signaturesRequired);
    BTCOpcode n_opcode = BTCOpcodeForSmallInteger(publicKeys.count);
    if (m_opcode == OP_INVALIDOPCODE) return nil;
    if (n_opcode == OP_INVALIDOPCODE) return nil;
    
    // Every pubkey should be present.
    for (NSData* pkdata in publicKeys)
    {
        if (![pkdata isKindOfClass:[NSData class]] || pkdata.length == 0) return nil;
    }
    
    if (self = [super init])
    {
        _multisigSignaturesRequired = signaturesRequired;
        _multisigPublicKeys = publicKeys;
        
        NSMutableArray* list = [NSMutableArray array];
        [list addObject:@(m_opcode)];
        [list addObjectsFromArray:publicKeys];
        [list addObject:@(n_opcode)];
        _chunks = list;
    }
    return self;
}

- (NSData*) data
{
    if (!_data)
    {
        // TODO: serialize in binary
    }
    return _data;
}

- (id) string
{
    if (!_string)
    {
        // TODO: serialize
    }
    return _string;
}

- (NSArray*) parseData:(NSData*)data
{
    // TODO: parse
    return @[];
}

- (NSArray*) parseString:(NSString*)string
{
    // TODO: parse
    return @[];
}


- (BOOL) isStandard
{
    return [self isHash160Script]
        || [self isPayToScriptHashScript]
        || [self isPublicKeyScript]
        || [self isStandardMultisignatureScript];
}

- (BOOL) isPublicKeyScript
{
    if (_chunks.count != 2) return NO;
    return [self pushdataAtIndex:0].length > 1
        && [self opcodeAtIndex:1] == OP_CHECKSIG;
}

- (BOOL) isHash160Script
{
    if (_chunks.count != 5) return NO;
    
    return [self opcodeAtIndex:0] == OP_DUP
        && [self opcodeAtIndex:1] == OP_HASH160
        && [self pushdataAtIndex:2].length == 20
        && [self opcodeAtIndex:3] == OP_EQUALVERIFY
        && [self opcodeAtIndex:4] == OP_CHECKSIG;
}

- (BOOL) isPayToScriptHashScript
{
    if (_chunks.count != 3) return NO;
    
    return [self opcodeAtIndex:0] == OP_HASH160
        && [self pushdataAtIndex:1].length == 20
        && [self opcodeAtIndex:2] == OP_EQUAL;
}

- (BOOL) isStandardMultisignatureScript
{
    if (![self isMultisignatureScript]) return NO;
    return _multisigPublicKeys.count <= 3;
}

- (BOOL) isMultisignatureScript
{
    if (_multisigSignaturesRequired == 0)
    {
         [self detectMultisigScript];
    }
    return _multisigSignaturesRequired > 0;
}

- (void) detectMultisigScript
{
    // multisig script must have at least 4 ops ("OP_1 <pubkey> OP_1 OP_CHECKMULTISIG")
    if (_chunks.count < 4) return;
    
    // The last op is multisig check.
    if ([self opcodeAtIndex:-1] != OP_CHECKMULTISIG) return;
    
    BTCOpcode m_opcode = [self opcodeAtIndex:0];
    BTCOpcode n_opcode = [self opcodeAtIndex:-2];
    
    NSInteger m = BTCSmallIntegerFromOpcode(m_opcode);
    NSInteger n = BTCSmallIntegerFromOpcode(n_opcode);
    if (m <= 0 || m == NSIntegerMax) return;
    if (n <= 0 || n == NSIntegerMax || n < m) return;
    
    // We must have correct number of pubkeys in the script. 3 extra ops: OP_<M>, OP_<N> and OP_CHECKMULTISIG
    if (_chunks.count != (3 + n)) return;
    
    NSMutableArray* list = [NSMutableArray array];
    for (int i = 1; i <= n; i++)
    {
        NSData* data = [self pushdataAtIndex:i];
        if (!data) return;
        [list addObject:data];
    }
    
    // Now we extracted all pubkeys and verified the numbers.
    _multisigSignaturesRequired = m;
    _multisigPublicKeys = list;
}



#pragma mark - Utility methods


// Returns an opcode in a chunk.
// If the chunk is data, not an opcode, returns OP_INVALIDOPCODE
// Raises exception if index is out of bounds.
- (BTCOpcode) opcodeAtIndex:(NSInteger)index
{
    NSNumber* n = _chunks[index < 0 ? (_chunks.count + index) : index];
    if ([n isKindOfClass:[NSNumber class]]) return [n unsignedCharValue];
    // If the chunk is not actually an opcode, return invalid opcode.
    return OP_INVALIDOPCODE;
}

// Returns NSData in a chunk.
// If chunk is actually an opcode, returns nil.
// Raises exception if index is out of bounds.
- (NSData*) pushdataAtIndex:(NSInteger)index
{
    NSData* data = _chunks[index < 0 ? (_chunks.count + index) : index];
    if ([data isKindOfClass:[NSData class]]) return data;
    // If the chunk is not actually a data, return nil.
    return nil;
}

// Returns bignum from pushdata or nil.
- (BTCBigNumber*) bignumberAtIndex:(NSInteger)index
{
    NSData* data = [self pushdataAtIndex:index];
    if (!data) return nil;
    BTCBigNumber* bn = [[BTCBigNumber alloc] initWithData:data];
    return bn;
}






#pragma mark - Canonical checks


// Note: non-canonical pubkey could still be valid for EC internals of OpenSSL and thus accepted by Bitcoin nodes.
+ (BOOL) isCanonicalPublicKey:(NSData*)data error:(NSError**)errorOut
{
    NSUInteger length = data.length;
    const char* bytes = [data bytes];
    
    // Non-canonical public key: too short
    if (length < 33)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalPublicKey userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical public key: too short.", @"")}];
        return NO;
    }
    
    if (bytes[0] == 0x04)
    {
        // Length of uncompressed key must be 65 bytes.
        if (length == 65) return YES;
        
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalPublicKey userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical public key: length of uncompressed key must be 65 bytes.", @"")}];
        
        return NO;
    }
    else if (bytes[0] == 0x02 || bytes[0] == 0x03)
    {
        // Length of compressed key must be 33 bytes.
        if (length == 33) return YES;
        
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalPublicKey userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical public key: length of compressed key must be 33 bytes.", @"")}];
        
        return NO;
    }
    
    // Unknown public key format.
    if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalPublicKey userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown non-canonical public key.", @"")}];
    
    return NO;
}



+ (BOOL) isCanonicalSignature:(NSData*)data verifyEvenS:(BOOL)verifyEvenS error:(NSError**)errorOut
{
    // See https://bitcointalk.org/index.php?topic=8392.msg127623#msg127623
    // A canonical signature exists of: <30> <total len> <02> <len R> <R> <02> <len S> <S> <hashtype>
    // Where R and S are not negative (their first byte has its highest bit not set), and not
    // excessively padded (do not start with a 0 byte, unless an otherwise negative number follows,
    // in which case a single 0 byte is necessary and even required).
    
    NSInteger length = data.length;
    const unsigned char* bytes = data.bytes;
    
    // Non-canonical signature: too short
    if (length < 9)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: too short.", @"")}];
        return NO;
    }
    
    // Non-canonical signature: too long
    if (length > 73)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: too long.", @"")}];
        return NO;
    }

    unsigned char nHashType = bytes[length - 1] & (~(SIGHASH_ANYONECANPAY));
    
    if (nHashType < SIGHASH_ALL || nHashType > SIGHASH_SINGLE)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: unknown hashtype byte.", @"")}];
        return NO;
    }
    
    if (bytes[0] != 0x30)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: wrong type.", @"")}];
        return NO;
    }
    
    if (bytes[1] != length-3)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: wrong length marker.", @"")}];
        return NO;
    }
    
    unsigned int nLenR = bytes[3];
    
    if (5 + nLenR >= length)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S length misplaced.", @"")}];
        return NO;
    }
    
    unsigned int nLenS = bytes[5+nLenR];
    
    if ((unsigned long)(nLenR+nLenS+7) != length)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: R+S length mismatch", @"")}];
        return NO;
    }
    
    const unsigned char *R = &bytes[4];
    if (R[-2] != 0x02)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: R value type mismatch", @"")}];
        return NO;
    }
    if (nLenR == 0)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: R length is zero", @"")}];
        return NO;
    }
    
    if (R[0] & 0x80)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: R value negative", @"")}];
        return NO;
    }
    
    if (nLenR > 1 && (R[0] == 0x00) && !(R[1] & 0x80))
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: R value excessively padded", @"")}];
        return NO;
    }
    
    const unsigned char *S = &bytes[6+nLenR];
    if (S[-2] != 0x02)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S value type mismatch", @"")}];
        return NO;
    }
    
    if (nLenS == 0)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S length is zero", @"")}];
        return NO;
    }
    
    if (S[0] & 0x80)
    {
        return NO;
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S value is negative", @"")}];
    }
    
    if (nLenS > 1 && (S[0] == 0x00) && !(S[1] & 0x80))
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S value excessively padded", @"")}];
        return NO;
    }
    
    if (verifyEvenS)
    {
        if (S[nLenS-1] & 1)
        {
            if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorNonCanonicalScriptSignature userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Non-canonical signature: S value is odd", @"")}];
            return NO;
        }
    }
    
    return true;
}


@end
