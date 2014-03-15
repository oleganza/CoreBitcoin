// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTC256.h"

static const int32_t BTCBlockCurrentVersion = 2;
static const NSUInteger BTCBlockHeaderLength = 4 + 32 + 32 + 4 + 4 + 4; // 80 bytes

@interface BTCBlockHeader : NSObject

@property(nonatomic) int32_t version;
@property(nonatomic) BTC256 previousBlockHash;
@property(nonatomic) BTC256 merkleRootHash;
@property(nonatomic) uint32_t time;
@property(nonatomic) uint32_t difficultyTarget; // aka nBits
@property(nonatomic) uint32_t nonce;

@property(nonatomic, readonly) BTC256 hash;
@property(nonatomic, readonly) NSData* data; // binary representation

// Parses block header from the data buffer.
- (id) initWithData:(NSData*)data;

// Parses input stream (same format used by initWithData:)
- (id) initWithStream:(NSInputStream*)stream;

@end
