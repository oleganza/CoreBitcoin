// Oleg Andreev <oleganza@gmail.com>

#import "BTCScript.h"
#import "BTCAddress.h"
#import "BTCBigNumber.h"
#import "BTCErrors.h"
#import "BTCData.h"

@interface BTCScript ()
@end

@implementation BTCScript {
    // An array of NSData objects (pushing data) or NSNumber objects (containing opcodes)
    NSMutableArray* _chunks;
    
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
        _chunks = [NSMutableArray array];
    }
    return self;
}

- (id) initWithData:(NSData*)data
{
    if (self = [super init])
    {
        // It's important to keep around original data to correctly identify the size of the script for BTC_MAX_SCRIPT_SIZE check
        // and to correctly calculate hash for the signature because in BitcoinQT scripts are not re-serialized/canonicalized.
        _data = data ?: [NSData data];
        _chunks = [self parseData:_data];
        if (!_chunks) return nil;
    }
    return self;
}

- (id) initWithString:(NSString*)string
{
    if (self = [super init])
    {
        _chunks = [self parseString:string ?: @""];
        if (!_chunks) return nil;
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
        NSMutableData* buffer = [NSMutableData data];
        for (id chunk in _chunks)
        {
            if ([chunk isKindOfClass:[NSNumber class]])
            {
                BTCOpcode opcode = [chunk unsignedCharValue];
                [buffer appendBytes:&opcode length:sizeof(opcode)];
            }
            else if ([chunk isKindOfClass:[NSData class]])
            {
                NSData* data = chunk;
                
                // First append the length. If it's smaller than OP_PUSHDATA1, the opcode is the length itself.
                if (data.length < OP_PUSHDATA1)
                {
                    unsigned char len = data.length;
                    [buffer appendBytes:&len length:sizeof(len)];
                }
                else if (data.length <= 0xff)
                {
                    unsigned char pushdata1 = OP_PUSHDATA1;
                    unsigned char len = data.length;
                    [buffer appendBytes:&pushdata1 length:sizeof(pushdata1)];
                    [buffer appendBytes:&len length:sizeof(len)];
                }
                else if (data.length <= 0xffff)
                {
                    unsigned char pushdata2 = OP_PUSHDATA2;
                    uint16_t len = data.length;
                    len = CFSwapInt16HostToLittle(len);
                    [buffer appendBytes:&pushdata2 length:sizeof(pushdata2)];
                    [buffer appendBytes:&len length:sizeof(len)];
                }
                else
                {
                    unsigned char pushdata4 = OP_PUSHDATA4;
                    uint32_t len = (uint32_t)data.length;
                    len = CFSwapInt32HostToLittle(len);
                    [buffer appendBytes:&pushdata4 length:sizeof(pushdata4)];
                    [buffer appendBytes:&len length:sizeof(len)];
                }
                
                // Now append the actual data.
                [buffer appendData:data];
            }
        }
        _data = buffer;
    }
    return _data;
}

- (NSString*) string
{
    if (!_string)
    {
        NSMutableString* buffer = [NSMutableString string];
        
        for (id chunk in _chunks)
        {
            if ([chunk isKindOfClass:[NSNumber class]])
            {
                BTCOpcode opcode = [chunk unsignedCharValue];
                
                // Some other guys (BitcoinQT, bitcoin-ruby) encode "small enough" integers in decimal numbers and do that differently.
                // BitcoinQT encodes any data less than 4 bytes as a decimal number.
                // bitcoin-ruby encodes 2..16 as decimals, 0 and -1 as opcode names and the rest is in hex.
                // Now no matter which encoding you use, it can be parsed incorrectly.
                // Also: pushdata operations are typically encoded in a raw data which can be encoded in binary differently.
                // This means, you'll never be able to parse a sane-looking script into only one binary.
                // So forget about relying on parsing this thing exactly. Typically, we either have very small numbers (0..16),
                // or very big numbers (hashes and pubkeys).
                if (opcode == OP_0)
                {
                    [buffer appendString:@"0 "];
                }
                else if (opcode == OP_1NEGATE)
                {
                    [buffer appendString:@"-1 "];
                }
                else if (opcode >= OP_1 && opcode <= OP_16)
                {
                    [buffer appendFormat:@"%ul ", ((int)opcode + 1 - (int)OP_1)];
                }
                else
                {
                    [buffer appendFormat:@"%@ ", BTCNameForOpcode(opcode)];
                }
            }
            else if ([chunk isKindOfClass:[NSData class]])
            {
                NSData* data = chunk;
                if (data.length <= 4)
                {
                    // Act as BitcoinQT: small enough data is encoded as decimal integer.
                    // This still creates ambiguity in between 4- and 5-byte values, but we typically don't
                    // see them anywhere.
                    BTCBigNumber* bignum = [[BTCBigNumber alloc] initWithData:data];
                    [buffer appendFormat:@"%d ", bignum.int32value];
                }
                else
                {
                    [buffer appendFormat:@"%@ ", BTCHexStringFromData(data)];
                }
            }
        }
        
        _string = [buffer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return _string;
}

- (NSMutableArray*) parseData:(NSData*)data
{
    if (data.length == 0) return [NSMutableArray array];
    
    NSMutableArray* chunks = [NSMutableArray array];
    
    int i = 0;
    int length = (int)data.length;
    int endi = length - 1;
    const uint8_t* bytes = [data bytes];
    
    while (i < length)
    {
        BTCOpcode opcode = bytes[i]; i++;
        
        // Push data operations.
        if (opcode > 0 && opcode <= OP_PUSHDATA4)
        {
            uint32_t dataLength = 0;
            if (opcode < OP_PUSHDATA1)
            {
                dataLength = opcode;
            }
            else if (opcode == OP_PUSHDATA1)
            {
                if (endi - i < 1) return nil;
                dataLength = *(bytes + i); i++;
            }
            else if (opcode == OP_PUSHDATA2)
            {
                if (endi - i < 2) return nil;
                memcpy(&dataLength, bytes + i, 2);
                i += 2;
            }
            else if (opcode == OP_PUSHDATA4)
            {
                if (endi - i < 4) return nil;
                memcpy(&dataLength, bytes + i, 4);
                i += 4;
            }
            
            if (endi - i < 0 || (unsigned int)(endi - i) < dataLength)
                return nil;
            
            [chunks addObject:[data subdataWithRange:NSMakeRange(i, dataLength)]];
            i += dataLength;
        }
        else
        {
            // Any opcode: simply add to the chunks list.
            [chunks addObject:@(opcode)];
        }
    }
    return chunks;
}

- (NSMutableArray*) parseString:(NSString*)string
{
    if (string.length == 0) return [NSMutableArray array];
    
    NSMutableArray* chunks = [NSMutableArray array];
    
    NSArray* tokens = [string componentsSeparatedByString:@" "];
    
    NSRegularExpression* decimalNumberRegexp = [NSRegularExpression regularExpressionWithPattern:@"^-?[0-9]+$"
                                                                                         options:0
                                                                                           error:NULL];
    
    NSRegularExpression* hexDataRegexp = [NSRegularExpression regularExpressionWithPattern:@"^[0-9a-fA-F]+$"
                                                                                         options:0
                                                                                           error:NULL];
    
    for (NSString* token in tokens)
    {
        if ([token isEqualToString:@""]) continue;
        
        BTCOpcode opcode = BTCOpcodeForName(token);
        
        // If token is "CHECKSIG", try converting it to OP_CHECKSIG.
        if (opcode == OP_INVALIDOPCODE) opcode = BTCOpcodeForName([@"OP_" stringByAppendingString:token]);
        
        // Valid opcode - put as is.
        if (opcode != OP_INVALIDOPCODE)
        {
            [chunks addObject:@(opcode)];
        }
        else
        {
            // If there is a string of decimal numbers of 1..10 bytes, read it as a decimal integer.
            // This cannot ever be accurate because bigger data chunk may be encoded in hex into the same token.
            // Keeping this in mind, I just read 10 bytes and don't care if it overflows int32.
            // Numbers close to maximum cannot be reliably parsed anyway. Thankfully, this parser is not used in the protocol
            // and transactions with such numbers normally do not happen.
            if ([decimalNumberRegexp numberOfMatchesInString:token options:0 range:NSMakeRange(0, token.length)] > 0
                && token.length <= 10)
            {
                NSInteger integer = [token integerValue];
                BTCOpcode opcode = BTCOpcodeForSmallInteger(integer);
                if (opcode != OP_INVALIDOPCODE)
                {
                    [chunks addObject:@(opcode)];
                }
                else
                {
                    BTCBigNumber* bignum = [[BTCBigNumber alloc] initWithInt64:integer];
                    [chunks addObject:bignum.data];
                }
            }
            else if ([hexDataRegexp numberOfMatchesInString:token options:0 range:NSMakeRange(0, token.length)] > 0)
            {
                NSData* data = BTCDataWithHexString(token);
                if (!data) return nil;
                [chunks addObject:data];
            }
            else
            {
                // Unrecognized token or invalid number, or invalid hex string.
                return nil;
            }
        }
    }
    
    return chunks;
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
    // TODO: check against the original serialized form instead of parsed chunks because BIP16 defines
    // P2SH script as an exact byte template. Scripts using OP_PUSHDATA1/2/4 are not valid P2SH scripts.
    // To do that we have to maintain original script binary data and each chunk should keep a range in that data.
    
    if (_chunks.count != 3) return NO;
    
    return [self opcodeAtIndex:0] == OP_HASH160
        && [self pushdataAtIndex:1].length == 20
        && [self opcodeAtIndex:2] == OP_EQUAL;
}

// Returns YES if the script ends with P2SH check.
// Not used in CoreBitcoin. Similar code is used in bitcoin-ruby. I don't know if we'll ever need it.
- (BOOL) endsWithPayToScriptHash
{
    if (_chunks.count < 3) return NO;
    
    return [self opcodeAtIndex:-3] == OP_HASH160
        && [self pushdataAtIndex:-2].length == 20
        && [self opcodeAtIndex:-1] == OP_EQUAL;
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

// If typical multisig tx is detected, sets two ivars:
// _multisigSignaturesRequired, _multisigPublicKeys.
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

- (BOOL) isPushOnly
{
    for (id chunk in _chunks)
    {
        if ([chunk isKindOfClass:[NSNumber class]])
        {
            BTCOpcode opcode = [chunk unsignedCharValue];
            if (opcode > OP_16) return NO;
        }
        else // data chunk represents a PUSHDATA op
        {
        }
    }
    return YES;
}


- (void) enumerateOperations:(void(^)(NSUInteger opIndex, BTCOpcode opcode, NSData* pushdata, BOOL* stop))block
{
    if (!block) return;
    
    NSUInteger opIndex = 0;
    for (id chunk in _chunks)
    {
        if ([chunk isKindOfClass:[NSNumber class]])
        {
            BTCOpcode opcode = [chunk unsignedCharValue];
            BOOL stop = NO;
            block(opIndex, opcode, nil, &stop);
            if (stop) return;
        }
        else if ([chunk isKindOfClass:[NSData class]])
        {
            NSData* data = chunk;
            BOOL stop = NO;
            block(opIndex, OP_INVALIDOPCODE, data, &stop);
            if (stop) return;
        }
        opIndex++;
    }
}




#pragma mark - Modification



- (void) invalidateSerialization
{
    _data = nil;
    _string = nil;
    _multisigSignaturesRequired = 0;
    _multisigPublicKeys = nil;
}

- (void) appendOpcode:(BTCOpcode)opcode
{
    [_chunks addObject:@(opcode)];
    [self invalidateSerialization];
}

- (void) appendData:(NSData*)data
{
    if (!data) return;
    [_chunks addObject:data];
    [self invalidateSerialization];
}

- (void) appendScript:(BTCScript*)otherScript
{
    if (!otherScript) return;
    
    [_chunks addObjectsFromArray:otherScript->_chunks];
    
    [self invalidateSerialization];
}

- (BTCScript*) subScriptFromIndex:(NSUInteger)index
{
    BTCScript* script = [[BTCScript alloc] init];
    script->_chunks = [[_chunks subarrayWithRange:NSMakeRange(index, _chunks.count - index)] mutableCopy];
    return script;
}

- (BTCScript*) subScriptToIndex:(NSUInteger)index
{
    BTCScript* script = [[BTCScript alloc] init];
    script->_chunks = [[_chunks subarrayWithRange:NSMakeRange(0, index)] mutableCopy];
    return script;
}

- (id) copyWithZone:(NSZone *)zone
{
    BTCScript* script = [[BTCScript alloc] init];
    script->_chunks = [_chunks mutableCopy];
    return script;
}

- (void) deleteOccurrencesOfData:(NSData*)data
{
    if (!data) return;
    [_chunks removeObject:data];
}

- (void) deleteOccurrencesOfOpcode:(BTCOpcode)opcode
{
    [_chunks removeObject:@(opcode)];
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
