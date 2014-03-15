// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCBlockHeader.h"
#import "BTCData.h"

@implementation BTCBlockHeader

- (id) init
{
    if (self = [super init])
    {
        // init default values
        _version           = BTCBlockCurrentVersion;
        _previousBlockHash = BTC256Zero;
        _merkleRootHash    = BTC256Zero;
        _time              = 0;
        _difficultyTarget  = 0;
        _nonce             = 0;
    }
    return self;
}

// Parses block header from the data buffer.
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

- (BTC256) hash
{
    return BTCHash256(self.data);
}

- (NSData*) data
{
    return [self computePayload];
}

- (NSData*) computePayload
{
    NSMutableData* data = [NSMutableData data];

    int32_t version = OSSwapHostToLittleInt32(_version);
    [data appendBytes:&version length:sizeof(version)];
    
    [data appendBytes:&_previousBlockHash length:sizeof(_previousBlockHash)];
    [data appendBytes:&_merkleRootHash length:sizeof(_merkleRootHash)];
    
    uint32_t time = OSSwapHostToLittleInt32(_time);
    [data appendBytes:&time length:sizeof(time)];

    uint32_t target = OSSwapHostToLittleInt32(_difficultyTarget);
    [data appendBytes:&target length:sizeof(target)];

    uint32_t nonce = OSSwapHostToLittleInt32(_nonce);
    [data appendBytes:&nonce length:sizeof(nonce)];
    
    return data;
}

- (BOOL) parseData:(NSData*)data
{
    if (!data) return NO;
    if (data.length < BTCBlockHeaderLength) return NO;
    
    return [self parseBytes:data.bytes];
}

- (BOOL) parseStream:(NSInputStream*)stream
{
    if (!stream) return NO;
    if (stream.streamStatus == NSStreamStatusClosed) return NO;
    if (stream.streamStatus == NSStreamStatusNotOpen) return NO;
    
    const int length = BTCBlockHeaderLength;
    unsigned char header[length];
    if ([stream read:(uint8_t*)header maxLength:length] != length) return NO;
    
    return [self parseBytes:header];
}

// Private method, assumes bytes array is already at least BTCBlockHeaderLength long.
- (BOOL) parseBytes:(const unsigned char*)bytes
{
    int offset = 0;
    _version = (int32_t)OSSwapLittleToHostConstInt32(*((const uint32_t*)(bytes + offset)));
    offset += sizeof(_version);
    
    memcpy(&_previousBlockHash, (bytes + offset), 32);
    offset += 32;
    
    memcpy(&_merkleRootHash, (bytes + offset), 32);
    offset += 32;
    
    _time = OSSwapLittleToHostConstInt32(*((const uint32_t*)(bytes + offset)));
    offset += sizeof(_time);
    
    _difficultyTarget = OSSwapLittleToHostConstInt32(*((const uint32_t*)(bytes + offset)));
    offset += sizeof(_difficultyTarget);

    _nonce = OSSwapLittleToHostConstInt32(*((const uint32_t*)(bytes + offset)));
    offset += sizeof(_nonce);
    
    return YES;
}


@end
