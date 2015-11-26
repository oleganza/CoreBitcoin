// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCData.h"
#import "BTCBigNumber.h"
#import "BTCSecretSharing.h"

@interface BTCSecretSharing ()
@property(nonatomic, readwrite) BTCSecretSharingVersion version;
@end

@implementation BTCSecretSharing

// Returns a configuration for compact 128-bit secrets with up to 16 shares.
- (id __nonnull) initWithVersion:(BTCSecretSharingVersion)version {
    if (self = [super init]) {
        if (version != BTCSecretSharingVersionCompact128) {
            [NSException raise:@"BTCSecretSharing supports only BTCSecretSharingVersionCompact128 at the moment" format:@""];
        }
        self.version = version;

    }
    return self;
}

- (BTCBigNumber*) order128 {
    // 0xffffffffffffffffffffffffffffff61
    return [[BTCBigNumber alloc] initWithString:@"ffffffffffffffffffffffffffffff61" base:16];
}

- (NSArray* __nonnull) splitSecret:(NSData* __nonnull)secret threshold:(NSInteger)m shares:(NSInteger)n error:(NSError**)errorOut {

    return @[];
}

- (NSData* __nonnull) joinShares:(NSArray* __nonnull)shares error:(NSError**)errorOut {

    return [@"" dataUsingEncoding:NSUTF8StringEncoding];
}



@end
