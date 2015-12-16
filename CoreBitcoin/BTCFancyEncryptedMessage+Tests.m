//
//  BTCFancyEncryptedMessage+Tests.m
//  CoreBitcoin
//
//  Created by Oleg Andreev on 21.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BTCFancyEncryptedMessage+Tests.h"

#import "BTCKey.h"
#import "BTCData.h"
#import "BTCBigNumber.h"
#import "BTCCurvePoint.h"

@implementation BTCFancyEncryptedMessage (Tests)

+ (void) runAllTests {
    [self testProofOfWork];
    [self testMessages];
}

+ (void) testMessages {
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:BTCSHA256([@"some key" dataUsingEncoding:NSUTF8StringEncoding])];
    
    NSString* originalString = @"Hello!";
    
    BTCFancyEncryptedMessage* msg = [[BTCFancyEncryptedMessage alloc] initWithData:[originalString dataUsingEncoding:NSUTF8StringEncoding]];

    msg.difficultyTarget = 0x00FFFFFF;
    
    //NSLog(@"difficulty: %@ (%x)", [self binaryString32:msg.difficultyTarget], msg.difficultyTarget);
    
    NSData* encryptedMsg = [msg encryptedDataWithKey:key seed:BTCDataFromHex(@"deadbeef")];
    
    NSAssert(msg.difficultyTarget == 0x00FFFFFF, @"check the difficulty target");
    
    //NSLog(@"encrypted msg = %@   hash: %@...", BTCHexFromData(encryptedMsg), BTCHexFromData([BTCHash256(encryptedMsg) subdataWithRange:NSMakeRange(0, 8)]));
    
    BTCFancyEncryptedMessage* receivedMsg = [[BTCFancyEncryptedMessage alloc] initWithEncryptedData:encryptedMsg];
    
    NSAssert(receivedMsg, @"pow and format are correct");
    
    NSError* error = nil;
    NSData* decryptedData = [receivedMsg decryptedDataWithKey:key error:&error];
    
    NSAssert(decryptedData, @"should decrypt correctly");
    
    NSString* string = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    NSAssert(string, @"should decode a UTF-8 string");
    
    NSAssert([string isEqualToString:originalString], @"should decrypt the original string");
}

+ (void) testProofOfWork {
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:0] == 0, @"0x00 -> 0");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:0xFF] == 0xFFFFFFFF, @"0x00 -> 0");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:1] == 0, @"order is zero");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:2] == 0, @"order is zero");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:3] == 0, @"order is zero");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:4] == 1, @"order is zero, and tail starts with 1");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:5] == 1, @"order is zero, and tail starts with 1");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:6] == 1, @"order is zero, and tail starts with 1");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:7] == 1, @"order is zero, and tail starts with 1");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:8] == 2, @"order is one, but tail is zero");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:8+3] == 2, @"order is one, but tail is zero");
    NSAssert([BTCFancyEncryptedMessage targetForCompactTarget:8+4] == 3, @"order is one, and tail starts with 1");
    
    uint8_t t = 0;
    do {
        // normalize t
        uint8_t nt = t;
        uint32_t order = t >> 3;
        if (order == 0) nt = t >> 2;
        if (order == 1) nt = t & (0xff - 1 - 2);
        if (order == 2) nt = t & (0xff - 1);

        uint32_t target = [BTCFancyEncryptedMessage targetForCompactTarget:t];
        
        uint8_t t2 = [BTCFancyEncryptedMessage compactTargetForTarget:target];
        
        // uncomment this line to visualize data
        
        //NSLog(@"byte = % 4d %@   target = %@ % 11d", (int)t, [self binaryString8:t], [self binaryString32:target], target);
        //NSLog(@"t = % 4d %@ (%@) -> %@ % 11d -> %@ % 3d", (int)t, [self binaryString8:t], [self binaryString8:nt], [self binaryString32:target], target, [self binaryString8:t2], (int)t2);
        
        NSAssert(nt == t2, @"should transform back and forth correctly");
        
        if (t == 0xff) break;
        t++;
    } while (1);
}

+ (NSString*) binaryString8:(uint8_t)byte {
    return [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d",
            (int)((byte >> 7) & 1),
            (int)((byte >> 6) & 1),
            (int)((byte >> 5) & 1),
            (int)((byte >> 4) & 1),
            (int)((byte >> 3) & 1),
            (int)((byte >> 2) & 1),
            (int)((byte >> 1) & 1),
            (int)((byte >> 0) & 1)
            ];
}

+ (NSString*) binaryString32:(uint32_t)eent {
    return [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
            (int)((eent >> 31) & 1),
            (int)((eent >> 30) & 1),
            (int)((eent >> 29) & 1),
            (int)((eent >> 28) & 1),
            (int)((eent >> 27) & 1),
            (int)((eent >> 26) & 1),
            (int)((eent >> 25) & 1),
            (int)((eent >> 24) & 1),
            (int)((eent >> 23) & 1),
            (int)((eent >> 22) & 1),
            (int)((eent >> 21) & 1),
            (int)((eent >> 20) & 1),
            (int)((eent >> 19) & 1),
            (int)((eent >> 18) & 1),
            (int)((eent >> 17) & 1),
            (int)((eent >> 16) & 1),
            (int)((eent >> 15) & 1),
            (int)((eent >> 14) & 1),
            (int)((eent >> 13) & 1),
            (int)((eent >> 12) & 1),
            (int)((eent >> 11) & 1),
            (int)((eent >> 10) & 1),
            (int)((eent >> 9) & 1),
            (int)((eent >> 8) & 1),
            (int)((eent >> 7) & 1),
            (int)((eent >> 6) & 1),
            (int)((eent >> 5) & 1),
            (int)((eent >> 4) & 1),
            (int)((eent >> 3) & 1),
            (int)((eent >> 2) & 1),
            (int)((eent >> 1) & 1),
            (int)((eent >> 0) & 1)
            ];
}

@end
