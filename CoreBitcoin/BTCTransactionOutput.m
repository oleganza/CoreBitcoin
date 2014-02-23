// Oleg Andreev <oleganza@gmail.com>

#import "BTCTransaction.h"
#import "BTCTransactionOutput.h"
#import "BTCScript.h"
#import "BTCAddress.h"
#import "BTCData.h"
#import "BTCProtocolSerialization.h"

@interface BTCTransactionOutput ()
@property(nonatomic, readwrite) NSData* data;
@end

@implementation BTCTransactionOutput

+ (instancetype) outputWithValue:(BTCSatoshi)value address:(BTCAddress*)address
{
    BTCTransactionOutput* output = [[BTCTransactionOutput alloc] init];
    output.value = value;
    output.script = [[BTCScript alloc] initWithAddress:address];
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

- (id) copyWithZone:(NSZone *)zone
{
    BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
    txout.value = self.value;
    txout.script = [self.script copy];
    return txout;
}

- (NSData*) data
{
    return [self computePayload];
//    if (!_data)
//    {
//        _data = [self computePayload];
//    }
//    return _data;
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
    [_transaction invalidatePayload];
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

- (NSString*) description
{
    NSData* txhash = self.transactionHash;
    return [NSString stringWithFormat:@"<%@:0x%p%@%@ %@ BTC '%@'%@>", [self class], self,
            (txhash ? [NSString stringWithFormat:@" %@", BTCHexStringFromData(txhash)]: @""),
            (_index == BTCTransactionOutputIndexUnknown ? @"" : [NSString stringWithFormat:@":%d", _index]),
            [self formattedBTCValue:_value],
            _script.string,
            (_confirmations == NSNotFound ? @"" : [NSString stringWithFormat:@" %d confirmations", (unsigned int)_confirmations])];
}

- (NSString*) formattedBTCValue:(BTCSatoshi)value
{
    return [NSString stringWithFormat:@"%lld.%@", value / BTCCoin, [NSString stringWithFormat:@"%08lld", value % BTCCoin]];
}

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation
{
    return @{
             @"value": [self formattedBTCValue:_value],
             // TODO: like in BTCTransactionInput, have an option to put both "asm" and "hex" representations of the script.
             @"scriptPubKey": _script.string ?: @"",
             };
}

- (uint32_t) index
{
    // Remember the index as it does not change when we add more outputs.
    if (_transaction && _index == BTCTransactionOutputIndexUnknown)
    {
        NSUInteger idx = [_transaction.outputs indexOfObject:self];
        if (idx != NSNotFound)
        {
            _index = (uint32_t)idx;
        }
    }
    return _index;
}

- (NSData*) transactionHash
{
    // Do not remember transaction hash as it changes when we add another output or change some metadata of the tx.
    if (_transactionHash) return _transactionHash;
    if (_transaction) return _transaction.transactionHash;
    return nil;
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
