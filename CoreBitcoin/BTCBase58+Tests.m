// Oleg Andreev <oleganza@gmail.com>

#import "BTCBase58+Tests.h"
#import "BTCData.h"

void BTCAssertHexEncodesToBase58(NSString* hex, NSString* base58) {
    NSData* data = BTCDataFromHex(hex);
    
    // Encode
    NSCAssert([BTCBase58StringWithData(data) isEqualToString:base58], @"should encode in base58 correctly");
    
    // Decode
    NSData* data2 = BTCDataFromBase58(base58);
    NSCAssert([data2 isEqual:data], @"should decode base58 correctly");
}

void BTCAssertDetectsInvalidBase58(NSString* text) {
	NSData *data = BTCDataFromBase58Check(text);
    
    NSCAssert(data == nil, @"should return nil if base58 is invalid");
}

void BTCBase58RunAllTests() {
    BTCAssertDetectsInvalidBase58(nil);
    BTCAssertDetectsInvalidBase58(@" ");
    BTCAssertDetectsInvalidBase58(@"lLoO");
    BTCAssertDetectsInvalidBase58(@"l");
    BTCAssertDetectsInvalidBase58(@"L");
    BTCAssertDetectsInvalidBase58(@"o");
    BTCAssertDetectsInvalidBase58(@"O");
    BTCAssertDetectsInvalidBase58(@"öまи");
    
    BTCAssertHexEncodesToBase58(@"", @""); // Empty string is valid encoding of an empty binary string
    BTCAssertHexEncodesToBase58(@"61", @"2g");
    BTCAssertHexEncodesToBase58(@"626262", @"a3gV");
    BTCAssertHexEncodesToBase58(@"636363", @"aPEr");
    BTCAssertHexEncodesToBase58(@"73696d706c792061206c6f6e6720737472696e67", @"2cFupjhnEsSn59qHXstmK2ffpLv2");
    BTCAssertHexEncodesToBase58(@"00eb15231dfceb60925886b67d065299925915aeb172c06647", @"1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L");
    BTCAssertHexEncodesToBase58(@"516b6fcd0f", @"ABnLTmg");
    BTCAssertHexEncodesToBase58(@"bf4f89001e670274dd", @"3SEo3LWLoPntC");
    BTCAssertHexEncodesToBase58(@"572e4794", @"3EFU7m");
    BTCAssertHexEncodesToBase58(@"ecac89cad93923c02321", @"EJDM8drfXA6uyA");
    BTCAssertHexEncodesToBase58(@"10c8511e", @"Rt5zm");
    BTCAssertHexEncodesToBase58(@"00000000000000000000", @"1111111111");

    if ((0)) {
        // Search for vanity prefix
        NSString* prefix = @"s";
        
        NSData* payload = BTCRandomDataWithLength(32);
        for (uint32_t i = 0x10000000; i <= UINT32_MAX; i++) {
            int j = 10;
            NSString* serialization = nil;
            do {
                NSMutableData* data = [NSMutableData data];

                uint32_t idx = 0;
                [data appendBytes:&i length:sizeof(i)];
                [data appendBytes:&idx length:sizeof(idx)];
                [data appendData:payload];

                serialization = BTCBase58CheckStringWithData(data);

                payload = BTCRandomDataWithLength(32);

            } while ([serialization hasPrefix:prefix] && j-- > 0);

            if ([serialization hasPrefix:prefix]) {
                NSLog(@"integer for prefix %@ is %d", prefix, i);
                break;
            }
        }
    }
}