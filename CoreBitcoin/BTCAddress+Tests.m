#import "NSData+BTCData.h"
#import "NS+BTCBase58.h"
#import "BTCAddress+Tests.h"

@implementation BTCAddress (Tests)

+ (void) runAllTests
{
    [self testPublicKeyAddress];
    [self testPrivateKeyAddress];
    [self testPrivateKeyAddressWithCompressedPoint];
    [self testScriptHashKeyAddress];
}

+ (void) testPublicKeyAddress
{
    BTCPublicKeyAddress* addr = [BTCAddress addressWithBase58String:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPublicKeyAddress class]], @"Address should be an instance of BTCPublicKeyAddress");
    NSAssert([@"c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827" isEqualToString:[addr.data hexString]], @"Must decode hash160 correctly.");
    
    BTCPublicKeyAddress* addr2 = [BTCPublicKeyAddress addressWithData:BTCDataWithHexString(@"c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" isEqualToString:addr2.base58String], @"Must encode hash160 correctly.");
}

+ (void) testPrivateKeyAddress
{
    BTCPrivateKeyAddress* addr = [BTCAddress addressWithBase58String:@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPrivateKeyAddress class]], @"Address should be an instance of BTCPrivateKeyAddress");
    NSAssert(!addr.isPublicKeyCompressed, @"Address should be not compressed");
    NSAssert([@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" isEqualToString:[addr.data hexString]], @"Must decode secret key correctly.");
    
    BTCPrivateKeyAddress* addr2 = [BTCPrivateKeyAddress addressWithData:BTCDataWithHexString(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" isEqualToString:addr2.base58String], @"Must encode secret key correctly.");
}

+ (void) testPrivateKeyAddressWithCompressedPoint
{
    BTCPrivateKeyAddress* addr = [BTCAddress addressWithBase58String:@"L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCPrivateKeyAddress class]], @"Address should be an instance of BTCPrivateKeyAddress");
    NSAssert(addr.isPublicKeyCompressed, @"Address should be compressed");
    NSAssert([@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" isEqualToString:[addr.data hexString]], @"Must decode secret key correctly.");
    
    BTCPrivateKeyAddress* addr2 = [BTCPrivateKeyAddress addressWithData:BTCDataWithHexString(@"c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")];
    NSAssert(addr2, @"Address should be created");
    addr2.publicKeyCompressed = YES;
    NSAssert([@"L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu" isEqualToString:addr2.base58String], @"Must encode secret key correctly.");
    addr2.publicKeyCompressed = NO;
    NSAssert([@"5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" isEqualToString:addr2.base58String], @"Must encode secret key correctly.");
}

+ (void) testScriptHashKeyAddress
{
    BTCScriptHashAddress* addr = [BTCAddress addressWithBase58String:@"3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8"];
    NSAssert(addr, @"Address should be decoded");
    NSAssert([addr isKindOfClass:[BTCScriptHashAddress class]], @"Address should be an instance of BTCScriptHashAddress");
    NSAssert([@"e8c300c87986efa84c37c0519929019ef86eb5b4" isEqualToString:addr.data.hexString], @"Must decode hash160 correctly.");
    
    BTCScriptHashAddress* addr2 = [BTCScriptHashAddress addressWithData:BTCDataWithHexString(@"e8c300c87986efa84c37c0519929019ef86eb5b4")];
    NSAssert(addr2, @"Address should be created");
    NSAssert([@"3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8" isEqualToString:addr2.base58String], @"Must encode hash160 correctly.");
}

@end
