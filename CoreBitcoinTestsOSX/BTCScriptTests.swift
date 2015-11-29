//
//  BTCScriptTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 7/29/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCScriptTests: XCTestCase {
    
    func testP2SHMultisig() {
        
//        let tx = BTCTransaction(data: BTCDataFromHex("0100000002e7131826715b36b47b149177b0f2f3169af74b9188d3d02433d7f3b5e6c796a701000000fc00473044022075968c0bd5dd89872cb4793f60e30bcaa44b73f2c4ff31f0ad184f216d2b081202205b6e0d4dbe07d826baeef346d8ff9d02d40c5aa9b0f74b0fafb370aee068a9ae0147304402204b287822f29e683fc0cb16935d11b9401fee5a97893a798b4ca7d43e53eaf8c602207e42f8749083d871ea7d1e0a90e02d44f25f6276787d3c04ed72da681fb3e70f014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff12780cf6595ce7d34ca2e2c104dad5a2ea8709348a280cefc2246bdbd0bf142a01000000fb00473044022056c9d4177774917f9a91be9b5f7c458d9d142bd5ac22d219942dd6eec7b98c140220732715ed6ffee27d446792a11578b63b5db13e52898dae26e6dc965b9dc87fb20146304302206882ff20af49797da8a5758024e32517216ec66c119199a3dc9a9f89c24cc56d021f6bf1d49a83fc73f93a2139e519ed31e3ae8b04fbe7bb7245f35da9dd22c6f7014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff03e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87c60700000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d8700000000"))
        
        let tx = BTCTransaction(data: BTCDataFromHex("0100000002e7131826715b36b47b149177b0f2f3169af74b9188d3d02433d7f3b5e6c796a701000000fdfd0000473044022032e7b327ccf5e7f19029134c50d881daa178a1233d09ac9e6e93081e8f33efaf02202e2bf8b57d1c34554f65fac9c6df4986d31b3f6a7bee6cbab9a3ed835e3f57c301483045022100a355f5cde0b7643a1cbb813df4b29ddca13ddd7ee3685e77b1972179832bbd9a0220391bb9661fdab9f38bcce2abaebde39f3b5874b65758b61e1961c64f8b74d288014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff12780cf6595ce7d34ca2e2c104dad5a2ea8709348a280cefc2246bdbd0bf142a01000000fdfd0000483045022100a6967dcd995712007a647d5466131ebc2f5cd3f46c7b314ccf428ea4e46684c502202716cf49125a67627dc2837b747898b38e8c4f58abb13cd3c1c362f0f4094ff301473044022056fc5265f4508e1baf4d837894d5e6e3df8925c68c1f2f8ca83476b73fabd64202200ad5c9928db2d7096a3d19ac2d6fc9eab3db69cd00b9dbcb923bb2e709c5b64f014c6952210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153aeffffffff03e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87e80300000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d87c60700000000000017a914df91b0c30b7d6ec20c50e066c07add242dcfcc1d8700000000"))
        
//        let redeemScript = BTCScript(data: BTCDataFromHex("52210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c7121026a361b855808aeba02d3143b3ec884f709b24d5391c515bd4eafd69d1afae337210355e9d91d63acb15a75c1a9205fc4c0a0878778e08e0a9ca22adb0c2c33fa880153ae"))
        
        let outputScript = BTCScript(address: BTCAddress(string: "2NDdMCpA9to3ayTkXJQ3DvfKuSxjyRtFG5S"))
        
//        println("p2sh = \(outputScript.string)")
//        println("p2sh inner = \(redeemScript.string)")
//        println("tx = \(tx.dictionary)")
        
        for i in 0 ..< uint32(tx.inputs.count) {
            let sm = BTCScriptMachine(transaction: tx, inputIndex: i)
            
            do {
                try sm.verifyWithOutputScript(outputScript)
            } catch {
                print("BTCScriptMachine error: \(error)")
                XCTFail("should verify first input")
            }
            
        }
        
    }

    func testMultisignatureScripts() {
        // 1. Create some keys
        
        let alice   = BTCKey(privateKey: BTCHash256(BTCDataWithUTF8CString("alice")))
        let bob     = BTCKey(privateKey: BTCHash256(BTCDataWithUTF8CString("bob")))
        let carl    = BTCKey(privateKey: BTCHash256(BTCDataWithUTF8CString("carl")))
        let david   = BTCKey(privateKey: BTCHash256(BTCDataWithUTF8CString("david")))
        
        // 2. Compose a source transaction (does not need to be fully valid o have any inputs)
        
        let pubkeys = [alice, bob, carl].map { $0.compressedPublicKey }
        let srcTx = BTCTransaction()
        
        // Lets have a 2-of-3 multisig output.
        let srcTxOut = BTCTransactionOutput(value: 100, script: BTCScript(publicKeys: pubkeys, signaturesRequired: 2))
        srcTx.addOutput(srcTxOut)
        
//        println("Script: \(srcTxOut.script.string)")
        
        let dstTx = BTCTransaction()
        
        // Add dummy output (we don't care where the coins will go)
        dstTx.addOutput(BTCTransactionOutput(value: 100))
        
        let dstTxIn = BTCTransactionInput()
        dstTxIn.previousHash = srcTx.transactionHash
        dstTxIn.previousIndex = 0
        dstTx.addInput(dstTxIn)
        
        // 3. Sign the redeeming transaction.
        
        let hashtype = BTCSignatureHashType.SIGHASH_ALL
        let hash = try? dstTx.signatureHashForScript(srcTxOut.script, inputIndex: 0, hashType: hashtype)
        
        XCTAssertNotNil(hash, "sanity check")
        
        // 4. Simple signing case useful as a sample code.
        
        do {
            let signatureScript = BTCScript()
            
            signatureScript.appendOpcode(.OP_0) // always prepend dummy OP_0 because OP_CHECKMULTISIG pops one too many items from the stack.
            signatureScript.appendData(alice.signatureForHash(hash, hashType: hashtype))
            signatureScript.appendData(bob.signatureForHash(hash, hashType: hashtype))
            
            dstTxIn.signatureScript = signatureScript
            
            // Verify the transaction.
            
            let sm = BTCScriptMachine(transaction: dstTx, inputIndex: 0)
            do {
                try sm.verifyWithOutputScript(srcTxOut.script.copy() as! BTCScript)
            } catch {
                XCTFail("should verify first input")
            }
            
        }
        
        // 5. Check valid combinations
        
        let validKeyCombinations = [
            // Exactly 2 signatures in correct order.
            [alice, bob],
            [bob,   carl],
            [alice, carl],
            
            // Too many signatures, but the last ones are correct
            [alice, alice, bob],
            [david, alice, carl],
            [alice, bob,   carl],
        ]
        
        for keyGroup in validKeyCombinations {
            let signatureScript = BTCScript()
            
            signatureScript.appendOpcode(.OP_0)
            for key in keyGroup {
                signatureScript.appendData(key.signatureForHash(hash, hashType: hashtype))
            }
            
            dstTxIn.signatureScript = signatureScript
            
            // Verify the transaction.
            
            let sm = BTCScriptMachine(transaction: dstTx, inputIndex: 0)
            
            do {
                try sm.verifyWithOutputScript(srcTxOut.script.copy() as! BTCScript)
            } catch {
                print("BTCScriptMachine error: \(error)")
                XCTFail("should verify first input")
            }
            
            
        }
        
        // Check invalid combinations
        let invalidKeyCombinations = [
            // Not enough signatures
            [],
            [alice],
            [bob],
            [carl],
            
            // Too many signatures and the last two are incorrect
            [alice, bob, david],
            [bob, carl, alice],
            [bob, bob, bob],
            
            // Incorrect signatures
            [alice, alice],
            [bob, bob],
            [carl, carl],
            [david, david],
            [alice, david],
            
            // Incorrect order
            [bob, alice],
            [carl, bob],
            [carl, alice],
        ]
        
        for keyGroup in invalidKeyCombinations {
            let signatureScript = BTCScript()
            
            signatureScript.appendOpcode(.OP_0)
            for key in keyGroup {
                signatureScript.appendData(key.signatureForHash(hash, hashType: hashtype))
            }
            
            dstTxIn.signatureScript = signatureScript
            
            //Verify the transaction.
            
            let sm = BTCScriptMachine(transaction: dstTx, inputIndex: 0)
            
            do {
                try sm.verifyWithOutputScript(srcTxOut.script.copy() as! BTCScript)
                XCTFail("should not verify first output")
            } catch {
                print("BTCScriptMachine error: \(error)")
            }
            
            
        }
        
    }


    func testBinarySerialization() {
        //Empty script
        do {
            XCTAssertEqual(BTCScript().data, NSData(), "Default script should be empty")
            XCTAssertEqual(BTCScript(data: NSData()).data, NSData(), "Empty script should be empty")
        }
    }

    func testStringSerialization() {
//        println("tx = " + (BTCHexFromData(BTCReversedData(BTCDataFromHex("..."))) ?? ""))
        
        let yrashkScript = BTCDataFromHex("52210391e4786b4c7637c160247ad6d5702d9bb2860cbb8130d59b0fd9808a0220d50f2102e191fcff2849099988fbe1592b6788707a61401058c09ef97363c9d96c43a0cf21027f10a51295e8e96d5957f3665168426249a006e548e48cbfa5882d2bf89ab67e2103d39801bafef0cc3c211101a54a47874c0a835efa2c17c47ebbe380c803345a2354ae")
        
        let script = BTCScript(data: yrashkScript)
        
        XCTAssertNotNil(script, "sanity check")
//        println("Script: \(script)")
    }

    func testStandardScripts() {
        let script = BTCScript(data: BTCDataFromHex("76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac"))
        
//        println("TEST: String: \(script.string)\nIs P2PKH Script: \(script.isPayToPublicKeyHashScript)")
        
        XCTAssertTrue(script.isPayToPublicKeyHashScript, "should be regular hash160 script")

        let simsigData = script.simulatedSignatureScriptWithOptions(.Default).data
        XCTAssertEqual(simsigData.length, 1 + (72 + 1) + 1 + 65, "Simulated sigscript for p2pkh should contain signature, hashtype and an uncompressed pubkey")
        
        let simsigData2 = script.simulatedSignatureScriptWithOptions(.CompressedPublicKeys).data
        XCTAssertEqual(simsigData2.length, 1 + (72 + 1) + 1 + 33, "Simulated sigscript for p2pkh with compressed pubkey option should contain signature, hashtype and a compressed pubkey")

        let base58address = script.standardAddress.string
        //print("TEST: address: \(base58address)")
        
        XCTAssertEqual(base58address, "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG", "address should be correctly decoded")

        let script2 = BTCScript(address: BTCAddress(string: "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG"))
        XCTAssertEqual(script2.data, script.data, "script created from extracted address should be the same as the original script")
        XCTAssertEqual(script2.string, script.string, "script created from extracted address should be the same as the original script")

    }

    func testKeyConversion() {

// This test crashes Swift 2 in Xcode 7.1.1

//        let key = BTCKey()!
//        let addressB58 = key.compressedPublicKeyAddress!.string
//        let privKeyB58 = key.privateKeyAddress!.string
//
//        //        print("Address1: \(addressB58)")
//        //        print("PrivKey1: \(privKeyB58)")
//
//        //get address from private key
//
//        //            if true { // this assert fails because it creates data = <00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000> because it's cleared when address is dealloc'd.
//        //                let privkey01 = BTCAddress(string: privKeyB58)!.data
//        //                XCTAssertEqual(privkey01, key.privateKey, "private key should be the same")
//        //            }
//
//        // However, if we assign intermediate object to a variable, everything works fine. Need to investigate.
//        let pkaddr = BTCPrivateKeyAddress(string: privKeyB58)
//        let privkey = pkaddr!.data
//
//        XCTAssertEqual(key.privateKey, privkey, "Private key should be the same")
//
//        let key2 = BTCKey(privateKey: privkey)
//        let pubkeyAddress = BTCPublicKeyAddress(data: BTCHash160(key2.publicKey))
//        let privkeyAddress = BTCPrivateKeyAddress(data: key2.privateKey)
//
////        print("Address2: \(pubkeyAddress!.string)")
////        print("PrivKey2: \(privkeyAddress!.string)")
//
//        let address2 = key2.compressedPublicKeyAddress.string
//        XCTAssertEqual(addressB58, address2, "addresses must be equal")

    }

//
//    func testScriptModifications() {
//        //
//    }
//    
//    func testStrangeScripts() {
//        let script = BTCScript(string: "2147483648 0 OP_ADD")
//        
//        XCTAssertNotNil(script, "should be a valid script")
//        
//        let scriptMachine = BTCScriptMachine()
//        scriptMachine.verificationFlags = .StrictEncoding
//        scriptMachine.inputScript = script
//        
//        do {
//            try scriptMachine.verifyWithOutputScript(BTCScript(string: "OP_NOP"))
//            print("script passed: \(script)")
//        } catch {
//            print("error: \(error)")
//        }
//        
//        
//    }
//    
//    func testValidBitcoinQTScripts() {
//        for fakeTuple in validBitcoinQTScripts() {
//            let inputScriptString = fakeTuple[0] as! String
//            let outputScriptString = fakeTuple[1]as! String
//            let comment = (fakeTuple.count > 2) ? fakeTuple[2] as! String : "Script should not fail"
//            
//            var inputScript = BTCScript(string: inputScriptString)
//            if inputScript == nil {
//                // for breakpoint
//                inputScript = BTCScript(string: inputScriptString)
//            }
//            
//            var outputScript = BTCScript(string: outputScriptString)
//            if outputScript == nil {
//                // for breakpoint
//                outputScript = BTCScript(string: outputScriptString)
//            }
//            
//            XCTAssertNotNil(inputScript, "Input script must be well-formed")
//            XCTAssertNotNil(outputScript, "Output script must be well-formed")
//            
//            let scriptMachine = BTCScriptMachine()
//            scriptMachine.verificationFlags = .StrictEncoding
//            scriptMachine.inputScript = inputScript
//            
//            do {
//                try scriptMachine.verifyWithOutputScript(outputScript)
//            } catch {
//                XCTFail("BTCScript validation error: \(error) (\(comment))")
//            }
//            
//            
//        }
//    }
//    
//    func testInvalidBitcoinQTScripts() {
//        for fakeTuple in invalidBitcoinQTScripts() {
//            let inputScriptString = fakeTuple[0] as! String
//            let outputScriptString = fakeTuple[1] as! String
//            let comment = (fakeTuple.count > 2) ? fakeTuple[2] as! String : "Script should not fail"
//            
//            let inputScript = BTCScript(string: inputScriptString)
//            
//            // Script is malformed, it's okay.
//            
//            if inputScript == nil { continue }
//            
//            let outputScript = BTCScript(string: outputScriptString)
//            
//            //Script is malformed, it's okay.
//            if (outputScript == nil) { continue }
//            
//            let scriptMachine = BTCScriptMachine()
//            scriptMachine.verificationFlags = .StrictEncoding
//            scriptMachine.inputScript = inputScript
//            
//            
//            do {
//                try scriptMachine.verifyWithOutputScript(outputScript)
//                
//            } catch {
//                XCTFail(comment)
//            }
//            
//        }
//    }
//    

}
