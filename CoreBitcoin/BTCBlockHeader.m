// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCBlockHeader.h"
#import "BTCData.h"

@implementation BTCBlockHeader

+ (NSUInteger) headerLength
{
    return 4 + 32 + 32 + 4 + 4 + 4;
}

- (id) init
{
    if (self = [super init])
    {
        // init default values
        _version = BTCBlockCurrentVersion;
        _previousBlockHash = BTCZero256();
        _merkleRootHash = BTCZero256();
        _time = 0;
        _difficultyTarget = 0;
        _nonce = 0;
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

- (NSData*) blockHash
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
    
    [data appendData:self.previousBlockHash];
    [data appendData:self.merkleRootHash];
    
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
    
    // TODO
    
    return YES;
}

- (BOOL) parseStream:(NSStream*)stream
{
    // TODO
    
    return YES;
}


@end
