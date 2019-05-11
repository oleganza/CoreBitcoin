// Oleg Andreev <oleganza@gmail.com>

#import "BTCScript.h"
#import "BTCAddress.h"
#import "BTCBigNumber.h"
#import "BTCErrors.h"
#import "BTCData.h"


@interface BTCScriptChunk ()

// A range of scriptData represented by this chunk.
@property(nonatomic) NSRange range;

// Reference to the whole script binary data.
@property(nonatomic) NSData* scriptData;

// Portion of scriptData defined by range.
@property(nonatomic, readonly) NSData* chunkData;

// String representation of a chunk.
// OP_1NEGATE, OP_0, OP_1..OP_16 are represented as a decimal number.
// Most compactly represented pushdata chunks >= 128 bit is encoded as <hex string>
// Smaller most compactly represented data is encoded as [<hex string>]
// Non-compact pushdata (e.g. 75-byte string with PUSHDATA1) contain a decimal prefix denoting a length size before hex data in square brackets. Ex. "1:[...]", "2:[...]" or "4:[...]"
// For both compat and non-compact pushdata chunks, if the data consists of all printable ASCII characters (0x20..0x7E), it is enclosed not in square brackets, but in single quotes as characters themselves. Non-compact string is prefixed with 1:, 2: or 4: like described above.
- (NSString*) string;

// Returns a chunk if parsed correctly or nil if it is invalid.
+ (BTCScriptChunk*) parseChunkFromData:(NSData*)data offset:(NSUInteger)offset;

// Returns encoded data with proper length prefix for a given raw pushdata.
// If preferredLengthEncoding is -1, the most compact encoding is used. Other valid values: 0, 1, 2, 4.
+ (NSData*) scriptDataForPushdata:(NSData*)data preferredLengthEncoding:(int)preferredLengthEncoding;

@end


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
        NSMutableData* resultData = [NSMutableData data];
        
        BTCOpcode prefix[] = {OP_DUP, OP_HASH160};
        [resultData appendBytes:prefix length:sizeof(prefix)];
        
        unsigned char length = address.data.length;
        [resultData appendBytes:&length length:sizeof(length)];
        
        [resultData appendData:address.data];
        
        BTCOpcode suffix[] = {OP_EQUALVERIFY, OP_CHECKSIG};
        [resultData appendBytes:suffix length:sizeof(suffix)];
        
        return [self initWithData:resultData];
    }
    else if ([address isKindOfClass:[BTCScriptHashAddress class]])
    {
        // OP_HASH160 <hash> OP_EQUAL
        NSMutableData* resultData = [NSMutableData data];
        
        BTCOpcode prefix[] = {OP_HASH160};
        [resultData appendBytes:prefix length:sizeof(prefix)];
        
        unsigned char length = address.data.length;
        [resultData appendBytes:&length length:sizeof(length)];
        
        [resultData appendData:address.data];
        
        BTCOpcode suffix[] = {OP_EQUAL};
        [resultData appendBytes:suffix length:sizeof(suffix)];
        
        return [self initWithData:resultData];
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
    
    NSMutableData* data = [NSMutableData data];
    
    [data appendBytes:&m_opcode length:sizeof(m_opcode)];
    
    for (NSData* pubkey in publicKeys)
    {
        NSData* d = [BTCScriptChunk scriptDataForPushdata:pubkey preferredLengthEncoding:-1];
        
        if (d.length == 0) return nil; // invalid data
        
        [data appendData:d];
    }
    
    [data appendBytes:&n_opcode length:sizeof(n_opcode)];
    
    
    if (self = [self initWithData:data])
    {
        _multisigSignaturesRequired = signaturesRequired;
        _multisigPublicKeys = publicKeys;
    }
    return self;
}

- (NSData*) data
{
    if (!_data)
    {
        // When we calculate data from scratch, it's important to respect actual offsets in the chunks as they may have been copied or shifted in subScript* methods.
        NSMutableData* md = [NSMutableData data];
        for (BTCScriptChunk* chunk in _chunks)
        {
            [md appendData:chunk.chunkData];
        }
        _data = md;
    }
    return _data;
}

- (NSString*) string
{
    if (!_string)
    {
        NSMutableArray* buffer = [NSMutableArray array];
        
        for (BTCScriptChunk* chunk in _chunks)
        {
            [buffer addObject:[chunk string]];
        }
        
        _string = [buffer componentsJoinedByString:@" "];
    }
    return _string;
}

- (NSMutableArray*) parseData:(NSData*)data
{
    if (data.length == 0) return [NSMutableArray array];
    
    NSMutableArray* chunks = [NSMutableArray array];
    
    int i = 0;
    int length = (int)data.length;
    
    while (i < length)
    {
        BTCScriptChunk* chunk = [BTCScriptChunk parseChunkFromData:data offset:i];
        
        // Exit if failed to parse
        if (!chunk) return nil;
        
        [chunks addObject:chunk];
        
        i += chunk.range.length;
    }
    return chunks;
}

- (NSMutableArray*) parseString:(NSString*)string
{
    if (string.length == 0) return [NSMutableArray array];
    
    // Accumulated data to which chunks are referring to.
    NSMutableData* scriptData = [NSMutableData data];
    
    NSScanner* scanner = [NSScanner scannerWithString:string];
    NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (![scanner isAtEnd])
    {
        [scanner scanCharactersFromSet:whitespaceSet intoString:NULL];
        
        if ([scanner isAtEnd]) break;
        
        // First detect 1:, 2: and 4: prefixes before pushdata (quoted, hex or in square brackets)
        // encoding = 0 - most compact encoding for the given data
        // encoding = 1 - 1-byte length prefix
        // encoding = 2 - 2-byte length prefix
        // encoding = 4 - 4-byte length prefix
        int lengthEncoding = -1; // -1 means "use the most compact one".
        BOOL mustBePushdata = NO;
        
        if ([scanner scanString:@"0:" intoString:NULL]) // just for extra consistency, detect 0: as well (although, it's pointless to use it for real)
        {
            lengthEncoding = 0;
            mustBePushdata = YES;
        }
        else if ([scanner scanString:@"1:" intoString:NULL])
        {
            lengthEncoding = 1;
            mustBePushdata = YES;
        }
        else if ([scanner scanString:@"2:" intoString:NULL])
        {
            lengthEncoding = 2;
            mustBePushdata = YES;
        }
        else if ([scanner scanString:@"4:" intoString:NULL])
        {
            lengthEncoding = 4;
            mustBePushdata = YES;
        }
        
        // The text could be:
        // 1. Single-quoted UTF8 string. (BitcoinQT unit tests style)
        // 2. Arbitrary pushdata in square brackets (bitcoinj style)
        // 3. Raw binary in hex (starts with 0x) (BitcoinQT unit tests style)
        // 4. Opcode with and without OP_ prefix
        // 5. Small integer
        // 6. Big pushdata in hex
        
        
        NSData* pushdata = nil;
        NSString* word = nil;
        
        // 1. Detect an ASCII string in single quotes.
        if ([scanner scanString:@"'" intoString:NULL])
        {
            NSMutableString* buffer = [NSMutableString string];
            
            while (1)
            {
                NSString* portion = @"";
                if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\\'"] intoString:&portion])
                {
                    [buffer appendString:portion];
                }
                
                if ([scanner isAtEnd]) return nil; // if finished it means the string is not terminated properly
                
                // For simplicity, we do not support all imaginable escape sequences like in C or JavaScript (especially unicode ones).
                // This parser will be happy to read UTF8 characters, but we do not support writing UTF8 characters in a form of single-quoted string.
                // For unsupported characters use hex notation, not ASCII one.
                // Backslash not in front of another backslash or single quote is a syntax error.
                if ([scanner scanString:@"\\" intoString:NULL])
                {
                    // Escape sequence before either quote «'» or backslash «\\»
                    if ([scanner scanString:@"\\" intoString:NULL]) // escaped backslash
                    {
                        [buffer appendString:@"\\"];
                        continue;
                    }
                    else if ([scanner scanString:@"'" intoString:NULL])
                    {
                        [buffer appendString:@"'"];
                        continue;
                    }
                    // Something unsupported is escaped - fail.
                    return nil;
                }
                else if ([scanner scanString:@"'" intoString:NULL])
                {
                    // String finished.
                    break;
                }
                // Syntax failed.
                return nil;
            }
            
            pushdata = [buffer dataUsingEncoding:NSUTF8StringEncoding];
        }
        // 2. Arbitrary hex pushdata in square brackets (bitcoinj style)
        else if ([scanner scanString:@"[" intoString:NULL])
        {
            NSString* hexstring = nil;
            if ([scanner scanUpToString:@"]" intoString:&hexstring])
            {
                // Check if hex string is valid.
                NSData* data = BTCDataWithHexString(hexstring);
                
                if (!data) return nil; // hex string is invalid
                
                if (![scanner scanString:@"]" intoString:NULL])
                {
                    return nil;
                }
                
                pushdata = data;
            }
            else
            {
                return nil;
            }
        }
        // 3. Raw binary in hex (starts with 0x) (BitcoinQT unit tests style)
        else if ([scanner scanString:@"0x" intoString:NULL])
        {
            if (mustBePushdata) return nil; // Should not prepend 0x... with pushdata length prefix.
            
            NSString* hexstring = nil;
            if ([scanner scanUpToCharactersFromSet:whitespaceSet intoString:&hexstring])
            {
                NSData* data = BTCDataWithHexString(hexstring);
                
                if (!data || data.length == 0) return nil; // hex string is invalid
                
                [scriptData appendData:data];
                
                // Move back to the beginning of the loop to scan another piece of script.
                continue;
            }
            else
            {
                // Should have some data after 0x
                return nil;
            }
        }
        // Find one of these:
        // 4. Opcode with and without OP_ prefix
        // 5. Small integer
        // 6. Big pushdata in hex
        else if ([scanner scanUpToCharactersFromSet:whitespaceSet intoString:&word])
        {
            // Attempt to find an opcode name or small integer only if we don't have pushdata prefix (1:, 2:, 4:)
            // E.g. "12" is a small integer OP_12, but "1:12" is OP_PUSHDATA1 with data 0x12
            if (!mustBePushdata)
            {
                BTCOpcode opcode = BTCOpcodeForName(word);
                
                // Opcode may be used without OP_ prefix.
                if (opcode == OP_INVALIDOPCODE) opcode = BTCOpcodeForName([@"OP_" stringByAppendingString:word]);

                // 4. Opcode with and without OP_ prefix
                if (opcode != OP_INVALIDOPCODE)
                {
                    [scriptData appendBytes:&opcode length:sizeof(opcode)];
                    continue;
                }
                else
                {
                    long long decimalInteger = [word longLongValue];
                    
                    if ([[NSString stringWithFormat:@"%lld", decimalInteger] isEqualToString:word])
                    {
                        // 5.1. Small Integer
                        if (decimalInteger >= -1 && decimalInteger <= 16)
                        {
                            opcode = BTCOpcodeForSmallInteger((NSUInteger)decimalInteger);
                            
                            if (opcode == OP_INVALIDOPCODE)
                            {
                                @throw [NSException exceptionWithName:@"BTCScript parser inconsistency"
                                                               reason:@"Tried to parse small integer into opcode, but the opcode comes out invalid." userInfo:nil];
                            }
                            
                            [scriptData appendBytes:&opcode length:sizeof(opcode)];
                            continue;
                        }
                        else
                        {
                            BTCBigNumber* bn = [[BTCBigNumber alloc] initWithInt64:decimalInteger];
                            [scriptData appendData:[BTCScriptChunk scriptDataForPushdata:bn.littleEndianData preferredLengthEncoding:-1]];
                            continue;
                        }
                    }
                    
                } // opcode or small integer
            } // if (!mustBePushdata)
            
            
            
            // 6. Big pushdata in hex
            
            NSData* data = BTCDataWithHexString(word);
            
            if (!data || data.length == 0) return nil; // hex string is invalid
            
            pushdata = data;
            
        }
        else
        {
            // Why this should ever happen?
            @throw [NSException exceptionWithName:@"BTCScript parser inconsistency"
                                           reason:@"Unhandled code path. Should figure out why this happens." userInfo:nil];

        }
        
        
        // If we need pushdata because 1:, 2:, 4: prefix was used, fail if we don't have it.
        if (mustBePushdata && !pushdata)
        {
            return nil;
        }
        
        // If it was a pushdata, encode it.
        if (pushdata)
        {
            NSData* addedScriptData = [BTCScriptChunk scriptDataForPushdata:pushdata preferredLengthEncoding:lengthEncoding];
            
            if (!addedScriptData)
            {
                // Invalid length prefix or data is too small or too big.
                return nil;
            }
                        
            [scriptData appendData:addedScriptData];
        }
        else
        {
            // Why this should ever happen?
            @throw [NSException exceptionWithName:@"BTCScript parser inconsistency"
                                           reason:@"Unhandled code path. Should figure out why this happens." userInfo:nil];

        }
    } // loop over chunks
    
    
    return [self parseData:scriptData];
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
    
    BTCScriptChunk* dataChunk = [self chunkAtIndex:2];
    
    return [self opcodeAtIndex:0] == OP_DUP
        && [self opcodeAtIndex:1] == OP_HASH160
        && !dataChunk.isOpcode
        && dataChunk.range.length == 21
        && [self opcodeAtIndex:3] == OP_EQUALVERIFY
        && [self opcodeAtIndex:4] == OP_CHECKSIG;
}

- (BOOL) isPayToScriptHashScript
{
    // TODO: check against the original serialized form instead of parsed chunks because BIP16 defines
    // P2SH script as an exact byte template. Scripts using OP_PUSHDATA1/2/4 are not valid P2SH scripts.
    // To do that we have to maintain original script binary data and each chunk should keep a range in that data.
    
    if (_chunks.count != 3) return NO;
    
    BTCScriptChunk* dataChunk = [self chunkAtIndex:1];
    
    return [self opcodeAtIndex:0] == OP_HASH160
        && !dataChunk.isOpcode
        && dataChunk.range.length == 21          // this is enough to match the exact byte template, any other encoding will be larger.
        && [self opcodeAtIndex:2] == OP_EQUAL;
}

// Returns YES if the script ends with P2SH check.
// Not used in EthCore. Similar code is used in bitcoin-ruby. I don't know if we'll ever need it.
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

- (BOOL) isDataOnly
{
    // Include both PUSHDATA ops and OP_0..OP_16 literals.
    for (BTCScriptChunk* chunk in _chunks)
    {
        if (chunk.opcode > OP_16)
        {
            return NO;
        }
    }
    return YES;
}

- (NSArray*) scriptChunks
{
    return [_chunks copy];
}

- (void) enumerateOperations:(void(^)(NSUInteger opIndex, BTCOpcode opcode, NSData* pushdata, BOOL* stop))block
{
    if (!block) return;
    
    NSUInteger opIndex = 0;
    for (BTCScriptChunk* chunk in _chunks)
    {
        if (chunk.isOpcode)
        {
            BTCOpcode opcode = chunk.opcode;
            BOOL stop = NO;
            block(opIndex, opcode, nil, &stop);
            if (stop) return;
        }
        else
        {
            NSData* data = chunk.pushdata;
            BOOL stop = NO;
            block(opIndex, OP_INVALIDOPCODE, data, &stop);
            if (stop) return;
        }
        opIndex++;
    }
}


- (BTCAddress*) standardAddress
{
    if ([self isHash160Script])
    {
        if (_chunks.count != 5) return nil;
        
        BTCScriptChunk* dataChunk = [self chunkAtIndex:2];
        
        if (!dataChunk.isOpcode && dataChunk.range.length == 21)
        {
            return [BTCPublicKeyAddress addressWithData:dataChunk.pushdata];
        }
    }
    else if ([self isPayToScriptHashScript])
    {
        if (_chunks.count != 3) return nil;
        
        BTCScriptChunk* dataChunk = [self chunkAtIndex:1];
        
        if (!dataChunk.isOpcode && dataChunk.range.length == 21)
        {
            return [BTCScriptHashAddress addressWithData:dataChunk.pushdata];
        }
    }
    return nil;
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
    NSMutableData* scriptData = [self.data mutableCopy] ?: [NSMutableData data];
    
    [scriptData appendBytes:&opcode length:sizeof(opcode)];
    
    BTCScriptChunk* chunk = [[BTCScriptChunk alloc] init];
    chunk.scriptData = scriptData;
    chunk.range = NSMakeRange(scriptData.length - sizeof(opcode), sizeof(opcode));
    [_chunks addObject:chunk];
    
    // Update reference to a new data for all chunks.
    for (BTCScriptChunk* chunk in _chunks) chunk.scriptData = scriptData;
    
    [self invalidateSerialization];
}

- (void) appendData:(NSData*)data
{
    if (data.length == 0) return;
    
    NSMutableData* scriptData = [self.data mutableCopy] ?: [NSMutableData data];
    
    NSData* addedScriptData = [BTCScriptChunk scriptDataForPushdata:data preferredLengthEncoding:-1];
    [scriptData appendData:addedScriptData];
    
    BTCScriptChunk* chunk = [[BTCScriptChunk alloc] init];
    chunk.scriptData = scriptData;
    chunk.range = NSMakeRange(scriptData.length - addedScriptData.length, addedScriptData.length);
    [_chunks addObject:chunk];
    
    // Update reference to a new data for all chunks.
    for (BTCScriptChunk* chunk in _chunks) chunk.scriptData = scriptData;
    
    [self invalidateSerialization];
}

- (void) appendScript:(BTCScript*)otherScript
{
    if (!otherScript) return;
    
    NSMutableData* scriptData = [self.data mutableCopy] ?: [NSMutableData data];
    
    NSInteger offset = scriptData.length;
    
    [scriptData appendData:otherScript.data];
    
    for (BTCScriptChunk* chunk in otherScript->_chunks)
    {
        BTCScriptChunk* chunk2 = [[BTCScriptChunk alloc] init];
        chunk2.range = NSMakeRange(chunk.range.location + offset, chunk.range.length);
        chunk2.scriptData = scriptData;
        [_chunks addObject:chunk2];
    }

    // Update reference to a new data for all chunks.
    for (BTCScriptChunk* chunk in _chunks) chunk.scriptData = scriptData;

    [self invalidateSerialization];
}

- (BTCScript*) subScriptFromIndex:(NSUInteger)index
{
    NSMutableData* md = [NSMutableData data];
    for (BTCScriptChunk* chunk in [_chunks subarrayWithRange:NSMakeRange(index, _chunks.count - index)])
    {
        [md appendData:chunk.chunkData];
    }
    return [[BTCScript alloc] initWithData:md];
}

- (BTCScript*) subScriptToIndex:(NSUInteger)index
{
    NSMutableData* md = [NSMutableData data];
    for (BTCScriptChunk* chunk in [_chunks subarrayWithRange:NSMakeRange(0, index)])
    {
        [md appendData:chunk.chunkData];
    }
    return [[BTCScript alloc] initWithData:md];
}

- (id) copyWithZone:(NSZone *)zone
{
    return [[BTCScript alloc] initWithData:self.data];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@:0x%p \"%@\">", [self class], self, self.string];
}

- (void) deleteOccurrencesOfData:(NSData*)data
{
    if (data.length == 0) return;
    
    NSMutableData* md = [NSMutableData data];
    
    for (BTCScriptChunk* chunk in _chunks)
    {
        if (![chunk.pushdata isEqual:data])
        {
            [md appendData:chunk.chunkData];
        }
    }
    
    _chunks = [self parseData:md];
}

- (void) deleteOccurrencesOfOpcode:(BTCOpcode)opcode
{
    NSMutableData* md = [NSMutableData data];
    
    for (BTCScriptChunk* chunk in _chunks)
    {
        if (chunk.opcode != opcode)
        {
            [md appendData:chunk.chunkData];
        }
    }
    
    _chunks = [self parseData:md];
}





#pragma mark - Utility methods


- (BTCScriptChunk*) chunkAtIndex:(NSInteger)index
{
    BTCScriptChunk* chunk = _chunks[index < 0 ? (_chunks.count + index) : index];
    return chunk;
}

// Returns an opcode in a chunk.
// If the chunk is data, not an opcode, returns OP_INVALIDOPCODE
// Raises exception if index is out of bounds.
- (BTCOpcode) opcodeAtIndex:(NSInteger)index
{
    BTCScriptChunk* chunk = _chunks[index < 0 ? (_chunks.count + index) : index];
    
    if (chunk.isOpcode) return chunk.opcode;
    
    // If the chunk is not actually an opcode, return invalid opcode.
    return OP_INVALIDOPCODE;
}

// Returns NSData in a chunk.
// If chunk is actually an opcode, returns nil.
// Raises exception if index is out of bounds.
- (NSData*) pushdataAtIndex:(NSInteger)index
{
    BTCScriptChunk* chunk = _chunks[index < 0 ? (_chunks.count + index) : index];
    
    if (chunk.isOpcode) return nil;
    
    return chunk.pushdata;
}

// Returns bignum from pushdata or nil.
- (BTCBigNumber*) bignumberAtIndex:(NSInteger)index
{
    NSData* data = [self pushdataAtIndex:index];
    if (!data) return nil;
    BTCBigNumber* bn = [[BTCBigNumber alloc] initWithLittleEndianData:data];
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










@implementation BTCScriptChunk {
}

- (BTCOpcode) opcode
{
    return (BTCOpcode)((const unsigned char*)_scriptData.bytes)[_range.location];
}

- (BOOL) isOpcode
{
    BTCOpcode opcode = [self opcode];
    // Pushdata opcodes are not considered a single "opcode".
    // Attention: OP_0 is also "pushdata" code that pushes empty data.
    if (opcode <= OP_PUSHDATA4) return NO;
    return YES;
}

- (NSData*) chunkData
{
    return [_scriptData subdataWithRange:_range];
}

// Data being pushed. Returns nil if the opcode is not OP_PUSHDATA*.
- (NSData*) pushdata
{
    if (self.isOpcode) return nil;
    BTCOpcode opcode = [self opcode];
    NSUInteger loc = 1;
    if (opcode == OP_PUSHDATA1)
    {
        loc += 1;
    }
    else if (opcode == OP_PUSHDATA2)
    {
        loc += 2;
    }
    else if (opcode == OP_PUSHDATA4)
    {
        loc += 4;
    }
    return [_scriptData subdataWithRange:NSMakeRange(_range.location + loc, _range.length - loc)];
}

// Returns YES if the data is represented with the most compact opcode.
- (BOOL) isDataCompact
{
    if (self.isOpcode) return NO;
    BTCOpcode opcode = [self opcode];
    NSData* data = [self pushdata];
    if (opcode < OP_PUSHDATA1) return YES; // length fits in one byte under OP_PUSHDATA1.
    if (opcode == OP_PUSHDATA1) return data.length >= OP_PUSHDATA1; // length should be less than OP_PUSHDATA1
    if (opcode == OP_PUSHDATA2) return data.length > 0xff; // length should not fit in one byte
    if (opcode == OP_PUSHDATA4) return data.length > 0xffff; // length should not fit in two bytes
    return NO;
}

// String representation of a chunk.
// OP_1NEGATE, OP_0, OP_1..OP_16 are represented as a decimal number.
// Most compactly represented pushdata chunks >=128 bit are encoded as <hex string>
// Smaller most compactly represented data is encoded as [<hex string>]
// Non-compact pushdata (e.g. 75-byte string with PUSHDATA1) contains a decimal prefix denoting a length size before hex data in square brackets. Ex. "1:[...]", "2:[...]" or "4:[...]"
// For both compat and non-compact pushdata chunks, if the data consists of all printable characters (0x20..0x7E), it is enclosed not in square brackets, but in single quotes as characters themselves. Non-compact string is prefixed with 1:, 2: or 4: like described above.

// Some other guys (BitcoinQT, bitcoin-ruby) encode "small enough" integers in decimal numbers and do that differently.
// BitcoinQT encodes any data less than 4 bytes as a decimal number.
// bitcoin-ruby encodes 2..16 as decimals, 0 and -1 as opcode names and the rest is in hex.
// Now no matter which encoding you use, it can be parsed incorrectly.
// Also: pushdata operations are typically encoded in a raw data which can be encoded in binary differently.
// This means, you'll never be able to parse a sane-looking script into only one binary.
// So forget about relying on parsing this thing exactly. Typically, we either have very small numbers (0..16),
// or very big numbers (hashes and pubkeys).

- (NSString*) string
{
    BTCOpcode opcode = [self opcode];
    
    if (self.isOpcode)
    {
        if (opcode == OP_0) return @"0";
        if (opcode == OP_1NEGATE) return @"-1";
        if (opcode >= OP_1 && opcode <= OP_16)
        {
            return [NSString stringWithFormat:@"%u", ((int)opcode + 1 - (int)OP_1)];
        }
        else
        {
            return BTCNameForOpcode(opcode);
        }
    }
    else
    {
        NSData* data = [self pushdata];
        
        NSString* string = nil;
        // Empty data is encoded as OP_0.
        if (data.length == 0)
        {
            string = @"0";
        }
        else if ([self isASCIIData:data])
        {
            string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            
            // Escape escapes & single quote characters.
            string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            // Wrap in single quotes. Why not double? Because they are already used in JSON and we don't want to multiply the mess.
            string = [NSString stringWithFormat:@"'%@'", string];
        }
        else
        {
            string = BTCHexStringFromData(data);
            
            // Shorter than 128-bit chunks are wrapped in square brackets to avoid ambiguity with big all-decimal numbers.
            if (data.length < 16)
            {
                string = [NSString stringWithFormat:@"[%@]", string];
            }
        }
        
        // Non-compact data is prefixed with an appropriate length prefix.
        if (![self isDataCompact])
        {
            int prefix = 1;
            if (opcode == OP_PUSHDATA2) prefix = 2;
            if (opcode == OP_PUSHDATA4) prefix = 4;
            string = [NSString stringWithFormat:@"%d:%@", prefix, string];
        }
        return string;
    }
    
    return nil;
}

- (BOOL) isASCIIData:(NSData*)data
{
    BOOL isASCII = YES;
    for (int i = 0; i < data.length; i++)
    {
        char ch = ((const char*)data.bytes)[i];
        if (!(ch >= 0x20 && ch <= 0x7E))
        {
            isASCII = NO;
            break;
        }
    }
    return isASCII;
}

// If encoding is -1, then the most compact will be chosen.
// Valid values: -1, 0, 1, 2, 4.
// Returns nil if preferredLengthEncoding can't be used for data, or data is nil or too big.

+ (NSData*) scriptDataForPushdata:(NSData*)data preferredLengthEncoding:(int)preferredLengthEncoding
{
    if (!data) return nil;
    
    NSMutableData* scriptData = [NSMutableData data];
    
    if (data.length < OP_PUSHDATA1 && preferredLengthEncoding <= 0)
    {
        uint8_t len = data.length;
        [scriptData appendBytes:&len length:sizeof(len)];
        [scriptData appendData:data];
    }
    else if (data.length <= 0xff && (preferredLengthEncoding == -1 || preferredLengthEncoding == 1))
    {
        uint8_t op = OP_PUSHDATA1;
        uint8_t len = data.length;
        [scriptData appendBytes:&op length:sizeof(op)];
        [scriptData appendBytes:&len length:sizeof(len)];
        [scriptData appendData:data];
    }
    else if (data.length <= 0xffff && (preferredLengthEncoding == -1 || preferredLengthEncoding == 2))
    {
        uint8_t op = OP_PUSHDATA2;
        uint16_t len = CFSwapInt16HostToLittle((uint16_t)data.length);
        [scriptData appendBytes:&op length:sizeof(op)];
        [scriptData appendBytes:&len length:sizeof(len)];
        [scriptData appendData:data];
    }
    else if ((unsigned long long)data.length <= 0xffffffffull && (preferredLengthEncoding == -1 || preferredLengthEncoding == 4))
    {
        uint8_t op = OP_PUSHDATA4;
        uint32_t len = CFSwapInt32HostToLittle((uint32_t)data.length);
        [scriptData appendBytes:&op length:sizeof(op)];
        [scriptData appendBytes:&len length:sizeof(len)];
        [scriptData appendData:data];
    }
    else
    {
        // Invalid preferredLength encoding or data size is too big.
        return nil;
    }
    
    return scriptData;
}

+ (BTCScriptChunk*) parseChunkFromData:(NSData*)scriptData offset:(NSUInteger)offset
{
    // Data should fit at least one opcode.
    if (scriptData.length < (offset + 1)) return nil;
    
    const uint8_t* bytes = ((const uint8_t*)[scriptData bytes]);
    BTCOpcode opcode = bytes[offset];
    
    if (opcode <= OP_PUSHDATA4)
    {
        // push data opcode
        int length = (int)scriptData.length;

        BTCScriptChunk* chunk = [[BTCScriptChunk alloc] init];
        chunk.scriptData = scriptData;
        
        if (opcode < OP_PUSHDATA1)
        {
            uint8_t dataLength = opcode;
            NSUInteger chunkLength = sizeof(opcode) + dataLength;
            
            if (offset + chunkLength > length) return nil;
            
            chunk.range = NSMakeRange(offset, chunkLength);
        }
        else if (opcode == OP_PUSHDATA1)
        {
            uint8_t dataLength;
            
            if (offset + sizeof(dataLength) > length) return nil;
            
            memcpy(&dataLength, bytes + offset + sizeof(opcode), sizeof(dataLength));

            NSUInteger chunkLength = sizeof(opcode) + sizeof(dataLength) + dataLength;
            
            if (offset + chunkLength > length) return nil;
            
            chunk.range = NSMakeRange(offset, chunkLength);
        }
        else if (opcode == OP_PUSHDATA2)
        {
            uint16_t dataLength;
            
            if (offset + sizeof(dataLength) > length) return nil;
            
            memcpy(&dataLength, bytes + offset + sizeof(opcode), sizeof(dataLength));
            dataLength = CFSwapInt16LittleToHost(dataLength);
            
            NSUInteger chunkLength = sizeof(opcode) + sizeof(dataLength) + dataLength;
            
            if (offset + chunkLength > length) return nil;
            
            chunk.range = NSMakeRange(offset, chunkLength);
        }
        else if (opcode == OP_PUSHDATA4)
        {
            uint32_t dataLength;
            
            if (offset + sizeof(dataLength) > length) return nil;
            
            memcpy(&dataLength, bytes + offset + sizeof(opcode), sizeof(dataLength));
            dataLength = CFSwapInt16LittleToHost(dataLength);
            
            NSUInteger chunkLength = sizeof(opcode) + sizeof(dataLength) + dataLength;
            
            if (offset + chunkLength > length) return nil;
            
            chunk.range = NSMakeRange(offset, chunkLength);
        }
        
        return chunk;
    }
    else
    {
        // simple opcode
        BTCScriptChunk* chunk = [[BTCScriptChunk alloc] init];
        chunk.scriptData = scriptData;
        chunk.range = NSMakeRange(offset, sizeof(opcode));
        return chunk;
    }
    return nil;
}


@end








