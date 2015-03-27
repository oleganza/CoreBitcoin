// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCProtocolBuffers.h"

typedef NS_ENUM(NSInteger, BTCProtobufType) {
    BTCProtobufTypeVarInt          = 0, // int32, int64, uint32, uint64, sint32, sint64, bool, enum
    BTCProtobufType64bit           = 1, // fixed64, sfixed64, double
    BTCProtobufTypeLengthDelimited = 2, // string, bytes, embedded messages, packed repeated fields
    BTCProtobufType32bit           = 5, // fixed32, sfixed32, float
};

@implementation BTCProtocolBuffers

// Returns a variable-length integer value at a given offset in source data.
+ (uint64_t) varIntAtOffset:(NSInteger*)offset fromData:(NSData*)src {
    uint64_t varInt = 0;
    uint8_t b = 0x80;
    NSUInteger i = 0;
    while ((b & 0x80) && *offset < src.length) {
        b = ((const uint8_t *)src.bytes)[(*offset)++];
        varInt += (uint64_t)(b & 0x7f) << 7*i++;
    }
    return varInt;
}

// Returns a length-delimited data at a given offset in source data.
+ (NSData *) lenghtDelimitedDataAtOffset:(NSInteger *)offset fromData:(NSData*)src {
    NSData *lengthDelimitedData = nil;
    NSUInteger length = (NSUInteger)[self varIntAtOffset:offset fromData:src];
    if (*offset + length <= src.length) {
        lengthDelimitedData = [src subdataWithRange:NSMakeRange(*offset, length)];
    }
    *offset += length;
    return lengthDelimitedData;
}

// Returns either int or data depending on field type, and returns a field key.
+ (NSInteger) fieldAtOffset:(NSInteger *)offset int:(uint64_t *)i data:(NSData **)d fromData:(NSData*)src {
    NSInteger key = (NSInteger)[self varIntAtOffset:offset fromData:src];
    uint64_t varInt = 0;
    NSData *lengthDelimitedData = nil;

    switch (key & 0x07) {
        case BTCProtobufTypeVarInt: {
            varInt = [self varIntAtOffset:offset fromData:src];
            if (i) *i = varInt;
            break;
        }
        case BTCProtobufType64bit: { // not used by BIP70
            *offset += sizeof(uint64_t);
            break;
        }
        case BTCProtobufTypeLengthDelimited: {
            lengthDelimitedData = [self lenghtDelimitedDataAtOffset:offset fromData:src];
            if (d) *d = lengthDelimitedData;
            break;
        }
        case BTCProtobufType32bit: { // not used by BIP70
            *offset += sizeof(uint32_t);
            break;
        }
        default: break;
    }

    return key >> 3;
}

+ (void) writeVarInt:(uint64_t)i toData:(NSMutableData*)dst {
    do {
        uint8_t b = i & 0x7f;
        i >>= 7;
        if (i > 0) b |= 0x80;
        [dst appendBytes:&b length:1];
    } while (i > 0);
}

+ (void) writeInt:(uint64_t)i withKey:(NSInteger)key toData:(NSMutableData*)dst {
    [self writeVarInt:(key << 3) + BTCProtobufTypeVarInt toData:dst];
    [self writeVarInt:i toData:dst];
}

+ (void) writeLengthDelimitedData:(NSData*)data toData:(NSMutableData*)dst {
    [self writeVarInt:data.length toData:dst];
    [dst appendData:data];
}

+ (void) writeData:(NSData*)data withKey:(NSInteger)key toData:(NSMutableData*)dst {
    [self writeVarInt:(key << 3) + BTCProtobufTypeLengthDelimited toData:dst];
    [self writeLengthDelimitedData:data toData:dst];
}

+ (void) writeString:(NSString*)string withKey:(NSInteger)key toData:(NSMutableData*)dst {
    [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withKey:key toData:dst];
}

@end

