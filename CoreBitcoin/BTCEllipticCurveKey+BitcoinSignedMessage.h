// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey.h"

@interface BTCEllipticCurveKey (BitcoinSignedMessage)

// Returns a signature for message prepended with "Bitcoin Signed Message:\n" line.
- (NSData*) signatureForMessage:(NSString*)message;

// Verifies message against given signature. On success returns a public key.
+ (BTCEllipticCurveKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message;

// Verifies signature of the message with its public key.
- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message;

@end
