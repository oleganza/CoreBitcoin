// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCScript.h"

@interface BTCScript (Tests)

+ (void) runAllTests;

+ (NSArray*) invalidBitcoinQTScripts;
+ (NSArray*) validBitcoinQTScripts;

@end
