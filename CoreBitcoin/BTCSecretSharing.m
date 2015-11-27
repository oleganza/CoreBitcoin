// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCErrors.h"
#import "BTCData.h"
#import "BTCBigNumber.h"
#import "BTCSecretSharing.h"

@interface BTCSecretSharing ()
@property(nonatomic, readwrite) BTCSecretSharingVersion version;
@property(nonatomic, readwrite) BTCBigNumber* order;
@property(nonatomic, readwrite) NSInteger bitlength;
@end

@implementation BTCSecretSharing

// Returns a configuration for compact 128-bit secrets with up to 16 shares.
- (id __nonnull) initWithVersion:(BTCSecretSharingVersion)version {
    if (self = [super init]) {
        if (version == BTCSecretSharingVersionCompact128) {
            self.version = version;
            // 0xffffffffffffffffffffffffffffff61
            self.bitlength = 128;
            self.order = [[BTCBigNumber alloc] initWithString:@"ffffffffffffffffffffffffffffff61" base:16];
        } else {
            [NSException raise:@"BTCSecretSharing supports only BTCSecretSharingVersionCompact128 at the moment" format:@""];
        }
    }
    return self;
}

- (NSArray* __nullable) splitSecret:(NSData* __nonnull)secret threshold:(NSInteger)m shares:(NSInteger)n error:(NSError**)errorOut {

    if (secret.length*8 != self.bitlength) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorIncompatibleSecret userInfo:@{NSLocalizedDescriptionKey: @"Secret length does not match bitlength of BTCSecretSharing."}];
        return nil;
    }
    BTCBigNumber* prime = self.order;
    BTCBigNumber* secretNumber = [[BTCBigNumber alloc] initWithUnsignedBigEndian:secret];

    if ([secretNumber greaterOrEqual:prime]) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorIncompatibleSecret userInfo:@{NSLocalizedDescriptionKey: @"Secret as bigint must be less than prime order of BTCSecretSharing."}];
        return nil;
    }

    if (!(n >= 1 && n <= 16)) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorIncompatibleSecret userInfo:@{NSLocalizedDescriptionKey: @"Number of shares (N) must be between 1 and 16."}];
        return nil;
    }

    if (!(m >= 1 && m <= n)) {
        if (errorOut) *errorOut = [NSError errorWithDomain:BTCErrorDomain code:BTCErrorIncompatibleSecret userInfo:@{NSLocalizedDescriptionKey: @"Threshold (M) must be between 1 and N (number of shares)."}];
        return nil;
    }

    NSMutableArray* shares = [NSMutableArray array];
    NSMutableArray* coefficients = [NSMutableArray array];
    [coefficients addObject:secretNumber];
    for (NSInteger i = 0; i < (m-1); i++) {
        // Generate unpredictable yet deterministic coefficients for each secret and M.
        NSMutableData* seed = [secret mutableCopy];
        unsigned char mbyte = m;
        unsigned char ibyte = i;
        [seed appendBytes:&mbyte length:1];
        [seed appendBytes:&ibyte length:1];
        NSData* coefdata = [self prng:seed];
        BTCBigNumber* coef = [[BTCBigNumber alloc] initWithUnsignedBigEndian:coefdata];
        [coefficients addObject:coef];
    }
    for (NSInteger i = 0; i < n; i++) {
        BTCMutableBigNumber* x = [[BTCMutableBigNumber alloc] initWithInt64:i+1];
        NSInteger exp = 1;
        BTCMutableBigNumber* y = [coefficients[0] mutableCopy];
        // while exp < m
        //   y = (y + (coef[exp] * ((x**exp) % prime) % prime)) % prime
        //   exp += 1
        // end
        while (exp < m) {
            BTCMutableBigNumber* coef = [coefficients[exp] mutableCopy];
            [coef multiply:x mod:prime];
            [y add:coef mod:prime];
            [x multiply:x mod:prime]; // (x**exp % prime)
            exp += 1;
        }
        NSData* share = [self encodeShareM:m X:i+1 Y:y];
        [shares addObject:share];
    }
    return shares;
}

- (NSData* __nullable) joinShares:(NSArray* __nonnull)shares error:(NSError**)errorOut {

    return [@"" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*) prng:(NSData*)seed {
    /*
     def prng(seed)
         x = Order
         s = nil
         pad = "".b
         while x >= Order
             s = Digest::SHA2.digest(Digest::SHA2.digest(seed + pad))[0,16]
             x = int_from_be(s)
             pad = pad + "\x00".b
         end
         s
     end
     */
    BTCBigNumber* x = self.order;
    NSData* s = nil;
    NSMutableData* pad = [NSMutableData data];
    while ([x greaterOrEqual:self.order]) {
        NSMutableData* input = [seed mutableCopy];
        [input appendData:pad];
        s = [BTCHash256(input) subdataWithRange:NSMakeRange(0, 16)];
        x = [[BTCBigNumber alloc] initWithUnsignedBigEndian:s];
        unsigned char zero = 0;
        [pad appendBytes:&zero length:1];
    }
    return s;
}

// Returns mmmmxxxx yyyyyyyy yyyyyyyy ... (16 bytes of y)
- (NSData*) encodeShareM:(NSInteger)m X:(NSInteger)x Y:(BTCBigNumber*)y {
    m = [self toNibble:m];
    x = [self toNibble:x];
    unsigned char prefix = (m << 4) + x;
    NSMutableData* data = [[NSMutableData alloc] initWithBytes:&prefix length:1];
    [data appendData:[y.unsignedBigEndian subdataWithRange:NSMakeRange(32-self.bitlength/8, self.bitlength/8)]];
    return data;
}


//# Returns mmmmxxxx yyyyyyyy yyyyyyyy ... (16 bytes of y)
//def string_from_point(m, x, y)
//m = to_nibble(m)
//x = to_nibble(x)
//byte = [(m << 4) + x].pack("C")
//byte + be_from_int(y)
//end
//
//# returns [m, x, y]
//def point_from_string(s)
//byte = s.bytes.first
//m = from_nibble(byte >> 4)
//x = from_nibble(byte & 0x0f)
//y = int_from_be(s[1..-1])
//[m, x, y]
//end

// Encodes values in range 1..16 to one nibble where all values are encoded as-is,
// except for 16 which becomes 0. This is to make strings look friendly for common cases when M,N < 16
- (NSInteger) toNibble:(NSInteger)x {
    return x == 16 ? 0 : x;
}

- (NSInteger) fromNibble:(NSInteger)x {
    return x == 0 ? 16 : x;
}

@end
