// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

@class BTCNetwork;
@interface BTCEncryptedBackup : NSObject

- (id) initWithBackupKey:(NSData*)backupKey;

+ (NSData*) backupKeyForNetwork:(BTCNetwork*)network masterKey:(NSData*)masterKey;

@end
