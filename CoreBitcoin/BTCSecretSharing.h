// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTCSecretSharingVersion) {
    // Identifies configuration for compact 128-bit secrets with up to 16 shares.
    BTCSecretSharingVersionCompact128 = 1,
};

@interface BTCSecretSharing : NSObject

@property(nonatomic, readonly) BTCSecretSharingVersion version;

- (id __nonnull) initWithVersion:(BTCSecretSharingVersion)version;

- (NSArray* __nonnull) splitSecret:(NSData* __nonnull)secret threshold:(NSInteger)m shares:(NSInteger)n error:(NSError**)errorOut;

- (NSData* __nonnull) joinShares:(NSArray* __nonnull)shares error:(NSError**)errorOut;

@end