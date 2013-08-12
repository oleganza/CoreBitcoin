// Oleg Andreev <oleganza@gmail.com>

#import "BTCTransactionOutput.h"
#import "BTCScript.h"
#import "BTCProtocolSerialization.h"

@interface BTCTransactionOutput ()
@property(nonatomic, readwrite) NSData* data;
@end

@implementation BTCTransactionOutput

- (id) init
{
    if (self = [super init])
    {
        _value = -1;
        _script = [[BTCScript alloc] init];
    }
    return self;
}

// Parses tx input from a data buffer.
- (id) initWithData:(NSData*)data
{
    if (self = [self init])
    {
        if (![self parseData:data]) return nil;
    }
    return self;
}

// Read tx input from the stream.
- (id) initWithStream:(NSInputStream*)stream
{
    if (self = [self init])
    {
        if (![self parseStream:stream]) return nil;
    }
    return self;
}

// Constructs transaction input from a dictionary representation
- (id) initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [self init])
    {
        NSString* valueString = dictionary[@"value"];
        if (!valueString) valueString = @"0";
        
        // Parse amount.
        // "12" => 1,200,000,000 satoshis (12 BTC)
        // "4.5" => 450,000,000 satoshis
        // "0.12000000" => 12,000,000 satoshis
        NSArray* comps = [valueString componentsSeparatedByString:@"."];
        
        _value = 0;
        if (comps.count >= 1) _value += BTCCoin * [(NSString*)comps[0] integerValue];
        if (comps.count >= 2) _value += [[(NSString*)comps[1] stringByPaddingToLength:8 withString:@"0" startingAtIndex:0] longLongValue];
        
        NSString* scriptString = dictionary[@"scriptPubKey"] ?: @"";
        _script = [[BTCScript alloc] initWithString:scriptString];
    }
    return self;
}

- (NSData*) data
{
    if (!_data)
    {
        _data = [self computePayload];
    }
    return _data;
}

- (NSData*) computePayload
{
    NSMutableData* payload = [NSMutableData data];
    
    // TODO
    
    [payload appendBytes:&_value length:sizeof(_value)];
    
//    buf =  [ @value ].pack("Q")
//    buf << Protocol.pack_var_int(@pk_script_length)
//    buf << @pk_script if @pk_script_length > 0
//    buf
    
//    [payload appendData:_previousHash];
//    [payload appendBytes:&_previousIndex length:4];
//    
//    NSData* scriptData = _signatureScript.data;
//    [payload appendData:[BTCProtocolSerialization dataForVarInt:scriptData.length]];
//    [payload appendData:scriptData];
//    
//    [payload appendBytes:&_sequence length:4];
    
    return payload;
}

- (void) invalidatePayload
{
    _data = nil;
}

- (void) setValue:(BTCSatoshi)value
{
    if (_value == value) return;
    _value = value;
    [self invalidatePayload];
}

- (void) setScript:(BTCScript *)script
{
    if (_script == script) return;
    _script = script;
    [self invalidatePayload];
}

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation
{
    return @{
             @"value": [NSString stringWithFormat:@"%lld.%@", _value / BTCCoin, [[NSString stringWithFormat:@"%lld", _value % BTCCoin] stringByPaddingToLength:8 withString:@"0" startingAtIndex:0]],
             @"scriptPubKey": _script.string ?: @"",
    };
}








#pragma mark - Serialization and parsing



- (BOOL) parseData:(NSData*)data
{
    if (!data) return NO;
    NSInputStream* stream = [NSInputStream inputStreamWithData:data];
    [stream open];
    BOOL result = [self parseStream:stream];
    [stream close];
    return result;
}

- (BOOL) parseStream:(NSInputStream*)stream
{
    if (!stream) return NO;
    if (stream.streamStatus == NSStreamStatusClosed) return NO;
    if (stream.streamStatus == NSStreamStatusNotOpen) return NO;

    // TODO
    
//    // Read previousHash
//    uint8_t hash[BTCTxHashLength] = {0};
//    if ([stream read:(uint8_t*)hash maxLength:sizeof(hash)] != sizeof(hash)) return NO;
//    _previousHash = [NSData dataWithBytes:hash length:sizeof(hash)];
//    
//    // Read previousIndex
//    if ([stream read:(uint8_t*)(&_previousIndex) maxLength:sizeof(_previousIndex)] != sizeof(_previousIndex)) return NO;
//    
//    // Read signature script
//    NSData* signatureScriptData = [BTCProtocolSerialization readVarStringFromStream:stream];
//    if (!signatureScriptData) return NO;
//    _signatureScript = [[BTCScript alloc] initWithData:signatureScriptData];
//    
//    // Read sequence
//    if ([stream read:(uint8_t*)(&_sequence) maxLength:sizeof(_sequence)] != sizeof(_sequence)) return NO;
    
    return YES;
}


@end
