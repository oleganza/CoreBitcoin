//
//  BTCBip38EncryptedKey.h
//  CoreBitcoin
//
//  Created by Alex Zak on 16/11/2015.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTCKey.h"



extern const NSUInteger BTCBip38EncryptedKeyLength;
extern const NSUInteger BTCBip38EncryptedKeyHeaderLength;

extern const NSUInteger BTCBip38EncryptedKeyPrefixNonEC;
extern const NSUInteger BTCBip38EncryptedKeyPrefixEC;

extern const NSUInteger BTCBip38EncryptedKeyFlagsNonEC;
extern const NSUInteger BTCBip38EncryptedKeyFlagsCompressed;
extern const NSUInteger BTCBip38EncryptedKeyFlagsLotSequence;
extern const NSUInteger BTCBip38EncryptedKeyFlagsInvalid;



@interface BTCBip38EncryptedKey : NSObject

- (instancetype)initWithEncrypted:(NSString *)encrypted;
- (instancetype)initWithKey:(BTCKey *)key passphrase:(NSString *)passphrase;

- (NSString *)encrypted;
- (NSData *)encryptedData;
- (uint16_t)prefix;
- (uint8_t)flags;
- (uint32_t)addressHash;
- (BOOL)isEC;
- (BOOL)isCompressed;

- (BTCKey *)decryptedKeyWithPassphrase:(NSString *)passphrase;

@end



@interface BTCKey (bip38)

- (BTCBip38EncryptedKey *)encryptedBIP38KeyWithPassphrase:(NSString *)passphrase;

@end

