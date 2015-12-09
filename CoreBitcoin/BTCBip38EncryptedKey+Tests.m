//
//  BTCBip38EncryptedKey+Tests.m
//  CoreBitcoin
//
//  Created by Alex Zak on 16/11/2015.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

#import "BTCBip38EncryptedKey+Tests.h"

#import "BTCData.h"

@implementation BTCBip38EncryptedKey (Tests)

+ (void) runAllTests {
	
	[self testEncryption];
	[self testDecryption];
	[self testDecryptionWithWrongPass];
}


+ (NSArray *) testVectors {
	return @[
			 @{
				 @"hex"			: @"CBF4B9F70470856BB4F40F80B87EDB90865997FFEE6DF315AB166D713AF433A5",
				 @"compressed"	: @NO,
				 @"passphrase"	: @"TestingOneTwoThree",
				 @"encrypted"	: @"6PRVWUbkzzsbcVac2qwfssoUJAN1Xhrg6bNk8J7Nzm5H7kxEbn2Nh2ZoGg"
				 },
			 @{
				 @"hex"			: @"09C2686880095B1A4C249EE3AC4EEA8A014F11E6F986D0B5025AC1F39AFBD9AE",
				 @"compressed"	: @NO,
				 @"passphrase"	: @"Satoshi",
				 @"encrypted"	: @"6PRNFFkZc2NZ6dJqFfhRoFNMR9Lnyj7dYGrzdgXXVMXcxoKTePPX1dWByq"
				 },
			 @{
				 @"hex"			: @"CBF4B9F70470856BB4F40F80B87EDB90865997FFEE6DF315AB166D713AF433A5",
				 @"compressed"	: @YES,
				 @"passphrase"	: @"TestingOneTwoThree",
				 @"encrypted"	: @"6PYNKZ1EAgYgmQfmNVamxyXVWHzK5s6DGhwP4J5o44cvXdoY7sRzhtpUeo"
				 },
			 @{
				 @"hex"			: @"09C2686880095B1A4C249EE3AC4EEA8A014F11E6F986D0B5025AC1F39AFBD9AE",
				 @"compressed"	: @YES,
				 @"passphrase"	: @"Satoshi",
				 @"encrypted"	: @"6PYLtMnXvfG3oJde97zRyLYFZCYizPU5T3LwgdYJz1fRhh16bU7u6PPmY7"
				 }
			 ];
}

+ (void)testEncryption
{
	
	for (NSDictionary *testVector in [self testVectors]) {
		
		NSString *hex		 =  testVector[@"hex"		];
		BOOL	  compressed = [testVector[@"compressed"] boolValue];
		NSString *passphrase =  testVector[@"passphrase"];
		NSString *encrypted  =  testVector[@"encrypted" ];
		
		
		BTCKey *key = [[BTCKey alloc] initWithPrivateKey:BTCDataFromHex(hex)];
		[key setPublicKeyCompressed:compressed];
		
		BTCBip38EncryptedKey *bip38Key = [key encryptedBIP38KeyWithPassphrase:passphrase];
//		NSLog(@"Ecrypted key: %@", bip38Key.encrypted);
		NSAssert([bip38Key.encrypted isEqual:encrypted], @"Bip38 encryption failed");
	}
}

+ (void) testDecryption {
	
	for (NSDictionary *testVector in [self testVectors]) {
		
		BOOL	  expectedCompressed  = [testVector[@"compressed"] boolValue	  ];
		NSString *expextedHex		  = [testVector[@"hex"       ] lowercaseString];
		NSString *encrypted			  =  testVector[@"encrypted" ];
		NSString *passphrase		  =  testVector[@"passphrase"];
		
		BTCBip38EncryptedKey *bip38Key = [[BTCBip38EncryptedKey alloc] initWithEncrypted:encrypted];
		BTCKey *key = [bip38Key decryptedKeyWithPassphrase:passphrase];
		
		NSString *resultedHex = [BTCHexFromData(key.privateKey) lowercaseString];
//		NSLog(@"Decrypted hex: %@", resultedHex);
		NSAssert([resultedHex isEqualToString:expextedHex], @"Bip38 encryption failed");
		NSAssert(key.isPublicKeyCompressed == expectedCompressed, @"Bip38 encryption failed to find compression value");
	}
}

+ (void) testDecryptionWithWrongPass {
	
	NSString *passphrase = @"12345678";
	NSString *wrongPassphrase = @"87654321";
	BTCKey *key = [[BTCKey alloc] init];
	
	BTCBip38EncryptedKey *bip38Key = [key encryptedBIP38KeyWithPassphrase:passphrase];
	BTCKey *decryptedKey = [bip38Key decryptedKeyWithPassphrase:wrongPassphrase];
	
	NSAssert(decryptedKey == NULL, @"Bip38 encryption should've failed with wrong pass");
}


@end
