#import <Foundation/Foundation.h>

extern NSString* const BTCErrorDomain;

typedef NS_ENUM(NSUInteger, BTCErrorCode) {
    
    // Canonical checks
    BTCErrorNonCanonicalPublicKey        = 4001,
    BTCErrorNonCanonicalScriptSignature  = 4002,
};