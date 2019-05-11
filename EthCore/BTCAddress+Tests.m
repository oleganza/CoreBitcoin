#import "NSData+BTCData.h"
#import "NS+BTCBase58.h"
#import "BTCAddress+Tests.h"

@implementation BTCAddress (Tests)

+ (void) runAllTests {
    [self testPublicKeyAddress];
    [self testPrivateKeyAddress];
    [self testPrivateKeyAddressWithCompressedPoint];
    [self testScriptHashKeyAddress];
}

+ (void) testPublicKeyAddress {
    BTCPublicKeyAddress* addr = [BTCPublicKeyAddress addressWithString:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPublicKeyAddress class]], @"Address should be an instance of BTCPublicKeyAddress");
    NSAssert([@"c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827" isEqualToString:[addr.data hex]], @"Must decode hash160 correctly.");
    NSAssert([addr isEqual:addr.publicAddress], @"Address should be equal to its publicAddress");

    BTCPublicKeyAddress* addr2 = [BTCPublicKeyAddress addressWithData:BTCDataFromHex(@"c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" isEqualToString:addr2.string], @"Must encode hash160 correctly.");
}

+ (void) testPrivateKeyAddress {
    BTCPrivateKeyAddress* addr = [BTCPrivateKeyAddress addressWithString:@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPrivateKeyAddress class]], @"Address should be an instance of BTCPrivateKeyAddress");
    NSAssert(!addr.isPublicKeyCompressed, @"Address should be not compressed");
    NSAssert([@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" isEqualToString:addr.data.hex], @"Must decode secret key correctly.");
    NSAssert([[addr publicAddress].string isEqual:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"must provide proper public address");
    
    BTCPrivateKeyAddress* addr2 = [BTCPrivateKeyAddress addressWithData:BTCDataFromHex(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" isEqualToString:addr2.string], @"Must encode secret key correctly.");
}

+ (void) testPrivateKeyAddressWithCompressedPoint {
    BTCPrivateKeyAddress* addr = [BTCPrivateKeyAddress addressWithString:@"L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPrivateKeyAddress class]], @"Address should be an instance of BTCPrivateKeyAddress");
    NSAssert(addr.isPublicKeyCompressed, @"Address should be compressed");
    NSAssert([@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" isEqualToString:addr.data.hex], @"Must decode secret key correctly.");
    NSAssert([[addr publicAddress].string isEqual:@"1C7zdTfnkzmr13HfA2vNm5SJYRK6nEKyq8"], @"must provide proper public address");

    BTCPrivateKeyAddress* addr2 = [BTCPrivateKeyAddress addressWithData:BTCDataFromHex(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")];
    NSAssert(addr2, @"Address should be created");
    addr2.publicKeyCompressed = YES;
    NSAssert([@"L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu" isEqualToString:addr2.string], @"Must encode secret key correctly.");
    addr2.publicKeyCompressed = NO;
    NSAssert([@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" isEqualToString:addr2.string], @"Must encode secret key correctly.");
}

+ (void) testScriptHashKeyAddress {
    BTCScriptHashAddress* addr = [BTCScriptHashAddress addressWithString:@"3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCScriptHashAddress class]], @"Address should be an instance of BTCScriptHashAddress");
    NSAssert([@"e8c300c87986efa84c37c0519929019ef86eb5b4" isEqualToString:addr.data.hex], @"Must decode hash160 correctly.");
    NSAssert([addr isEqual:addr.publicAddress], @"Address should be equal to its publicAddress");

    BTCScriptHashAddress* addr2 = [BTCScriptHashAddress addressWithData:BTCDataFromHex(@"e8c300c87986efa84c37c0519929019ef86eb5b4")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8" isEqualToString:addr2.string], @"Must encode hash160 correctly.");
}

@end
