// Oleg Andreev <oleganza@gmail.com>

#import "BTCTransaction.h"
#import "BTCTransactionInput.h"
#import "BTCTransactionOutput.h"
#import "BTCProtocolSerialization.h"
#import "BTCData.h"
#import "BTCScript.h"
#import "BTCErrors.h"

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

- (id) copyWithZone:(NSZone *)zone
{
    BTCTransaction* tx = [[BTCTransaction alloc] init];
    tx.transactionHash = self.transactionHash;
    tx.displayTransactionHash = self.displayTransactionHash;
    tx.inputs = [[NSArray alloc] initWithArray:self.inputs copyItems:YES]; // so each element is copied individually
    tx.outputs = [[NSArray alloc] initWithArray:self.outputs copyItems:YES]; // so each element is copied individually
    for (BTCTransactionInput* txin in tx.inputs)
    {
        txin.transaction = self;
    }
    for (BTCTransactionOutput* txout in tx.outputs)
    {
        txout.transaction = self;
    }
    tx.data = [self.data copy];
    tx.version = self.version;
    tx.lockTime = self.lockTime;
    return tx;
}



#pragma mark - Properties


- (NSData*) transactionHash
{
    return BTCHash256(self.data);
//    if (!_transactionHash)
//    {
//        _transactionHash = BTCHash256(self.data);
//    }
//    return _transactionHash;
}

- (NSString*) displayTransactionHash
{
    return BTCHexStringFromData(BTCReversedData(self.transactionHash));
//    if (!_displayTransactionHash)
//    {
//        _displayTransactionHash = BTCHexStringFromData(BTCReversedData(self.transactionHash));
//    }
//    return _displayTransactionHash;
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
    
    if (!(input.transaction == nil || input.transaction == self))
    {
        @throw [NSException exceptionWithName:@"BTCTransaction consistency error!" reason:@"Can't add an input to a transaction when it references another transaction." userInfo:nil];
        return;
    }
    input.transaction = self;
    _inputs = [_inputs arrayByAddingObject:input];
    [self invalidatePayload];
}

// Adds output script
- (void) addOutput:(BTCTransactionOutput*)output
{
    if (!output) return;
    
    if (!(output.transaction == nil || output.transaction == self))
    {
        @throw [NSException exceptionWithName:@"BTCTransaction consistency error!" reason:@"Can't add an output to a transaction when it references another transaction." userInfo:nil];
        return;
    }
    output.index = BTCTransactionOutputIndexUnknown;
    output.transactionHash = nil;
    output.transaction = self;
    _outputs = [_outputs arrayByAddingObject:output];
    [self invalidatePayload];
}

- (void) removeAllInputs
{
    _inputs = @[];
    [self invalidatePayload];
}

- (void) removeAllOutputs
{
    for (BTCTransactionOutput* txout in _outputs)
    {
        txout.transaction = nil;
    }
    _outputs = @[];
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


#pragma mark - Signing a transaction



// Hash for signing a transaction.
// You should supply the output script of the previous transaction, desired hash type and input index in this transaction.
- (NSData*) signatureHashForScript:(BTCScript*)subscript inputIndex:(uint32_t)inputIndex hashType:(BTCSignatureHashType)hashType error:(NSError**)errorOut
{
    // Create a temporary copy of the transaction to apply modifications to it.
    BTCTransaction* tx = [self copy];
    
    // We may have a scriptmachine instantiated without a transaction (for testing),
    // but it should not use signature checks then.
    if (!tx || inputIndex == 0xFFFFFFFF)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain
                                                      code:BTCErrorScriptError
                                                  userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Transaction and valid input index must be provided for signature verification.", @"")}];
        return nil;
    }
    
    // Note: BitcoinQT returns a 256-bit little-endian number 1 in such case, but it does not matter
    // because it would crash before that in CScriptCheck::operator()(). We normally won't enter this condition
    // if script machine is instantiated with initWithTransaction:inputIndex:, but if it was just -init-ed, it's better to check.
    if (inputIndex >= tx.inputs.count)
    {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain
                                                      code:BTCErrorScriptError
                                                  userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:
                                                     NSLocalizedString(@"Input index is out of bounds for transaction: %d >= %d.", @""),
                                                                                        (int)inputIndex, (int)tx.inputs.count]}];
        return nil;
    }
    
    // In case concatenating two scripts ends up with two codeseparators,
    // or an extra one at the end, this prevents all those possible incompatibilities.
    // Note: this normally never happens because there is no use for OP_CODESEPARATOR.
    // But we have to do that cleanup anyway to not break on rare transaction that use that for lulz.
    // Also: we modify the same subscript which is used several times for multisig check, but that's what BitcoinQT does as well.
    [subscript deleteOccurrencesOfOpcode:OP_CODESEPARATOR];
    
    // Blank out other inputs' signature scripts
    // and replace our input script with a subscript (which is typically a full output script from the previous transaction).
    for (BTCTransactionInput* txin in tx.inputs)
    {
        txin.signatureScript = [[BTCScript alloc] init];
    }
    ((BTCTransactionInput*)tx.inputs[inputIndex]).signatureScript = subscript;
    
    // Blank out some of the outputs depending on BTCSignatureHashType
    // Default is SIGHASH_ALL - all inputs and outputs are signed.
    if ((hashType & SIGHASH_OUTPUT_MASK) == SIGHASH_NONE)
    {
        // Wildcard payee - we can pay anywhere.
        [tx removeAllOutputs];
        
        // Blank out others' input sequence numbers to let others update transaction at will.
        for (NSUInteger i = 0; i < tx.inputs.count; i++)
        {
            if (i != inputIndex)
            {
                ((BTCTransactionInput*)tx.inputs[i]).sequence = 0;
            }
        }
    }
    // Single mode assumes we sign an output at the same index as an input.
    // Outputs before the one we need are blanked out. All outputs after are simply removed.
    else if ((hashType & SIGHASH_OUTPUT_MASK) == SIGHASH_SINGLE)
    {
        // Only lock-in the txout payee at same index as txin.
        uint32_t outputIndex = inputIndex;
        
        // If outputIndex is out of bounds, BitcoinQT is returning a 256-bit little-endian 0x01 instead of failing with error.
        // We should do the same to stay compatible.
        if (outputIndex >= tx.outputs.count)
        {
            static unsigned char littleEndianOne[32] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
            return [NSData dataWithBytes:littleEndianOne length:32];
        }
        
        // All outputs before the one we need are blanked out. All outputs after are simply removed.
        // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
        BTCTransactionOutput* myOutput = tx.outputs[outputIndex];
        [tx removeAllOutputs];
        for (int i = 0; i < outputIndex; i++)
        {
            [tx addOutput:[[BTCTransactionOutput alloc] init]];
        }
        [tx addOutput:myOutput];
        
        // Blank out others' input sequence numbers to let others update transaction at will.
        for (NSUInteger i = 0; i < tx.inputs.count; i++)
        {
            if (i != inputIndex)
            {
                ((BTCTransactionInput*)tx.inputs[i]).sequence = 0;
            }
        }
    }
    
    // Blank out other inputs completely. This is not recommended for open transactions.
    if (hashType & SIGHASH_ANYONECANPAY)
    {
        BTCTransactionInput* input = tx.inputs[inputIndex];
        [tx removeAllInputs];
        [tx addInput:input];
    }
    
    [tx invalidatePayload];
    
    // Important: we have to hash transaction together with its hash type.
    
    NSMutableData* fulldata = [tx.data mutableCopy];
    
    uint32_t hashType32 = OSSwapHostToLittleInt32((uint32_t)hashType);
    [fulldata appendBytes:&hashType32 length:sizeof(hashType32)];
    
    NSData* hash = BTCHash256(fulldata);
    
//    NSLog(@"\n----------------------\n");
//    NSLog(@"TX: %@", BTCHexStringFromData(fulldata));
//    NSLog(@"TX SUBSCRIPT: %@ (%@)", BTCHexStringFromData(subscript.data), subscript);
//    NSLog(@"TX HASH: %@", BTCHexStringFromData(hash));
//    NSLog(@"TX PLIST: %@", tx.dictionaryRepresentation);
    
    return hash;
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
