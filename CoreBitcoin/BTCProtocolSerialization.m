// Oleg Andreev <oleganza@gmail.com>

#import "BTCProtocolSerialization.h"

@implementation BTCProtocolSerialization


// varInt here refers to CompactSize in Satoshi code.
// BitcoinQT later added CVarInt which is different, more compact format used in block storage.
//  Value           Storage length     Format
//  < 0xfd          1                  uint8_t
// <= 0xffff        3                  0xfd followed by the value as uint16_t
// <= 0xffffffff    5                  0xfe followed by the value as uint32_t
//  > 0xffffffff    9                  0xff followed by the value as uint64_t

+ (NSUInteger) readVarInt:(uint64_t*)valueOut fromData:(NSData*)data
{
    NSUInteger dataLength = data.length;
    if (dataLength == 0) return 0;
    
    unsigned char size = ((unsigned char*)data.bytes)[0];
    
    if (size < 0xfd)
    {
        if (valueOut) *valueOut = size;
        return 1;
    }
    else if (size == 0xfd)
    {
        if (dataLength < 3) return 0;
        if (valueOut) *valueOut = ((unsigned short*)((uint8_t*)data.bytes+1))[0];
        return 3;
    }
    else if (size == 0xfe)
    {
        if (dataLength < 5) return 0;
        if (valueOut) *valueOut = ((unsigned int*)((uint8_t*)data.bytes+1))[0];
        return 5;
    }
    else
    {
        if (dataLength < 9) return 0;
        if (valueOut) *valueOut = ((uint64_t*)((uint8_t*)data.bytes+1))[0];
        return 9;
    }
    return 0;
}

+ (NSUInteger) readVarInt:(uint64_t*)valueOut fromStream:(NSInputStream*)stream
{
    if (!stream) return 0;
    
    unsigned char size = 0;
    NSInteger readSize = [stream read:&size maxLength:sizeof(size)];
    
    if (stream.streamStatus == NSStreamStatusClosed) return 0;
    if (stream.streamStatus == NSStreamStatusNotOpen) return 0;
    
    if (readSize < (NSInteger)sizeof(size))
    {
        return 0;
    }
    
    if (size < 0xfd)
    {
        if (valueOut) *valueOut = size;
        return 1;
    }
    else if (size == 0xfd)
    {
        unsigned short value = 0;
        NSInteger readSize = [stream read:(uint8_t*)&value maxLength:sizeof(value)];
        if (readSize < sizeof(value)) return 0;
        if (valueOut) *valueOut = value;
        return 1 + sizeof(value);
    }
    else if (size == 0xfe)
    {
        unsigned int value = 0;
        NSInteger readSize = [stream read:(uint8_t*)&value maxLength:sizeof(value)];
        if (readSize < sizeof(value)) return 0;
        if (valueOut) *valueOut = value;
        return 1 + sizeof(value);
    }
    else
    {
        uint64_t value = 0;
        NSInteger readSize = [stream read:(uint8_t*)&value maxLength:sizeof(value)];
        if (readSize < sizeof(value)) return 0;
        if (valueOut) *valueOut = value;
        return 1 + sizeof(value);
    }
}

+ (NSData*) readVarStringFromData:(NSData*)data
{
    uint64_t length = 0;
    NSUInteger varIntLength = [self readVarInt:&length fromData:data];
    if (varIntLength == 0) return nil;
    
    if (data.length < (varIntLength + length)) return nil;
    
    return [data subdataWithRange:NSMakeRange(varIntLength, length)];
}

+ (NSData*) readVarStringFromStream:(NSInputStream*)stream
{
    uint64_t length = 0;
    NSUInteger varIntLength = [self readVarInt:&length fromStream:stream];
    if (varIntLength == 0) return nil;
    
    NSMutableData* data = [NSMutableData dataWithLength:length];
    if (length > 0)
    {
        [stream read:data.mutableBytes maxLength:length];
    }
    return data;
}


+ (NSData*) dataForVarInt:(uint64_t)value
{
    if (value < 0xfd)
    {
        unsigned char size = value;
        return [NSData dataWithBytes:&size length:sizeof(size)];
    }
    else if (value <= 0xffff)
    {
        unsigned char size = 0xfd;
        unsigned short compactValue = value;
        NSMutableData* data = [NSMutableData dataWithLength:1 + sizeof(compactValue)];
        [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&size];
        [data replaceBytesInRange:NSMakeRange(1, sizeof(compactValue)) withBytes:&compactValue];
        return data;
    }
    else if (value <= 0xffffffffUL)
    {
        unsigned char size = 0xfe;
        unsigned int compactValue = (unsigned int)value;
        NSMutableData* data = [NSMutableData dataWithLength:1 + sizeof(compactValue)];
        [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&size];
        [data replaceBytesInRange:NSMakeRange(1, sizeof(compactValue)) withBytes:&compactValue];
        return data;
    }
    else
    {
        unsigned char size = 0xff;
        uint64_t compactValue = value;
        NSMutableData* data = [NSMutableData dataWithLength:1 + sizeof(compactValue)];
        [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&size];
        [data replaceBytesInRange:NSMakeRange(1, sizeof(compactValue)) withBytes:&compactValue];
        return data;
    }
}

// Prepends binary string with its length in varInt format.
+ (NSData*) dataForVarString:(NSData*)binaryString
{
    if (!binaryString) return nil;
    
    NSMutableData* data = [[self dataForVarInt:binaryString.length] mutableCopy];
    [data appendData:binaryString];
    return data;
}


@end

