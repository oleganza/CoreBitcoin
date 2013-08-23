// Oleg Andreev <oleganza@gmail.com>

#import "BTCTransaction.h"
#import "BTCTransactionInput.h"
#import "BTCTransactionOutput.h"
#import "BTCProtocolSerialization.h"
#import "BTCData.h"

@interface BTCTransaction ()
@property(nonatomic, readwrite) NSData* transactionHash;
@property(nonatomic, readwrite) NSString* displayTransactionHash;
@property(nonatomic, readwrite) NSArray* inputs;
@property(nonatomic, readwrite) NSArray* outputs;
@property(nonatomic, readwrite) NSData* data;
@property(nonatomic, readwrite) uint32_t version;
@end

@implementation BTCTransaction

- (id) init
{
    if (self = [super init])
    {
        // init default values
        _version = BTCTransactionCurrentVersion;
        _lockTime = 0;
        _inputs = @[];
        _outputs = @[];
    }
    return self;
}

// Parses tx from data buffer.
- (id) initWithData:(NSData*)data
{
    if (self = [self init])
    {
        if (![self parseData:data]) return nil;
    }
    return self;
}

// Parses input stream (useful when parsing many transactions from a single source, e.g. a block).
- (id) initWithStream:(NSInputStream*)stream
{
    if (self = [self init])
    {
        if (![self parseStream:stream]) return nil;
    }
    return self;
}

// Constructs transaction from dictionary representation
- (id) initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [self init])
    {
        _version = (uint32_t)[dictionary[@"ver"] unsignedIntegerValue];
        _lockTime = (uint32_t)[dictionary[@"lock_time"] unsignedIntegerValue];
        
        NSMutableArray* ins = [NSMutableArray array];
        for (id dict in dictionary[@"in"])
        {
            BTCTransactionInput* txin = [[BTCTransactionInput alloc] initWithDictionary:dict];
            if (!txin) return nil;
            [ins addObject:txin];
        }
        _inputs = ins;
        
        NSMutableArray* outs = [NSMutableArray array];
        for (id dict in dictionary[@"out"])
        {
            BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] initWithDictionary:dict];
            if (!txout) return nil;
            [outs addObject:txout];
        }
        _outputs = outs;
    }
    return self;
}

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation
{
    return @{
      @"hash":      self.displayTransactionHash,
      @"ver":       @(_version),
      @"vin_sz":    @(_inputs.count),
      @"vout_sz":   @(_outputs.count),
      @"lock_time": @(_lockTime),
      @"size":      @(self.data.length),
      @"in":        [_inputs valueForKey:@"dictionaryRepresentation"],
      @"out":       [_outputs valueForKey:@"dictionaryRepresentation"],
    };
}


#pragma mark - NSObject



- (BOOL) isEqual:(BTCTransaction*)object
{
    if (![object isKindOfClass:[BTCTransaction class]]) return NO;
    return [object.transactionHash isEqual:self.transactionHash];
}

- (NSUInteger) hash
{
    if (self.transactionHash.length >= sizeof(NSUInteger))
    {
        // Interpret first bytes as a hash value
        return *((NSUInteger*)self.transactionHash.bytes);
    }
    else
    {
        return 0;
    }
}



#pragma mark - Properties


- (NSData*) transactionHash
{
    if (!_transactionHash)
    {
        _transactionHash = BTCHash256(self.data);
    }
    return _transactionHash;
}

- (NSString*) displayTransactionHash
{
    if (!_displayTransactionHash)
    {
        _displayTransactionHash = BTCHexStringFromData(BTCReversedData(self.transactionHash));
    }
    return _displayTransactionHash;
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
    
    // 4-byte version
    uint32_t ver = _version;
    [payload appendBytes:&ver length:4];
    
    // varint with number of inputs
    [payload appendData:[BTCProtocolSerialization dataForVarInt:_inputs.count]];
    
    // input payloads
    for (BTCTransactionInput* input in _inputs)
    {
        [payload appendData:input.data];
    }
    
    // varint with number of outputs
    [payload appendData:[BTCProtocolSerialization dataForVarInt:_outputs.count]];
    
    // output payloads
    for (BTCTransactionOutput* output in _outputs)
    {
        [payload appendData:output.data];
    }
    
    // 4-byte lock_time
    uint32_t lt = _lockTime;
    [payload appendBytes:&lt length:4];
    
    return payload;
}

- (void) invalidatePayload
{
    // These ivars will be recomputed next time their properties are accessed.
    _transactionHash = nil;
    _displayTransactionHash = nil;
    _data = nil;
}

- (void) setLockTime:(uint32_t)lockTime
{
    if (_lockTime == lockTime) return;
    _lockTime = lockTime;
    [self invalidatePayload];
}


#pragma mark - Methods


// Adds input script
- (void) addInput:(BTCTransactionInput*)input
{
    if (!input) return;
    _inputs = [_inputs arrayByAddingObject:input];
    [self invalidatePayload];
}

// Adds output script
- (void) addOutput:(BTCTransactionOutput*)output
{
    if (!output) return;
    _outputs = [_outputs arrayByAddingObject:output];
    [self invalidatePayload];
}

- (BOOL) isCoinbase
{
    // Coinbase transaction has one input and it must be coinbase.
    return (_inputs.count == 1 && [(BTCTransactionInput*)_inputs[0] isCoinbase]);
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
    
    if ([stream read:(uint8_t*)&_version maxLength:sizeof(_version)] != sizeof(_version)) return NO;
    
    {
        uint64_t inputsCount = 0;
        if ([BTCProtocolSerialization readVarInt:&inputsCount fromStream:stream] == 0) return NO;
        
        NSMutableArray* ins = [NSMutableArray array];
        for (uint64_t i = 0; i < inputsCount; i++)
        {
            BTCTransactionInput* input = [[BTCTransactionInput alloc] initWithStream:stream];
            if (!input) return NO;
            [ins addObject:input];
        }
        _inputs = ins;
    }

    {
        uint64_t outputsCount = 0;
        if ([BTCProtocolSerialization readVarInt:&outputsCount fromStream:stream] == 0) return NO;
            
        NSMutableArray* outs = [NSMutableArray array];
        for (uint64_t i = 0; i < outputsCount; i++)
        {
            BTCTransactionOutput* output = [[BTCTransactionOutput alloc] initWithStream:stream];
            if (!output) return NO;
            [outs addObject:output];
        }
        _outputs = outs;
    }
    
    if ([stream read:(uint8_t*)&_lockTime maxLength:sizeof(_lockTime)] != sizeof(_lockTime)) return NO;
    
    [self invalidatePayload];
    
    return YES;
}



#pragma mark - Fees


// Minimum base fee to send a transaction.
+ (BTCSatoshi) minimumFee
{
    NSNumber* n = [[NSUserDefaults standardUserDefaults] objectForKey:@"BTCTransactionMinimumFee"];
    if (!n) return 10000;
    return (BTCSatoshi)[n longLongValue];
}

+ (void) setMinimumFee:(BTCSatoshi)fee
{
    fee = MIN(fee, BTC_MAX_MONEY);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:fee] forKey:@"BTCTransactionMinimumFee"];
}

// Minimum base fee to relay a transaction.
+ (BTCSatoshi) minimumRelayFee
{
    NSNumber* n = [[NSUserDefaults standardUserDefaults] objectForKey:@"BTCTransactionMinimumRelayFee"];
    if (!n) return 10000;
    return (BTCSatoshi)[n longLongValue];
}

+ (void) setMinimumRelayFee:(BTCSatoshi)fee
{
    fee = MIN(fee, BTC_MAX_MONEY);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:fee] forKey:@"BTCTransactionMinimumRelayFee"];
}


// Minimum fee to relay the transaction
- (BTCSatoshi) minimumRelayFee
{
    return [self minimumFeeForSending:NO];
}

// Minimum fee to send the transaction
- (BTCSatoshi) minimumSendFee
{
    return [self minimumFeeForSending:YES];
}

- (BTCSatoshi) minimumFeeForSending:(BOOL)sending
{
    // See also CTransaction::GetMinFee in BitcoinQT and calculate_minimum_fee in bitcoin-ruby
    
    // BitcoinQT calculates min fee based on current block size, but it's unused and constant value is used today instead.
    NSUInteger baseBlockSize = 1000;
    // BitcoinQT has some complex formulas to determine when we shouldn't allow free txs. To be done later.
    BOOL allowFree = YES;
    
    BTCSatoshi baseFee = sending ? [BTCTransaction minimumFee] : [BTCTransaction minimumRelayFee];
    NSUInteger txSize = self.data.length;
    NSUInteger newBlockSize = baseBlockSize + txSize;
    BTCSatoshi minFee = (1 + txSize / 1000) * baseFee;
    
    if (allowFree)
    {
        if (newBlockSize == 1)
        {
            // Transactions under 10K are free
            // (about 4500 BTC if made of 50 BTC inputs)
            if (txSize < 10000)
                minFee = 0;
        }
        else
        {
            // Free transaction area
            if (newBlockSize < 27000)
                minFee = 0;
        }
    }
    
    // To limit dust spam, require base fee if any output is less than 0.01
    if (minFee < baseFee)
    {
        for (BTCTransactionOutput* txout in _outputs)
        {
            if (txout.value < BTCCent)
            {
                minFee = baseFee;
                break;
            }
        }
    }
    
    // Raise the price as the block approaches full
    if (baseBlockSize != 1 && newBlockSize >= BTC_MAX_BLOCK_SIZE_GEN/2)
    {
        if (newBlockSize >= BTC_MAX_BLOCK_SIZE_GEN)
            return BTC_MAX_MONEY;
        minFee *= BTC_MAX_BLOCK_SIZE_GEN / (BTC_MAX_BLOCK_SIZE_GEN - newBlockSize);
    }
    
    if (minFee < 0 || minFee > BTC_MAX_MONEY) minFee = BTC_MAX_MONEY;
    
    return minFee;
}



@end
