// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

extern NSString* const BTCErrorDomain;

typedef NS_ENUM(NSUInteger, BTCErrorCode) {
    
    // Canonical pubkey/signature check errors
    BTCErrorNonCanonicalPublicKey        = 4001,
    BTCErrorNonCanonicalScriptSignature  = 4002,
    
    // Script verification errors
    BTCErrorScriptError                  = 5001,
};