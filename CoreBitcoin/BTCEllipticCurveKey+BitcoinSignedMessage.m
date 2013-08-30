// Oleg Andreev <oleganza@gmail.com>

#import "BTCEllipticCurveKey+BitcoinSignedMessage.h"
#import "BTCProtocolSerialization.h"
#import "BTCData.h"

static NSData* BTCSignatureHashForMessage(NSString* message)
{
    message = message ?: @"";
    NSMutableData* data = [NSMutableData data];
    NSData* prefix = [@"Bitcoin Signed Message:\n" dataUsingEncoding:NSASCIIStringEncoding];
    NSData* body = [message dataUsingEncoding:NSASCIIStringEncoding];
    [data appendData:[BTCProtocolSerialization dataForVarString:prefix]];
    [data appendData:[BTCProtocolSerialization dataForVarString:body]];
    return BTCHash256(data);
}

@implementation BTCEllipticCurveKey (BitcoinSignedMessage)

// Returns a signature for a message prepended with "Bitcoin Signed Message:\n" line.
- (NSData*) signatureForMessage:(NSString*)message
{
    if (!message) return nil;
    
    // TODO
    
    return nil;
}

// Verifies message against given signature. On success returns a public key.
+ (BTCEllipticCurveKey*) verifySignature:(NSData*)signature forMessage:(NSString*)message
{
    // TODO
    
    return nil;
}

// Verifies signature of the message with its public key.
- (BOOL) isValidSignature:(NSData*)signature forMessage:(NSString*)message
{
    BTCEllipticCurveKey* key = [[self class] verifySignature:signature forMessage:message];
    return [key isEqual:self];
}

@end
