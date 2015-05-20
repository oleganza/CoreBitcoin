// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCAddress.h"

@interface BTCAssetAddress : BTCAddress
@property(nonatomic, readonly) BTCAddress* bitcoinAddress;
+ (instancetype) addressWithBitcoinAddress:(BTCAddress*)btcAddress;
@end
