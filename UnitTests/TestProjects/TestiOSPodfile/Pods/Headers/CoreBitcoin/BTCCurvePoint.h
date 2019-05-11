// EthCore by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#include <openssl/ec.h>

// Represents a point on the elliptic curve secp256k1.
// Combined with BTCBigNumber arithmetic, you can do usual EC operations to manipulate private and public keys.
// Private key is a big integer (represented by raw NSData or BTCBigNumber).
// Public key is a point on the curve represented by BTCCurvePoint or BTCKey.
// BTCCurvePoint is mutable. There is no immutable counterpart.
@class BTCKey;
@class BTCBigNumber;
@interface BTCCurvePoint : NSObject <NSCopying>

// Serialized form of a curve point as a compressed public key (32-byte X coordinate with 1-byte prefix)
@property(nonatomic, readonly) NSData* data;

// Underlying data structure in OpenSSL.
@property(nonatomic, readonly) const EC_POINT* EC_POINT;

// Returns the generator point. Same as [BTCCurvePoint alloc] init].
+ (id) generator;

// Returns order of the secp256k1 curve (FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141).
+ (BTCBigNumber*) curveOrder;

// Initializes point with its binary representation (corresponds to -data).
- (id) initWithData:(NSData*)data;

// Initializes point with OpenSSL EC_POINT.
- (id) initWithEC_POINT:(const EC_POINT*)ecpoint;

// Returns YES if the point is at infinity.
- (BOOL) isInfinity;

// These modify the receiver and return self (or nil in case of error). To create another point use -copy: [[point copy] multiply:number]
- (instancetype) multiply:(BTCBigNumber*)number;
- (instancetype) add:(BTCCurvePoint*)point;

// Efficiently adds n*G to the receiver. Equivalent to [point add:[[G copy] multiply:number]]
- (instancetype) addGeneratorMultipliedBy:(BTCBigNumber*)number;

// Coordinates of the point
- (BTCBigNumber*) x;
- (BTCBigNumber*) y;

@end
