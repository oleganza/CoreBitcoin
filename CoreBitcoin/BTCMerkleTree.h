// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

@interface BTCMerkleTree : NSObject

@property(nonatomic, readonly) NSData* merkleRoot;

- (id) initWithHashes:(NSArray*)hashes;

- (id) initWithTransactions:(NSArray*)transactions;

@end
