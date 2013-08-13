// Oleg Andreev <oleganza@gmail.com>

#import "BTCTransactionOutput.h"
#import "BTCScript.h"
#import "BTCProtocolSerialization.h"

@interface BTCTransactionOutput ()
@property(nonatomic, readwrite) NSData* data;
@end

@implementation BTCTransactionOutput

+ (instancetype) outputWithValue:(BTCSatoshi)value address:(NSString*)address
{
    BTCTransactionOutput* output = [[BTCTransactionOutput alloc] init];
    output.value = value;
    output.script = [BTCScript scriptWithAddress:address];
    return output;
}

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
    
    [payload appendBytes:&_value length:sizeof(_value)];
    
    NSData* scriptData = _script.data ?: [NSData data];
    [payload appendData:[BTCProtocolSerialization dataForVarInt:scriptData.length]];
    [payload appendData:scriptData];
    
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
    
    // Read value
    if ([stream read:(uint8_t*)(&_value) maxLength:sizeof(_value)] != sizeof(_value)) return NO;
    
    // Read script
    NSData* scriptData = [BTCProtocolSerialization readVarStringFromStream:stream];
    if (!scriptData) return NO;
    _script = [[BTCScript alloc] initWithData:scriptData];
    
    return YES;
}


@end
