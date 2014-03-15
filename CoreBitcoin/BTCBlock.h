// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

@class BTCBlockHeader;
@interface BTCBlock : NSObject

@property(nonatomic) BTCBlockHeader* header;
@property(nonatomic) NSArray* transactions;

// Updates header.merkleRootHash by hashing transactions.
- (void) updateMerkleTree;


@end
