// Oleg Andreev <oleganza@gmail.com>

#import "BTCScript+Tests.h"
#import "BTCData.h"
#import "BTCBase58.h"
#import "BTCScriptMachine.h"
#import "BTCScript.h"
#import "BTCKey.h"
#import "BTCAddress.h"
#import "BTCTransaction.h"
#import "BTCTransactionOutput.h"
#import "BTCTransactionInput.h"

@implementation BTCScript (Tests)

+ (void) runAllTests {
    [self testP2SHMultisig];
    [self testMultisignatureScripts];
    
    [self testBinarySerialization];
    [self testStringSerialization];
    [self testStandardScripts];
    
    [self testScriptModifications];
    [self testStrangeScripts];
    
    [self testValidBitcoinQTScripts];
    [self testInvalidBitcoinQTScripts];
}

+ (void) testP2SHMultisig {
//    BTCTransaction* tx = [[BTCTransaction alloc] initWithData:BTCDataFromHex(@"0100000002e7131826715b36b47b149177b0f2f3169af74b9188d3d02433d7f3b5e6c796a701000000fc00473044022075968c0bd5dd89872cb4793f60e30bcaa44b73f2c4ff31f0ad184f216d2b081202205b6e0d4dbe07d826baeef346d8ff9d02d40c5aa9b0f74b0fafb370aee068a9ae0147304402204b287822f29e683fc0cb16935d11b9401fee5a97893a798b4ca7d43e53eaf8c602207e42f8749083d871ea7d1e0a90e02d44f25f6276787d3c04ed72da681fb3e70f014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff12780cf6595ce7d34ca2e2c104dad5a2ea8709348a280cefc2246bdbd0bf142a01000000fb00473044022056c9d4177774917f9a91be9b5f7c458d9d142bd5ac22d219942dd6eec7b98c140220732715ed6ffee27d446792a11578b63b5db13e52898dae26e6dc965b9dc87fb20146304302206882ff20af49797da8a5758024e32517216ec66c119199a3dc9a9f89c24cc56d021f6bf1d49a83fc73f93a2139e519ed31e3ae8b04fbe7bb7245f35da9dd22c6f7014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff03e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87c60700000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d8700000000")];

    BTCTransaction* tx = [[BTCTransaction alloc] initWithData:BTCDataFromHex(@"0100000002e7131826715b36b47b149177b0f2f3169af74b9188d3d02433d7f3b5e6c796a701000000fdfd0000473044022032e7b327ccf5e7f19029134c50d881daa178a1233d09ac9e6e93081e8f33efaf02202e2bf8b57d1c34554f65fac9c6df4986d31b3f6a7bee6cbab9a3ed835e3f57c301483045022100a355f5cde0b7643a1cbb813df4b29ddca13ddd7ee3685e77b1972179832bbd9a0220391bb9661fdab9f38bcce2abaebde39f3b5874b65758b61e1961c64f8b74d288014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff12780cf6595ce7d34ca2e2c104dad5a2ea8709348a280cefc2246bdbd0bf142a01000000fdfd0000483045022100a6967dcd995712007a647d5466131ebc2f5cd3f46c7b314ccf428ea4e46684c502202716cf49125a67627dc2837b747898b38e8c4f58abb13cd3c1c362f0f4094ff301473044022056fc5265f4508e1baf4d837894d5e6e3df8925c68c1f2f8ca83476b73fabd64202200ad5c9928db2d7096a3d19ac2d6fc9eab3db69cd00b9dbcb923bb2e709c5b64f014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff03e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87c60700000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d8700000000")];
//    BTCScript* redeemScript = [[BTCScript alloc] initWithData:BTCDataFromHex(@"52210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153ae")];
    BTCScript* outputScript = [[BTCScript alloc] initWithAddress:[BTCAddress addressWithString:@"2NDdMCpA9to3ayTkXJQ3DvfKuSxjyRtFG5S"]];

//    NSLog(@"p2sh = %@", outputScript.string);
//    NSLog(@"p2sh inner = %@", redeemScript.string);
//    NSLog(@"tx = %@", tx.dictionary);

    for (uint32_t i = 0; i < tx.inputs.count; i++) {
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:i];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:outputScript error:&error];
        if (!r) {
            NSLog(@"BTCScriptMachine error: %@", error);
        }
        NSAssert(r, @"should verify first input");
    }
}

+ (void) testMultisignatureScripts {
    // 1. Create some keys
    
    BTCKey* alice = [[BTCKey alloc] initWithPrivateKey:BTCHash256(BTCDataWithUTF8CString("alice"))];
    BTCKey* bob   = [[BTCKey alloc] initWithPrivateKey:BTCHash256(BTCDataWithUTF8CString("bob"))];
    BTCKey* carl  = [[BTCKey alloc] initWithPrivateKey:BTCHash256(BTCDataWithUTF8CString("carl"))];
    BTCKey* david = [[BTCKey alloc] initWithPrivateKey:BTCHash256(BTCDataWithUTF8CString("david"))];
    
    // 2. Compose a source transaction (does not need to be fully valid o have any inputs)
    
    NSArray* pubkeys = [@[alice, bob, carl] valueForKey:@"compressedPublicKey"];
    BTCTransaction* srcTx = [[BTCTransaction alloc] init];
    
    // Lets have a 2-of-3 multisig output.
    BTCTransactionOutput* srcTxOut = [[BTCTransactionOutput alloc] initWithValue:100 script:[[BTCScript alloc] initWithPublicKeys:pubkeys signaturesRequired:2]];
    [srcTx addOutput:srcTxOut];
    
    //NSLog(@"Script: %@", srcTxOut.script.string);

    BTCTransaction* dstTx = [[BTCTransaction alloc] init];
    
    // Add dummy output (we don't care where the coins will go)
    [dstTx addOutput:[[BTCTransactionOutput alloc] initWithValue:100]];
    
    BTCTransactionInput* dstTxIn = [[BTCTransactionInput alloc] init];
    dstTxIn.previousHash = srcTx.transactionHash;
    dstTxIn.previousIndex = 0;
    [dstTx addInput:dstTxIn];
    
    // 3. Sign the redeeming transaction.
    
    BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
    NSData* hash = [dstTx signatureHashForScript:srcTxOut.script inputIndex:0 hashType:hashtype error:NULL];
    
    NSAssert(hash, @"sanity check");
    
    // 4. Simple signing case useful as a sample code.
    
    {
        BTCScript* signatureScript = [[BTCScript alloc] init];
        
        [signatureScript appendOpcode:OP_0]; // always prepend dummy OP_0 because OP_CHECKMULTISIG pops one too many items from the stack.
        [signatureScript appendData:[alice signatureForHash:hash hashType:hashtype]];
        [signatureScript appendData:[bob signatureForHash:hash hashType:hashtype]];
        
        dstTxIn.signatureScript = signatureScript;
        
        // Verify the transaction.
    
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:dstTx inputIndex:0];
        BOOL r = [sm verifyWithOutputScript:[srcTxOut.script copy] error:NULL];
        NSAssert(r, @"should verify first input");
    }
    
    // 5. Check valid combinations
    
    for (NSArray* keys in @[
                                   // Exactly 2 signatures in correct order.
                                   @[alice, bob],
                                   @[bob,   carl],
                                   @[alice, carl],
                                   
                                   // Too many signatures, but the last ones are correct
                                   @[alice, alice, bob],
                                   @[david, alice, carl],
                                   @[alice, bob,   carl],
                                   ]) {
        BTCScript* signatureScript = [[BTCScript alloc] init];
        
        [signatureScript appendOpcode:OP_0];
        for (BTCKey* key in keys) {
            [signatureScript appendData:[key signatureForHash:hash hashType:hashtype]];
        }
        
        dstTxIn.signatureScript = signatureScript;
        
        // Verify the transaction.
        
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:dstTx inputIndex:0];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:[srcTxOut.script copy] error:&error];
        if (!r) {
            NSLog(@"BTCScriptMachine error: %@", error);
        }
        NSAssert(r, @"should verify first input");
    }
    
    // Check invalid combinations
    for (NSArray* keys in @[
                                // Not enough signatures
                               @[],
                               @[alice],
                               @[bob],
                               @[carl],
                               
                               // Too many signatures and the last two are incorrect
                               @[alice, bob, david],
                               @[bob, carl, alice],
                               @[bob, bob, bob],
                               
                               // Incorrect signatures
                               @[alice, alice],
                               @[bob, bob],
                               @[carl, carl],
                               @[david, david],
                               @[alice, david],
                               
                               // Incorrect order
                               @[bob, alice],
                               @[carl, bob],
                               @[carl, alice],
                               ]) {
        BTCScript* signatureScript = [[BTCScript alloc] init];
        
        [signatureScript appendOpcode:OP_0];
        for (BTCKey* key in keys) {
            [signatureScript appendData:[key signatureForHash:hash hashType:hashtype]];
        }
        
        dstTxIn.signatureScript = signatureScript;
        
        // Verify the transaction.
        
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:dstTx inputIndex:0];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:[srcTxOut.script copy] error:&error];
        //NSLog(@"BTCScriptMachine error: %@", error);
        NSAssert(!r, @"should not verify first output");
    }
    
}

+ (void) testBinarySerialization {
    // Empty script
    {
        NSAssert([[[BTCScript alloc] init].data isEqual:[NSData data]], @"Default script should be empty.");
        NSAssert([[[BTCScript alloc] initWithData:[NSData data]].data isEqual:[NSData data]], @"Empty script should be empty.");
    }
    
}

+ (void) testStringSerialization {
    //NSLog(@"tx = %@", BTCHexFromData(BTCReversedData(BTCDataFromHex(@"..."))));
    
    NSData* yrashkScript = BTCDataFromHex(@"52210391e4786b4c7637c160247ad6d5702d9bb2860cbb8130d59b0fd9808a0220d50f2102e191fcff2849099988fbe1592b6788707a61401058c09ef97363c9d96c43a0cf21027f10a51295e8e96d5957f3665168426249a006e548e48cbfa5882d2bf89ab67e2103d39801bafef0cc3c211101a54a47874c0a835efa2c17c47ebbe380c803345a2354ae");
    
    BTCScript* script = [[BTCScript alloc] initWithData:yrashkScript];
    
    NSAssert(script, @"sanity check");
    //NSLog(@"Script: %@", script);
}

+ (void) testStandardScripts {
    BTCScript *script = [[BTCScript alloc] initWithData:BTCDataFromHex(@"76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac")];
    
    //NSLog(@"TEST: String: %@\nIs P2PKH Script: %d", script.string, script.isPayToPublicKeyHashScript);
    
    NSAssert([script isPayToPublicKeyHashScript], @"should be regular hash160 script");

    {
        NSData* simsigData = [script simulatedSignatureScriptWithOptions:BTCScriptSimulationDefault].data;
        NSAssert(simsigData.length == 1 + (72 + 1) + 1 + 65, @"Simulated sigscript for p2pkh should contain signature, hashtype and an uncompressed pubkey");

        NSData* simsigData2 = [script simulatedSignatureScriptWithOptions:BTCScriptSimulationCompressedPublicKeys].data;
        NSAssert(simsigData2.length == 1 + (72 + 1) + 1 + 33, @"Simulated sigscript for p2pkh with compressed pubkey option should contain signature, hashtype and a compressed pubkey");
    }

    NSString* base58address = script.standardAddress.string;
    //NSLog(@"TEST: address: %@", base58address);
    
    NSAssert([base58address isEqualToString:@"1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"], @"address should be correctly decoded");
    
    BTCScript* script2 = [[BTCScript alloc] initWithAddress:[BTCAddress addressWithString:@"1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"]];
    NSAssert([script2.data isEqual:script.data], @"script created from extracted address should be the same as the original script");
    NSAssert([script2.string isEqual:script.string], @"script created from extracted address should be the same as the original script");
    
    
    {
    	BTCKey* key = [[BTCKey alloc] init];
        NSString *addressB58 = key.compressedPublicKeyAddress.string;
        NSString *privKeyB58 = key.privateKeyAddress.string;
        
        //NSLog(@"Address1: %@", addressB58);
        //NSLog(@"PrivKey1: %@", privKeyB58);
        
        // get address from private key

        if (1) // this assert fails because it creates data = <00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000> because it's cleared when address is dealloc'd.
        {
            NSData *privkey01 = [[BTCAddress addressWithString:privKeyB58] data];

            NSAssert([privkey01 isEqual:key.privateKey], @"private key should be the same");
        }
        
        // However, if we assign intermediate object to a variable, everything works fine. Need to investigate.
        BTCPrivateKeyAddress* pkaddr = [BTCPrivateKeyAddress addressWithString:privKeyB58];
        NSData *privkey = pkaddr.data;
        
        NSAssert([privkey isEqual:key.privateKey], @"private key should be the same");
        
        BTCKey* key2 = [[BTCKey alloc] initWithPrivateKey:privkey];
//        BTCAddress* pubkeyAddress = [BTCPublicKeyAddress addressWithData:BTCHash160(key2.publicKey)];
//        BTCAddress* privkeyAddress = [BTCPrivateKeyAddress addressWithData:key2.privateKey];

        //NSLog(@"Address2: %@", pubkeyAddress.base58String);
        //NSLog(@"PrivKey2: %@", privkeyAddress.base58String);
        
        NSString *address2 = key2.compressedPublicKeyAddress.string;
        //NSLog(@"Address1 %@ Equal Address2", [addressB58 isEqualToString:address2] ? @"is": @"is NOT");
        NSAssert([addressB58 isEqualToString:address2], @"addresses must be equal");
    }
    
}

+ (void) testScriptModifications {
    // 
}

+ (void) testStrangeScripts {
//    @[@"2147483648 0 ADD", @"NOP", @"arithmetic operands must be in range @[-2^31...2^31] "],
//    @[@"-2147483648 0 ADD", @"NOP", @"arithmetic operands must be in range @[-2^31...2^31] "],
//    @[@"2147483647 DUP ADD", @"4294967294 NUMEQUAL", @"NUMEQUAL must be in numeric range"],
    
    BTCScript* script = [[BTCScript alloc] initWithString:@"2147483648 0 OP_ADD"];
    
    NSAssert(script, @"should be valid script");
    
    BTCScriptMachine* scriptMachine = [[BTCScriptMachine alloc] init];
    scriptMachine.verificationFlags = BTCScriptVerificationStrictEncoding;
    scriptMachine.inputScript = script;
    
    NSError* error = nil;
    if (![scriptMachine verifyWithOutputScript:[[BTCScript alloc] initWithString:@"OP_NOP"] error:&error]) {
//        NSLog(@"error: %@", error);
    } else {
//        NSLog(@"script passed: %@", script);
    }
}


BTCTransaction* BuildCreditingTransaction(BTCScript* scriptPubKey) {
    BTCTransaction* txCredit = [[BTCTransaction alloc] init];
    txCredit.version = 1;
    txCredit.lockTime = 0;
    BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
    txin.previousHash = BTCZero256();
    txin.previousIndex = 0xffffffff;
    txin.coinbaseData = [[[BTCScript new] appendOpcode:OP_0] appendOpcode:OP_0].data;
    [txCredit addInput:txin];
    BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
    txout.script = scriptPubKey;
    txout.value = 0;
    [txCredit addOutput:txout];
    return txCredit;
}

BTCTransaction* BuildSpendingTransaction(BTCScript* scriptSig, BTCTransaction* txCredit) {
    BTCTransaction* txSpend =[[BTCTransaction alloc] init];
    txSpend.version = 1;
    txSpend.lockTime = 0;
    BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
    txin.previousHash = txCredit.transactionHash;
    txin.previousIndex = 0;
    txin.signatureScript = scriptSig;
    txin.sequence = 0xffffffff;
    [txSpend addInput:txin];
    BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
    txout.script = [[BTCScript alloc] init];
    txout.value = 0;
    [txSpend addOutput:txout];
    return txSpend;
}



+ (void) testValidBitcoinQTScripts {
//    // 7f33a2f5ace097f071010d5105e7fd01f22c83d8d5daa741a41f2a630a2af23b
//    NSLog(@"crediting tx: %@", BuildCreditingTransaction([BTCScript new]).transactionID);
//    // add55eb99bb1f653ab822ea4177cb0f9673bcc5c2c4c729894ab0c626c8fa1e1
//    NSLog(@"spending tx:  %@", BuildSpendingTransaction([BTCScript new], BuildCreditingTransaction([BTCScript new])).transactionID);

    for (NSArray* tuple in [self validBitcoinQTScripts]) {
        NSString* inputScriptString = tuple[0];
        NSString* outputScriptString = tuple[1];
        NSString* comment = tuple.count > 2 ? tuple[2] : @"Script should not fail";
        
        BTCScript* inputScript = [[BTCScript alloc] initWithString:inputScriptString];
        if (!inputScript) {
            // for breakpoint
            inputScript = [[BTCScript alloc] initWithString:inputScriptString];
        }
        BTCScript* outputScript = [[BTCScript alloc] initWithString:outputScriptString];
        if (!outputScript) {
            // for breakpoint
            outputScript = [[BTCScript alloc] initWithString:outputScriptString];
        }
        
        NSAssert(inputScript, @"Input script must be well-formed");
        NSAssert(outputScript, @"Output script must be well-formed");
        
        BTCScriptMachine* scriptMachine = [[BTCScriptMachine alloc] init];
        scriptMachine.transaction = BuildSpendingTransaction(inputScript, BuildCreditingTransaction(outputScript));
        scriptMachine.inputIndex = 0;
        scriptMachine.verificationFlags = BTCScriptVerificationStrictEncoding;
        scriptMachine.inputScript = inputScript;
        
        NSError* error = nil;
        if (![scriptMachine verifyWithOutputScript:outputScript error:&error]) {
            NSLog(@"BTCScript validation error: %@ (%@)", error, comment);
            
            // for breakpoint.
            [scriptMachine verifyWithOutputScript:outputScript error:&error];
            NSAssert(0, comment);
        }
    }
}

+ (void) testInvalidBitcoinQTScripts {
    for (NSArray* tuple in [self invalidBitcoinQTScripts]) {
        NSString* inputScriptString = tuple[0];
        NSString* outputScriptString = tuple[1];
        NSString* comment = tuple.count > 2 ? tuple[2] : @"Script should not fail";
        
        BTCScript* inputScript = [[BTCScript alloc] initWithString:inputScriptString];
        
        // Script is malformed, it's okay.
        if (!inputScript) continue;
        
        BTCScript* outputScript = [[BTCScript alloc] initWithString:outputScriptString];
        
        // Script is malformed, it's okay.
        if (!outputScript) continue;
        
        BTCScriptMachine* scriptMachine = [[BTCScriptMachine alloc] init];
        scriptMachine.transaction = BuildSpendingTransaction(inputScript, BuildCreditingTransaction(outputScript));
        scriptMachine.inputIndex = 0;
        scriptMachine.verificationFlags = BTCScriptVerificationStrictEncoding;
        scriptMachine.inputScript = inputScript;
        
        NSError* error = nil;
        if ([scriptMachine verifyWithOutputScript:outputScript error:&error]) {
            // for breakpoint.
            [scriptMachine verifyWithOutputScript:outputScript error:&error];
            NSAssert(0, comment);
        }
    }
}



// Data

+ (NSArray*) validBitcoinQTScripts {
    return @[
                              @[@"0x01 0x0b", @"11 EQUAL", @"push 1 byte"],
                              @[@"0x02 0x417a", @"'Az' EQUAL"],
                              @[@"0x4b 0x417a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a",
                                @"'Azzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz' EQUAL", @"push 75 bytes"],
                              
                              @[@"0x4c 0x01 0x07",@"7 EQUAL", @"0x4c is OP_PUSHDATA1"],
                              @[@"0x4d 0x0100 0x08",@"8 EQUAL", @"0x4d is OP_PUSHDATA2"],
                              @[@"0x4e 0x01000000 0x09",@"9 EQUAL", @"0x4e is OP_PUSHDATA4"],
                              
                              @[@"0x4c 0x00",@"0 EQUAL"],
                              @[@"0x4d 0x0000",@"0 EQUAL"],
                              @[@"0x4e 0x00000000",@"0 EQUAL"],
                              @[@"0x4f 1000 ADD",@"999 EQUAL"],
                              @[@"0", @"IF 0x50 ENDIF 1", @"0x50 is reserved (ok if not executed)"],
                              @[@"0x51", @"0x5f ADD 0x60 EQUAL", @"0x51 through 0x60 push 1 through 16 onto stack"],
                              @[@"1",@"NOP"],
                              @[@"0", @"IF VER ELSE 1 ENDIF", @"VER non-functional (ok if not executed)"],
                              @[@"0", @"IF RESERVED RESERVED1 RESERVED2 ELSE 1 ENDIF", @"RESERVED ok in un-executed IF"],
                              
                              @[@"1", @"DUP IF ENDIF"],
                              @[@"1", @"IF 1 ENDIF"],
                              @[@"1", @"DUP IF ELSE ENDIF"],
                              @[@"1", @"IF 1 ELSE ENDIF"],
                              @[@"0", @"IF ELSE 1 ENDIF"],
                              
                              @[@"1 1", @"IF IF 1 ELSE 0 ENDIF ENDIF"],
                              @[@"1 0", @"IF IF 1 ELSE 0 ENDIF ENDIF"],
                              @[@"1 1", @"IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
                              @[@"0 0", @"IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
                              
                              @[@"1 0", @"NOTIF IF 1 ELSE 0 ENDIF ENDIF"],
                              @[@"1 1", @"NOTIF IF 1 ELSE 0 ENDIF ENDIF"],
                              @[@"1 0", @"NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
                              @[@"0 1", @"NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
                              
                              @[@"0", @"IF 0 ELSE 1 ELSE 0 ENDIF", @"Multiple ELSE's are valid and executed inverts on each ELSE encountered"],
                              @[@"1", @"IF 1 ELSE 0 ELSE ENDIF"],
                              @[@"1", @"IF ELSE 0 ELSE 1 ENDIF"],
                              @[@"1", @"IF 1 ELSE 0 ELSE 1 ENDIF ADD 2 EQUAL"],
                              @[@"'' 1", @"IF SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ENDIF 0x14 0x68ca4fec736264c13b859bac43d5173df6871682 EQUAL"],
                              
                              @[@"1", @"NOTIF 0 ELSE 1 ELSE 0 ENDIF", @"Multiple ELSE's are valid and execution inverts on each ELSE encountered"],
                              @[@"0", @"NOTIF 1 ELSE 0 ELSE ENDIF"],
                              @[@"0", @"NOTIF ELSE 0 ELSE 1 ENDIF"],
                              @[@"0", @"NOTIF 1 ELSE 0 ELSE 1 ENDIF ADD 2 EQUAL"],
                              @[@"'' 0", @"NOTIF SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ENDIF 0x14 0x68ca4fec736264c13b859bac43d5173df6871682 EQUAL"],
                              
                              @[@"0", @"IF 1 IF RETURN ELSE RETURN ELSE RETURN ENDIF ELSE 1 IF 1 ELSE RETURN ELSE 1 ENDIF ELSE RETURN ENDIF ADD 2 EQUAL", @"Nested ELSE ELSE"],
                              @[@"1", @"NOTIF 0 NOTIF RETURN ELSE RETURN ELSE RETURN ENDIF ELSE 0 NOTIF 1 ELSE RETURN ELSE 1 ENDIF ELSE RETURN ENDIF ADD 2 EQUAL"],
                              
                              @[@"0", @"IF RETURN ENDIF 1", @"RETURN only works if executed"],
                              
                              @[@"1 1", @"VERIFY"],
                              
                              @[@"10 0 11 TOALTSTACK DROP FROMALTSTACK", @"ADD 21 EQUAL"],
                              @[@"'gavin_was_here' TOALTSTACK 11 FROMALTSTACK", @"'gavin_was_here' EQUALVERIFY 11 EQUAL"],
                              
                              @[@"0 IFDUP", @"DEPTH 1 EQUALVERIFY 0 EQUAL"],
                              @[@"1 IFDUP", @"DEPTH 2 EQUALVERIFY 1 EQUALVERIFY 1 EQUAL"],
                              @[@"0 DROP", @"DEPTH 0 EQUAL"],
                              @[@"0", @"DUP 1 ADD 1 EQUALVERIFY 0 EQUAL"],
                              @[@"0 1", @"NIP"],
                              @[@"1 0", @"OVER DEPTH 3 EQUALVERIFY"],
                              @[@"22 21 20", @"0 PICK 20 EQUALVERIFY DEPTH 3 EQUAL"],
                              @[@"22 21 20", @"1 PICK 21 EQUALVERIFY DEPTH 3 EQUAL"],
                              @[@"22 21 20", @"2 PICK 22 EQUALVERIFY DEPTH 3 EQUAL"],
                              @[@"22 21 20", @"0 ROLL 20 EQUALVERIFY DEPTH 2 EQUAL"],
                              @[@"22 21 20", @"1 ROLL 21 EQUALVERIFY DEPTH 2 EQUAL"],
                              @[@"22 21 20", @"2 ROLL 22 EQUALVERIFY DEPTH 2 EQUAL"],
                              @[@"22 21 20", @"ROT 22 EQUAL"],
                              @[@"22 21 20", @"ROT DROP 20 EQUAL"],
                              @[@"22 21 20", @"ROT DROP DROP 21 EQUAL"],
                              @[@"22 21 20", @"ROT ROT 21 EQUAL"],
                              @[@"22 21 20", @"ROT ROT ROT 20 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 24 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT DROP 25 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2DROP 20 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2DROP DROP 21 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2DROP 2DROP 22 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2DROP 2DROP DROP 23 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2ROT 22 EQUAL"],
                              @[@"25 24 23 22 21 20", @"2ROT 2ROT 2ROT 20 EQUAL"],
                              @[@"1 0", @"SWAP 1 EQUALVERIFY 0 EQUAL"],
                              @[@"0 1", @"TUCK DEPTH 3 EQUALVERIFY SWAP 2DROP"],
                              @[@"13 14", @"2DUP ROT EQUALVERIFY EQUAL"],
                              @[@"-1 0 1 2", @"3DUP DEPTH 7 EQUALVERIFY ADD ADD 3 EQUALVERIFY 2DROP 0 EQUALVERIFY"],
                              @[@"1 2 3 5", @"2OVER ADD ADD 8 EQUALVERIFY ADD ADD 6 EQUAL"],
                              @[@"1 3 5 7", @"2SWAP ADD 4 EQUALVERIFY ADD 12 EQUAL"],
                              @[@"0", @"SIZE 0 EQUAL"],
                              @[@"1", @"SIZE 1 EQUAL"],
                              @[@"127", @"SIZE 1 EQUAL"],
                              @[@"128", @"SIZE 2 EQUAL"],
                              @[@"32767", @"SIZE 2 EQUAL"],
                              @[@"32768", @"SIZE 3 EQUAL"],
                              @[@"8388607", @"SIZE 3 EQUAL"],
                              @[@"8388608", @"SIZE 4 EQUAL"],
                              @[@"2147483647", @"SIZE 4 EQUAL"],
                              @[@"2147483648", @"SIZE 5 EQUAL"],
                              @[@"-1", @"SIZE 1 EQUAL"],
                              @[@"-127", @"SIZE 1 EQUAL"],
                              @[@"-128", @"SIZE 2 EQUAL"],
                              @[@"-32767", @"SIZE 2 EQUAL"],
                              @[@"-32768", @"SIZE 3 EQUAL"],
                              @[@"-8388607", @"SIZE 3 EQUAL"],
                              @[@"-8388608", @"SIZE 4 EQUAL"],
                              @[@"-2147483647", @"SIZE 4 EQUAL"],
                              @[@"-2147483648", @"SIZE 5 EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"SIZE 26 EQUAL"],
                              
                              
                              @[@"2 -2 ADD", @"0 EQUAL"],
                              @[@"2147483647 -2147483647 ADD", @"0 EQUAL"],
                              @[@"-1 -1 ADD", @"-2 EQUAL"],
                              
                              @[@"0 0",@"EQUAL"],
                              @[@"1 1 ADD", @"2 EQUAL"],
                              @[@"1 1ADD", @"2 EQUAL"],
                              @[@"111 1SUB", @"110 EQUAL"],
                              @[@"111 1 ADD 12 SUB", @"100 EQUAL"],
                              @[@"0 ABS", @"0 EQUAL"],
                              @[@"16 ABS", @"16 EQUAL"],
                              @[@"-16 ABS", @"-16 NEGATE EQUAL"],
                              @[@"0 NOT", @"NOP"],
                              @[@"1 NOT", @"0 EQUAL"],
                              @[@"11 NOT", @"0 EQUAL"],
                              @[@"0 0NOTEQUAL", @"0 EQUAL"],
                              @[@"1 0NOTEQUAL", @"1 EQUAL"],
                              @[@"111 0NOTEQUAL", @"1 EQUAL"],
                              @[@"-111 0NOTEQUAL", @"1 EQUAL"],
                              @[@"1 1 BOOLAND", @"NOP"],
                              @[@"1 0 BOOLAND", @"NOT"],
                              @[@"0 1 BOOLAND", @"NOT"],
                              @[@"0 0 BOOLAND", @"NOT"],
                              @[@"16 17 BOOLAND", @"NOP"],
                              @[@"1 1 BOOLOR", @"NOP"],
                              @[@"1 0 BOOLOR", @"NOP"],
                              @[@"0 1 BOOLOR", @"NOP"],
                              @[@"0 0 BOOLOR", @"NOT"],
                              @[@"16 17 BOOLOR", @"NOP"],
                              @[@"11 10 1 ADD", @"NUMEQUAL"],
                              @[@"11 10 1 ADD", @"NUMEQUALVERIFY 1"],
                              @[@"11 10 1 ADD", @"NUMNOTEQUAL NOT"],
                              @[@"111 10 1 ADD", @"NUMNOTEQUAL"],
                              @[@"11 10", @"LESSTHAN NOT"],
                              @[@"4 4", @"LESSTHAN NOT"],
                              @[@"10 11", @"LESSTHAN"],
                              @[@"-11 11", @"LESSTHAN"],
                              @[@"-11 -10", @"LESSTHAN"],
                              @[@"11 10", @"GREATERTHAN"],
                              @[@"4 4", @"GREATERTHAN NOT"],
                              @[@"10 11", @"GREATERTHAN NOT"],
                              @[@"-11 11", @"GREATERTHAN NOT"],
                              @[@"-11 -10", @"GREATERTHAN NOT"],
                              @[@"11 10", @"LESSTHANOREQUAL NOT"],
                              @[@"4 4", @"LESSTHANOREQUAL"],
                              @[@"10 11", @"LESSTHANOREQUAL"],
                              @[@"-11 11", @"LESSTHANOREQUAL"],
                              @[@"-11 -10", @"LESSTHANOREQUAL"],
                              @[@"11 10", @"GREATERTHANOREQUAL"],
                              @[@"4 4", @"GREATERTHANOREQUAL"],
                              @[@"10 11", @"GREATERTHANOREQUAL NOT"],
                              @[@"-11 11", @"GREATERTHANOREQUAL NOT"],
                              @[@"-11 -10", @"GREATERTHANOREQUAL NOT"],
                              @[@"1 0 MIN", @"0 NUMEQUAL"],
                              @[@"0 1 MIN", @"0 NUMEQUAL"],
                              @[@"-1 0 MIN", @"-1 NUMEQUAL"],
                              @[@"0 -2147483647 MIN", @"-2147483647 NUMEQUAL"],
                              @[@"2147483647 0 MAX", @"2147483647 NUMEQUAL"],
                              @[@"0 100 MAX", @"100 NUMEQUAL"],
                              @[@"-100 0 MAX", @"0 NUMEQUAL"],
                              @[@"0 -2147483647 MAX", @"0 NUMEQUAL"],
                              @[@"0 0 1", @"WITHIN"],
                              @[@"1 0 1", @"WITHIN NOT"],
                              @[@"0 -2147483647 2147483647", @"WITHIN"],
                              @[@"-1 -100 100", @"WITHIN"],
                              @[@"11 -100 100", @"WITHIN"],
                              @[@"-2147483647 -100 100", @"WITHIN NOT"],
                              @[@"2147483647 -100 100", @"WITHIN NOT"],
                              
                              @[@"2147483647 2147483647 SUB", @"0 EQUAL"],
                              @[@"2147483647 DUP ADD", @"4294967294 EQUAL", @">32 bit EQUAL is valid"],
                              @[@"2147483647 NEGATE DUP ADD", @"-4294967294 EQUAL"],
                              
                              @[@"''", @"RIPEMD160 0x14 0x9c1185a5c5e9fc54612808977ee8f548b2258d31 EQUAL"],
                              @[@"'a'", @"RIPEMD160 0x14 0x0bdc9d2d256b3ee9daae347be6f4dc835a467ffe EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"RIPEMD160 0x14 0xf71c27109c692c1b56bbdceb5b9d2865b3708dbc EQUAL"],
                              @[@"''", @"SHA1 0x14 0xda39a3ee5e6b4b0d3255bfef95601890afd80709 EQUAL"],
                              @[@"'a'", @"SHA1 0x14 0x86f7e437faa5a7fce15d1ddcb9eaeaea377667b8 EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"SHA1 0x14 0x32d10c7b8cf96570ca04ce37f2a19d84240d3a89 EQUAL"],
                              @[@"''", @"SHA256 0x20 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 EQUAL"],
                              @[@"'a'", @"SHA256 0x20 0xca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"SHA256 0x20 0x71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73 EQUAL"],
                              @[@"''", @"DUP HASH160 SWAP SHA256 RIPEMD160 EQUAL"],
                              @[@"''", @"DUP HASH256 SWAP SHA256 SHA256 EQUAL"],
                              @[@"''", @"NOP HASH160 0x14 0xb472a266d0bd89c13706a4132ccfb16f7c3b9fcb EQUAL"],
                              @[@"'a'", @"HASH160 NOP 0x14 0x994355199e516ff76c4fa4aab39337b9d84cf12b EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"HASH160 0x4c 0x14 0xc286a1af0947f58d1ad787385b1c2c4a976f9e71 EQUAL"],
                              @[@"''", @"HASH256 0x20 0x5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456 EQUAL"],
                              @[@"'a'", @"HASH256 0x20 0xbf5d3affb73efd2ec6c36ad3112dd933efed63c4e1cbffcfa88e2759c144f2d8 EQUAL"],
                              @[@"'abcdefghijklmnopqrstuvwxyz'", @"HASH256 0x4c 0x20 0xca139bc10c2f660da42666f72e89a225936fc60f193c161124a672050c434671 EQUAL"],
                              
                              
                              @[@"1",@"NOP1 NOP2 NOP3 NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10 1 EQUAL"],
                              @[@"'NOP_1_to_10' NOP1 NOP2 NOP3 NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10",@"'NOP_1_to_10' EQUAL"],
                              
                              @[@"0", @"IF 0xba ELSE 1 ENDIF", @"opcodes above NOP10 invalid if executed"],
                              @[@"0", @"IF 0xbb ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xbc ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xbd ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xbe ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xbf ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc0 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc1 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc2 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc3 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc4 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc5 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc6 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc7 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc8 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xc9 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xca ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xcb ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xcc ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xcd ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xce ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xcf ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd0 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd1 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd2 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd3 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd4 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd5 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd6 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd7 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd8 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xd9 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xda ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xdb ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xdc ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xdd ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xde ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xdf ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe0 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe1 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe2 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe3 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe4 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe5 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe6 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe7 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe8 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xe9 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xea ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xeb ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xec ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xed ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xee ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xef ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf0 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf1 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf2 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf3 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf4 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf5 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf6 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf7 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf8 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xf9 ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xfa ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xfb ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xfc ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xfd ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xfe ELSE 1 ENDIF"],
                              @[@"0", @"IF 0xff ELSE 1 ENDIF"],
                              
                              @[@"NOP",
                                @"'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'",
                                @"520 byte push"],
                              @[@"1",
                                @"0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161",
                                @"201 opcodes executed. 0x61 is NOP"],
                              @[@"1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
                                @"1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
                                @"1,000 stack size (0x6f is 3DUP)"],
                              @[@"1 TOALTSTACK 2 TOALTSTACK 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
                                @"1 2 3 4 5 6 7 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
                                @"1,000 stack size (altstack cleared between scriptSig/scriptPubKey)"],
                              @[@"'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
                                @"'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f 2DUP 0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161",
                                @"Max-size (10,000-byte), max-push(520 bytes), max-opcodes(201), max stack size(1,000 items). 0x6f is 3DUP, 0x61 is NOP"],
                              
                              @[@"0",
                                @"IF 0x5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050 ENDIF 1",
                                @">201 opcodes, but RESERVED (0x50) doesn't count towards opcode limit."],
                              
                              @[@"NOP",@"1"],
                              
                              @[@"1", @"0x01 0x01 EQUAL", @"The following is useful for checking implementations of BN_bn2mpi"],
                              @[@"127", @"0x01 0x7F EQUAL"],
                              @[@"128", @"0x02 0x8000 EQUAL", @"Leave room for the sign bit"],
                              @[@"32767", @"0x02 0xFF7F EQUAL"],
                              @[@"32768", @"0x03 0x008000 EQUAL"],
                              @[@"8388607", @"0x03 0xFFFF7F EQUAL"],
                              @[@"8388608", @"0x04 0x00008000 EQUAL"],
                              @[@"2147483647", @"0x04 0xFFFFFF7F EQUAL"],
                              @[@"2147483648", @"0x05 0x0000008000 EQUAL"],
                              @[@"-1", @"0x01 0x81 EQUAL", @"Numbers are little-endian with the MSB being a sign bit"],
                              @[@"-127", @"0x01 0xFF EQUAL"],
                              @[@"-128", @"0x02 0x8080 EQUAL"],
                              @[@"-32767", @"0x02 0xFFFF EQUAL"],
                              @[@"-32768", @"0x03 0x008080 EQUAL"],
                              @[@"-8388607", @"0x03 0xFFFFFF EQUAL"],
                              @[@"-8388608", @"0x04 0x00008080 EQUAL"],
                              @[@"-2147483647", @"0x04 0xFFFFFFFF EQUAL"],
                              @[@"-2147483648", @"0x05 0x0000008080 EQUAL"],
                              
                              @[@"2147483647", @"1ADD 2147483648 EQUAL", @"We can do math on 4-byte integers, and compare 5-byte ones"],
                              @[@"2147483647", @"1ADD 1"],
                              @[@"-2147483647", @"1ADD 1"],
                              
                              @[@"1", @"0x02 0x0100 EQUAL NOT", @"Not the same byte array..."],
                              @[@"1", @"0x02 0x0100 NUMEQUAL", @"... but they are numerically equal"],
                              @[@"11", @"0x4c 0x03 0x0b0000 NUMEQUAL"],
                              @[@"0", @"0x01 0x80 EQUAL NOT"],
                              @[@"0", @"0x01 0x80 NUMEQUAL", @"Zero numerically equals negative zero"],
                              @[@"0", @"0x02 0x0080 NUMEQUAL"],
                              @[@"0x03 0x000080", @"0x04 0x00000080 NUMEQUAL"],
                              @[@"0x03 0x100080", @"0x04 0x10000080 NUMEQUAL"],
                              @[@"0x03 0x100000", @"0x04 0x10000000 NUMEQUAL"],
                              
                              @[@"NOP", @"NOP 1", @"The following tests check the if(stack.size() < N) tests in each opcode"],
                              @[@"1", @"IF 1 ENDIF", @"They are here to catch copy-and-paste errors"],
                              @[@"0", @"NOTIF 1 ENDIF", @"Most of them are duplicated elsewhere,"],
                              @[@"1", @"VERIFY 1", @"but, hey, more is always better, right?"],
                              
                              @[@"0", @"TOALTSTACK 1"],
                              @[@"1", @"TOALTSTACK FROMALTSTACK"],
                              @[@"0 0", @"2DROP 1"],
                              @[@"0 1", @"2DUP"],
                              @[@"0 0 1", @"3DUP"],
                              @[@"0 1 0 0", @"2OVER"],
                              @[@"0 1 0 0 0 0", @"2ROT"],
                              @[@"0 1 0 0", @"2SWAP"],
                              @[@"1", @"IFDUP"],
                              @[@"NOP", @"DEPTH 1"],
                              @[@"0", @"DROP 1"],
                              @[@"1", @"DUP"],
                              @[@"0 1", @"NIP"],
                              @[@"1 0", @"OVER"],
                              @[@"1 0 0 0 3", @"PICK"],
                              @[@"1 0", @"PICK"],
                              @[@"1 0 0 0 3", @"ROLL"],
                              @[@"1 0", @"ROLL"],
                              @[@"1 0 0", @"ROT"],
                              @[@"1 0", @"SWAP"],
                              @[@"0 1", @"TUCK"],
                              
                              @[@"1", @"SIZE"],
                              
                              @[@"0 0", @"EQUAL"],
                              @[@"0 0", @"EQUALVERIFY 1"],
                              
                              @[@"0", @"1ADD"],
                              @[@"2", @"1SUB"],
                              @[@"-1", @"NEGATE"],
                              @[@"-1", @"ABS"],
                              @[@"0", @"NOT"],
                              @[@"-1", @"0NOTEQUAL"],
                              
                              @[@"1 0", @"ADD"],
                              @[@"1 0", @"SUB"],
                              @[@"-1 -1", @"BOOLAND"],
                              @[@"-1 0", @"BOOLOR"],
                              @[@"0 0", @"NUMEQUAL"],
                              @[@"0 0", @"NUMEQUALVERIFY 1"],
                              @[@"-1 0", @"NUMNOTEQUAL"],
                              @[@"-1 0", @"LESSTHAN"],
                              @[@"1 0", @"GREATERTHAN"],
                              @[@"0 0", @"LESSTHANOREQUAL"],
                              @[@"0 0", @"GREATERTHANOREQUAL"],
                              @[@"-1 0", @"MIN"],
                              @[@"1 0", @"MAX"],
                              @[@"-1 -1 0", @"WITHIN"],
                              
                              @[@"0", @"RIPEMD160"],
                              @[@"0", @"SHA1"],
                              @[@"0", @"SHA256"],
                              @[@"0", @"HASH160"],
                              @[@"0", @"HASH256"],
                              @[@"NOP", @"CODESEPARATOR 1"],
                              
                              @[@"NOP", @"NOP1 1"],
                              @[@"NOP", @"NOP2 1"],
                              @[@"NOP", @"NOP3 1"],
                              @[@"NOP", @"NOP4 1"],
                              @[@"NOP", @"NOP5 1"],
                              @[@"NOP", @"NOP6 1"],
                              @[@"NOP", @"NOP7 1"],
                              @[@"NOP", @"NOP8 1"],
                              @[@"NOP", @"NOP9 1"],
                              @[@"NOP", @"NOP10 1"],
                              
                              @[@"0 0x01 1", @"HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL", @"Very basic P2SH"],
                              @[@"0x4c 0 0x01 1", @"HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL"],
                              
                              @[@"0x40 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242",
                                @"0x4d 0x4000 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242 EQUAL",
                                @"Basic PUSH signedness check"],
                              
                              @[@"0x4c 0x40 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242",
                                @"0x4d 0x4000 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242 EQUAL",
                                @"Basic PUSHDATA1 signedness check"],

                              @[@"0x47 0x304402200a5c6163f07b8d3b013c4d1d6dba25e780b39658d79ba37af7057a3b7f15ffa102201fd9b4eaa9943f734928b99a83592c2e7bf342ea2680f6a2bb705167966b742001",
                                @"0x41 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG",
                                @"P2PK"],
                              @[
                               @"0x47 0x304402206e05a6fe23c59196ffe176c9ddc31e73a9885638f9d1328d47c0c703863b8876022076feb53811aa5b04e0e79f938eb19906cc5e67548bc555a8e8b8b0fc603d840c01 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508",
                               @"DUP HASH160 0x14 0x1018853670f9f3b0582c5b9ee8ce93764ac32b93 EQUALVERIFY CHECKSIG",
                               @"P2PKH"
                               ],
                              @[
                               @"0x47 0x304402204710a85181663b32d25c70ec2bbd14adff5ddfff6cb50d09e155ef5f541fc86c0220056b0cc949be9386ecc5f6c2ac0493269031dbb185781db90171b54ac127790281",
                               @"0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG",
                               @"P2PK anyonecanpay"
                               ]
                              ];
}

+ (NSArray*) invalidBitcoinQTScripts {
    return @[
  @[@"", @""],
  @[@"", @"NOP"],
  @[@"NOP", @""],
  @[@"NOP",@"NOP"],
  
  @[@"0x4c01",@"0x01 NOP", @"PUSHDATA1 with not enough bytes"],
  @[@"0x4d0200ff",@"0x01 NOP", @"PUSHDATA2 with not enough bytes"],
  @[@"0x4e03000000ffff",@"0x01 NOP", @"PUSHDATA4 with not enough bytes"],
  
  @[@"1", @"IF 0x50 ENDIF 1", @"0x50 is reserved"],
  @[@"0x52", @"0x5f ADD 0x60 EQUAL", @"0x51 through 0x60 push 1 through 16 onto stack"],
  @[@"0",@"NOP"],
  @[@"1", @"IF VER ELSE 1 ENDIF", @"VER non-functional"],
  @[@"0", @"IF VERIF ELSE 1 ENDIF", @"VERIF illegal everywhere"],
  @[@"0", @"IF ELSE 1 ELSE VERIF ENDIF", @"VERIF illegal everywhere"],
  @[@"0", @"IF VERNOTIF ELSE 1 ENDIF", @"VERNOTIF illegal everywhere"],
  @[@"0", @"IF ELSE 1 ELSE VERNOTIF ENDIF", @"VERNOTIF illegal everywhere"],
  
  @[@"1 IF", @"1 ENDIF", @"IF/ENDIF can't span scriptSig/scriptPubKey"],
  @[@"1 IF 0 ENDIF", @"1 ENDIF"],
  @[@"1 ELSE 0 ENDIF", @"1"],
  @[@"0 NOTIF", @"123"],
  
  @[@"0", @"DUP IF ENDIF"],
  @[@"0", @"IF 1 ENDIF"],
  @[@"0", @"DUP IF ELSE ENDIF"],
  @[@"0", @"IF 1 ELSE ENDIF"],
  @[@"0", @"NOTIF ELSE 1 ENDIF"],
  
  @[@"0 1", @"IF IF 1 ELSE 0 ENDIF ENDIF"],
  @[@"0 0", @"IF IF 1 ELSE 0 ENDIF ENDIF"],
  @[@"1 0", @"IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
  @[@"0 1", @"IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
  
  @[@"0 0", @"NOTIF IF 1 ELSE 0 ENDIF ENDIF"],
  @[@"0 1", @"NOTIF IF 1 ELSE 0 ENDIF ENDIF"],
  @[@"1 1", @"NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
  @[@"0 0", @"NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF"],
  
  @[@"1", @"IF RETURN ELSE ELSE 1 ENDIF", @"Multiple ELSEs"],
  @[@"1", @"IF 1 ELSE ELSE RETURN ENDIF"],
  
  @[@"1", @"ENDIF", @"Malformed IF/ELSE/ENDIF sequence"],
  @[@"1", @"ELSE ENDIF"],
  @[@"1", @"ENDIF ELSE"],
  @[@"1", @"ENDIF ELSE IF"],
  @[@"1", @"IF ELSE ENDIF ELSE"],
  @[@"1", @"IF ELSE ENDIF ELSE ENDIF"],
  @[@"1", @"IF ENDIF ENDIF"],
  @[@"1", @"IF ELSE ELSE ENDIF ENDIF"],
  
  @[@"1", @"RETURN"],
  @[@"1", @"DUP IF RETURN ENDIF"],
  
  @[@"1", @"RETURN 'data'", @"canonical prunable txout format"],
  @[@"0 IF", @"RETURN ENDIF 1", @"still prunable because IF/ENDIF can't span scriptSig/scriptPubKey"],
  
  @[@"0", @"VERIFY 1"],
  @[@"1", @"VERIFY"],
  @[@"1", @"VERIFY 0"],
  
  @[@"1 TOALTSTACK", @"FROMALTSTACK 1", @"alt stack not shared between sig/pubkey"],
  
  @[@"IFDUP", @"DEPTH 0 EQUAL"],
  @[@"DROP", @"DEPTH 0 EQUAL"],
  @[@"DUP", @"DEPTH 0 EQUAL"],
  @[@"1", @"DUP 1 ADD 2 EQUALVERIFY 0 EQUAL"],
  @[@"NOP", @"NIP"],
  @[@"NOP", @"1 NIP"],
  @[@"NOP", @"1 0 NIP"],
  @[@"NOP", @"OVER 1"],
  @[@"1", @"OVER"],
  @[@"0 1", @"OVER DEPTH 3 EQUALVERIFY"],
  @[@"19 20 21", @"PICK 19 EQUALVERIFY DEPTH 2 EQUAL"],
  @[@"NOP", @"0 PICK"],
  @[@"1", @"-1 PICK"],
  @[@"19 20 21", @"0 PICK 20 EQUALVERIFY DEPTH 3 EQUAL"],
  @[@"19 20 21", @"1 PICK 21 EQUALVERIFY DEPTH 3 EQUAL"],
  @[@"19 20 21", @"2 PICK 22 EQUALVERIFY DEPTH 3 EQUAL"],
  @[@"NOP", @"0 ROLL"],
  @[@"1", @"-1 ROLL"],
  @[@"19 20 21", @"0 ROLL 20 EQUALVERIFY DEPTH 2 EQUAL"],
  @[@"19 20 21", @"1 ROLL 21 EQUALVERIFY DEPTH 2 EQUAL"],
  @[@"19 20 21", @"2 ROLL 22 EQUALVERIFY DEPTH 2 EQUAL"],
  @[@"NOP", @"ROT 1"],
  @[@"NOP", @"1 ROT 1"],
  @[@"NOP", @"1 2 ROT 1"],
  @[@"NOP", @"0 1 2 ROT"],
  @[@"NOP", @"SWAP 1"],
  @[@"1", @"SWAP 1"],
  @[@"0 1", @"SWAP 1 EQUALVERIFY"],
  @[@"NOP", @"TUCK 1"],
  @[@"1", @"TUCK 1"],
  @[@"1 0", @"TUCK DEPTH 3 EQUALVERIFY SWAP 2DROP"],
  @[@"NOP", @"2DUP 1"],
  @[@"1", @"2DUP 1"],
  @[@"NOP", @"3DUP 1"],
  @[@"1", @"3DUP 1"],
  @[@"1 2", @"3DUP 1"],
  @[@"NOP", @"2OVER 1"],
  @[@"1", @"2 3 2OVER 1"],
  @[@"NOP", @"2SWAP 1"],
  @[@"1", @"2 3 2SWAP 1"],
  
  @[@"'a' 'b'", @"CAT", @"CAT disabled"],
  @[@"'a' 'b' 0", @"IF CAT ELSE 1 ENDIF", @"CAT disabled"],
  @[@"'abc' 1 1", @"SUBSTR", @"SUBSTR disabled"],
  @[@"'abc' 1 1 0", @"IF SUBSTR ELSE 1 ENDIF", @"SUBSTR disabled"],
  @[@"'abc' 2 0", @"IF LEFT ELSE 1 ENDIF", @"LEFT disabled"],
  @[@"'abc' 2 0", @"IF RIGHT ELSE 1 ENDIF", @"RIGHT disabled"],
  
  @[@"NOP", @"SIZE 1"],
  
  @[@"'abc'", @"IF INVERT ELSE 1 ENDIF", @"INVERT disabled"],
  @[@"1 2 0 IF AND ELSE 1 ENDIF", @"NOP", @"AND disabled"],
  @[@"1 2 0 IF OR ELSE 1 ENDIF", @"NOP", @"OR disabled"],
  @[@"1 2 0 IF XOR ELSE 1 ENDIF", @"NOP", @"XOR disabled"],
  @[@"2 0 IF 2MUL ELSE 1 ENDIF", @"NOP", @"2MUL disabled"],
  @[@"2 0 IF 2DIV ELSE 1 ENDIF", @"NOP", @"2DIV disabled"],
  @[@"2 2 0 IF MUL ELSE 1 ENDIF", @"NOP", @"MUL disabled"],
  @[@"2 2 0 IF DIV ELSE 1 ENDIF", @"NOP", @"DIV disabled"],
  @[@"2 2 0 IF MOD ELSE 1 ENDIF", @"NOP", @"MOD disabled"],
  @[@"2 2 0 IF LSHIFT ELSE 1 ENDIF", @"NOP", @"LSHIFT disabled"],
  @[@"2 2 0 IF RSHIFT ELSE 1 ENDIF", @"NOP", @"RSHIFT disabled"],
  
  @[@"0 1",@"EQUAL"],
  @[@"1 1 ADD", @"0 EQUAL"],
  @[@"11 1 ADD 12 SUB", @"11 EQUAL"],
  
  @[@"2147483648 0 ADD", @"NOP", @"arithmetic operands must be in range @[-2^31...2^31] "],
  @[@"-2147483648 0 ADD", @"NOP", @"arithmetic operands must be in range @[-2^31...2^31] "],
  @[@"2147483647 DUP ADD", @"4294967294 NUMEQUAL", @"NUMEQUAL must be in numeric range"],
  @[@"'abcdef' NOT", @"0 EQUAL", @"NOT is an arithmetic operand"],
  
  @[@"2 DUP MUL", @"4 EQUAL", @"disabled"],
  @[@"2 DUP DIV", @"1 EQUAL", @"disabled"],
  @[@"2 2MUL", @"4 EQUAL", @"disabled"],
  @[@"2 2DIV", @"1 EQUAL", @"disabled"],
  @[@"7 3 MOD", @"1 EQUAL", @"disabled"],
  @[@"2 2 LSHIFT", @"8 EQUAL", @"disabled"],
  @[@"2 1 RSHIFT", @"1 EQUAL", @"disabled"],
  
  @[@"1",@"NOP1 NOP2 NOP3 NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10 2 EQUAL"],
  @[@"'NOP_1_to_10' NOP1 NOP2 NOP3 NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10",@"'NOP_1_to_11' EQUAL"],
  
  @[@"0x50",@"1", @"opcode 0x50 is reserved"],
  @[@"1", @"IF 0xba ELSE 1 ENDIF", @"opcodes above NOP10 invalid if executed"],
  @[@"1", @"IF 0xbb ELSE 1 ENDIF"],
  @[@"1", @"IF 0xbc ELSE 1 ENDIF"],
  @[@"1", @"IF 0xbd ELSE 1 ENDIF"],
  @[@"1", @"IF 0xbe ELSE 1 ENDIF"],
  @[@"1", @"IF 0xbf ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc0 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc1 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc2 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc3 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc4 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc5 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc6 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc7 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc8 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xc9 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xca ELSE 1 ENDIF"],
  @[@"1", @"IF 0xcb ELSE 1 ENDIF"],
  @[@"1", @"IF 0xcc ELSE 1 ENDIF"],
  @[@"1", @"IF 0xcd ELSE 1 ENDIF"],
  @[@"1", @"IF 0xce ELSE 1 ENDIF"],
  @[@"1", @"IF 0xcf ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd0 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd1 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd2 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd3 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd4 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd5 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd6 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd7 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd8 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xd9 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xda ELSE 1 ENDIF"],
  @[@"1", @"IF 0xdb ELSE 1 ENDIF"],
  @[@"1", @"IF 0xdc ELSE 1 ENDIF"],
  @[@"1", @"IF 0xdd ELSE 1 ENDIF"],
  @[@"1", @"IF 0xde ELSE 1 ENDIF"],
  @[@"1", @"IF 0xdf ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe0 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe1 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe2 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe3 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe4 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe5 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe6 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe7 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe8 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xe9 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xea ELSE 1 ENDIF"],
  @[@"1", @"IF 0xeb ELSE 1 ENDIF"],
  @[@"1", @"IF 0xec ELSE 1 ENDIF"],
  @[@"1", @"IF 0xed ELSE 1 ENDIF"],
  @[@"1", @"IF 0xee ELSE 1 ENDIF"],
  @[@"1", @"IF 0xef ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf0 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf1 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf2 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf3 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf4 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf5 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf6 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf7 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf8 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xf9 ELSE 1 ENDIF"],
  @[@"1", @"IF 0xfa ELSE 1 ENDIF"],
  @[@"1", @"IF 0xfb ELSE 1 ENDIF"],
  @[@"1", @"IF 0xfc ELSE 1 ENDIF"],
  @[@"1", @"IF 0xfd ELSE 1 ENDIF"],
  @[@"1", @"IF 0xfe ELSE 1 ENDIF"],
  @[@"1", @"IF 0xff ELSE 1 ENDIF"],
  
  @[@"1 IF 1 ELSE", @"0xff ENDIF", @"invalid because scriptSig and scriptPubKey are processed separately"],
  
  @[@"NOP", @"RIPEMD160"],
  @[@"NOP", @"SHA1"],
  @[@"NOP", @"SHA256"],
  @[@"NOP", @"HASH160"],
  @[@"NOP", @"HASH256"],
  
  @[@"NOP",
    @"'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'",
    @">520 byte push"],
  @[@"0",
    @"IF 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' ENDIF 1",
    @">520 byte push in non-executed IF branch"],
  @[@"1",
    @"0x61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161",
    @">201 opcodes executed. 0x61 is NOP"],
  @[@"0",
    @"IF 0x6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161 ENDIF 1",
    @">201 opcodes including non-executed IF branch. 0x61 is NOP"],
  @[@"1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
    @"1 2 3 4 5 6 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
    @">1,000 stack size (0x6f is 3DUP)"],
  @[@"1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
    @"1 TOALTSTACK 2 TOALTSTACK 3 4 5 6 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f",
    @">1,000 stack+altstack size"],
  @[@"NOP",
    @"0 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f 2DUP 0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161",
    @"10,001-byte scriptPubKey"],
  
  @[@"NOP1",@"NOP10"],
  
  @[@"1",@"VER", @"OP_VER is reserved"],
  @[@"1",@"VERIF", @"OP_VERIF is reserved"],
  @[@"1",@"VERNOTIF", @"OP_VERNOTIF is reserved"],
  @[@"1",@"RESERVED", @"OP_RESERVED is reserved"],
  @[@"1",@"RESERVED1", @"OP_RESERVED1 is reserved"],
  @[@"1",@"RESERVED2", @"OP_RESERVED2 is reserved"],
  @[@"1",@"0xba", @"0xba == OP_NOP10 + 1"],
  
  @[@"2147483648", @"1ADD 1", @"We cannot do math on 5-byte integers"],
  @[@"-2147483648", @"1ADD 1", @"Because we use a sign bit, -2147483648 is also 5 bytes"],
  
  @[@"1", @"1 ENDIF", @"ENDIF without IF"],
  @[@"1", @"IF 1", @"IF without ENDIF"],
  @[@"1 IF 1", @"ENDIF", @"IFs don't carry over"],
  
  @[@"NOP", @"IF 1 ENDIF", @"The following tests check the if(stack.size() < N) tests in each opcode"],
  @[@"NOP", @"NOTIF 1 ENDIF", @"They are here to catch copy-and-paste errors"],
  @[@"NOP", @"VERIFY 1", @"Most of them are duplicated elsewhere,"],
  
  @[@"NOP", @"TOALTSTACK 1", @"but, hey, more is always better, right?"],
  @[@"1", @"FROMALTSTACK"],
  @[@"1", @"2DROP 1"],
  @[@"1", @"2DUP"],
  @[@"1 1", @"3DUP"],
  @[@"1 1 1", @"2OVER"],
  @[@"1 1 1 1 1", @"2ROT"],
  @[@"1 1 1", @"2SWAP"],
  @[@"NOP", @"IFDUP 1"],
  @[@"NOP", @"DROP 1"],
  @[@"NOP", @"DUP 1"],
  @[@"1", @"NIP"],
  @[@"1", @"OVER"],
  @[@"1 1 1 3", @"PICK"],
  @[@"0", @"PICK 1"],
  @[@"1 1 1 3", @"ROLL"],
  @[@"0", @"ROLL 1"],
  @[@"1 1", @"ROT"],
  @[@"1", @"SWAP"],
  @[@"1", @"TUCK"],
  
  @[@"NOP", @"SIZE 1"],
  
  @[@"1", @"EQUAL 1"],
  @[@"1", @"EQUALVERIFY 1"],
  
  @[@"NOP", @"1ADD 1"],
  @[@"NOP", @"1SUB 1"],
  @[@"NOP", @"NEGATE 1"],
  @[@"NOP", @"ABS 1"],
  @[@"NOP", @"NOT 1"],
  @[@"NOP", @"0NOTEQUAL 1"],
  
  @[@"1", @"ADD"],
  @[@"1", @"SUB"],
  @[@"1", @"BOOLAND"],
  @[@"1", @"BOOLOR"],
  @[@"1", @"NUMEQUAL"],
  @[@"1", @"NUMEQUALVERIFY 1"],
  @[@"1", @"NUMNOTEQUAL"],
  @[@"1", @"LESSTHAN"],
  @[@"1", @"GREATERTHAN"],
  @[@"1", @"LESSTHANOREQUAL"],
  @[@"1", @"GREATERTHANOREQUAL"],
  @[@"1", @"MIN"],
  @[@"1", @"MAX"],
  @[@"1 1", @"WITHIN"],
  
  @[@"NOP", @"RIPEMD160 1"],
  @[@"NOP", @"SHA1 1"],
  @[@"NOP", @"SHA256 1"],
  @[@"NOP", @"HASH160 1"],
  @[@"NOP", @"HASH256 1"],
  
  @[@"NOP 0x01 1", @"HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL", @"Tests for Script.IsPushOnly()"],
  @[@"NOP1 0x01 1", @"HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL"],
  
  @[@"0 0x01 0x50", @"HASH160 0x14 0xece424a6bb6ddf4db592c0faed60685047a361b1 EQUAL", @"OP_RESERVED in P2SH should fail"],
  @[@"0 0x01 VER", @"HASH160 0x14 0x0f4d7845db968f2a81b530b6f3c1d6246d4c7e01 EQUAL", @"OP_VER in P2SH should fail"]
  ];
}

@end
