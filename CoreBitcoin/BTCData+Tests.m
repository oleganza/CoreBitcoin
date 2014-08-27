// Oleg Andreev <oleganza@gmail.com>

#import "BTCData.h"
#import "NSData+BTCData.h"
#import "BTCBase58.h"
#import "NS+BTCBase58.h"
#import "BTCData+Tests.h"

@implementation NSData (BTC_Tests)

+ (void) runAllTests
{
    NSAssert([[[NSData alloc] init].SHA256.hexString
              isEqual:@"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"], @"Test vector");
    NSAssert([[[NSData alloc] init].SHA256.hexUppercaseString
              isEqual:@"E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"], @"Test vector");
    NSAssert([BTCDataWithUTF8String("The quick brown fox jumps over the lazy dog").SHA256.hexString
              isEqual:@"d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"], @"Test vector");
 
    NSAssert([BTCDataWithUTF8String("hello").SHA256.hexString
              isEqual:@"2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"], @"Test vector");
    NSAssert([BTCDataWithUTF8String("hello").SHA256.SHA256.hexString
              isEqual:@"9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50"], @"Test vector");
    NSAssert([BTCDataWithUTF8String("hello").BTCHash256.hexString
              isEqual:@"9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50"], @"Test vector");

    NSAssert([BTCDataWithUTF8String("hello").SHA256.RIPEMD160.hexString
              isEqual:@"b6a9c8c230722b7c748331a8b450f05566dc7d0f"], @"Test vector");

    NSAssert([BTCDataWithUTF8String("hello").BTCHash160.hexString
              isEqual:@"b6a9c8c230722b7c748331a8b450f05566dc7d0f"], @"Test vector");

    NSAssert([BTCDataWithHexString(@"deadBEEF") isEqualToData:[NSData dataWithBytes:"\xde\xad\xBE\xEF" length:4]], @"Init data with hex string");

    NSAssert([BTCDataWithHexString(@"0xdeadBEEF") isEqualToData:[NSData dataWithBytes:"\xde\xad\xBE\xEF" length:4]], @"Init data with hex string");
    
    NSAssert(![BTCDataWithHexString(@"0xdeadBEEF") isEqualToData:[NSData dataWithBytes:"\xde\xad\xBE\xFE" length:4]], @"Init data with hex string");
    
    
    // Base58 decoding
    
    NSAssert([[[@"6h8cQN" dataFromBase58] hexString] isEqual:@"deadbeef"], @"Decodes base58");
    NSAssert([[[@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" dataFromBase58Check] hexString] isEqual:@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"], @"Decodes base58 with checksum");
    

    // Base58 encoding
    
    NSAssert([[BTCDataWithHexString(@"deadBeeF") base58String] isEqualToString:@"6h8cQN"], @"Encodes base58");
    NSAssert([[BTCDataWithHexString(@"00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827") base58CheckString] isEqualToString:@"1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"], @"Encodes base58 with checksum");
    
    
    // Memory-hard KDF
    
    return;
    return;
    return;
    return;
    return;
    return;
    

    NSLog(@"Generating key with BTCLocustKDF256...");
    NSDate* t1 = [NSDate date];
    NSData* key1 = BTCLocustKDF256([@"secret" dataUsingEncoding:NSUTF8StringEncoding],
                                      BTCDataWithHexCString("2441399593e166d12e33265ddbef31b6ddf8644108ec3fe216ed13d1eb7024f3"),
                                      100*1024*1024 // memory required
                                      );
    NSLog(@"Generated key = %@ [%f sec]", key1, -[t1 timeIntervalSinceNow]);
    

    NSLog(@"Generating key with BTCMemoryHardKDF256...");
    NSDate* t2 = [NSDate date];
    NSData* key2 = BTCMemoryHardKDF256([@"secret" dataUsingEncoding:NSUTF8StringEncoding],
                                      BTCDataWithHexCString("2441399593e166d12e33265ddbef31b6ddf8644108ec3fe216ed13d1eb7024f3"),
                                      20, // number of rounds
                                      4*1024*1024 // memory required
                                      );
    NSLog(@"Generated key = %@ [%f sec]", key2, -[t2 timeIntervalSinceNow]);

    
    NSLog(@"Generating key with BTCMemoryHardAESKDF...");
    NSDate* t3 = [NSDate date];
    NSData* key3 = BTCMemoryHardAESKDF([@"secret" dataUsingEncoding:NSUTF8StringEncoding],
                                      BTCDataWithHexCString("2441399593e166d12e33265ddbef31b6ddf8644108ec3fe216ed13d1eb7024f3"),
                                      20, // number of rounds
                                      16*1024*1024 // memory required
                                      );
    NSLog(@"Generated key = %@ [%f sec]", key3, -[t3 timeIntervalSinceNow]);

    // Random number generators
    if (0)
    {
        const int length = 1024*16;
        double maxdeviation = 0.15;
        
        NSData* data = BTCCoinFlipDataWithLength(length);
        
        const int slots = 16;

        const unsigned char* bytes = data.bytes;
        int distribution[slots] = {0};
        for (int i = 0; i < data.length; i++)
        {
            unsigned char c = bytes[i];
            distribution[c % slots]++;
        }
        double max = 0;
        double min = 99999999;
        double avg = 0;
        for (int i = 0; i < slots; i++)
        {
            avg += distribution[i];
            max = MAX(max, distribution[i]);
            min = MIN(min, distribution[i]);
        }
        avg /= slots;
        
        double deviation = (max - min) / avg;
        NSLog(@"BTCCoinFlipDataWithLength: Deviation: %f", deviation);
        
        NSAssert(min > 0, @"Sanity check");
        NSAssert(max > min, @"Sanity check");
        NSAssert(deviation < maxdeviation, @"Deviation should be small enough");

        for (int i = 0; i < slots; i++)
        {
            NSLog(@"distribution[%02d] = %d", i, distribution[i]);
        }

        NSLog(@"BTCCoinFlipDataWithLength: %@", [data subdataWithRange:NSMakeRange(0, 32)].hexString);
    }
}

@end
