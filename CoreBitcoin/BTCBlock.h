// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

@class BTCBlockHeader;
@interface BTCBlock : NSObject

@property(nonatomic) BTCBlockHeader* header;
@property(nonatomic) NSArray* transactions;

@property(nonatomic, readonly) NSData* blockHash;
@property(nonatomic, readonly) NSData* data; // serialized form of the block

// Updates header.merkleRootHash by hashing transactions.
- (void) updateMerkleTree;


@end
