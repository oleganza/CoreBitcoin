// Oleg Andreev <oleganza@gmail.com>

#import "BTCKey.h"

@interface BTCKey (BitcoinSignedMessage)

// Returns a signature for message prepended with "Bitcoin Signed Message:\n" line.
- (NSData*) signatureForMessage:(NSString*)message;

// Verifies message against given signature. On success returns a public key.
+ (BTCKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message;

// Verifies signature of the message with its public key.
- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message;

@end
