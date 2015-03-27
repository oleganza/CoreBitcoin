// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCEncryptedBackup.h"
#import "BTCData.h"
#import "BTCNetwork.h"

@interface BTCEncryptedBackup ()
@property(nonatomic, readwrite) NSData* backupKey;
@end

@implementation BTCEncryptedBackup

- (id) initWithBackupKey:(NSData*)backupKey {
    if (!backupKey) return nil;
    if (self = [super init]) {
        self.backupKey = backupKey;
    }
    return self;
}

+ (NSData*) backupKeyForNetwork:(BTCNetwork*)network masterKey:(NSData*)masterKey {
    if (!network || network.isMainnet) {
        return BTCHMACSHA256(masterKey, [@"Automatic Backup Key Mainnet" dataUsingEncoding:NSASCIIStringEncoding]);
    } else {
        return BTCHMACSHA256(masterKey, [@"Automatic Backup Key Testnet" dataUsingEncoding:NSASCIIStringEncoding]);
    }
}

@end
