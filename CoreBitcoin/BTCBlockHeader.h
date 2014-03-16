// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

static const int32_t BTCBlockCurrentVersion = 2;

@interface BTCBlockHeader : NSObject

@property(nonatomic) int32_t version;
@property(nonatomic) NSData* previousBlockHash;
@property(nonatomic) NSData* merkleRootHash;
@property(nonatomic) uint32_t time;
@property(nonatomic) uint32_t difficultyTarget; // aka nBits
@property(nonatomic) uint32_t nonce;

@property(nonatomic, readonly) NSData* blockHash;
@property(nonatomic, readonly) NSData* data;

+ (NSUInteger) headerLength;

@end
