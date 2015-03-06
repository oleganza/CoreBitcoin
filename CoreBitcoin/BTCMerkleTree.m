// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCMerkleTree.h"
#import "BTCData.h"

@interface BTCMerkleTree ()
@property(nonatomic) NSArray* hashes;
@end

@implementation BTCMerkleTree

- (id) initWithHashes:(NSArray*)hashes {
    if (hashes.count == 0) return nil;
    if (self = [super init]) {
        self.hashes = hashes;
    }
    return self;
}

- (id) initWithTransactions:(NSArray*)transactions {
    if (transactions.count == 0) return nil;
    return [self initWithHashes:[transactions valueForKey:@"transactionHash"]];
}

- (NSData*) merkleRoot {
    // Based on original Satoshi implementation.
    NSMutableArray* tree = [self.hashes mutableCopy];

    NSInteger j = 0;
    for (NSInteger length = (NSInteger)tree.count; length > 1; length = (length + 1) / 2) {
        for (NSInteger i = 0; i < length; i += 2) {
            NSInteger i2 = MIN(i + 1, length - 1);
            NSData* hash = BTCHash256Concat(tree[j+i], tree[j+i2]);
            [tree addObject:hash];
        }
        j += length;
    }
    return tree.lastObject;
}

@end
