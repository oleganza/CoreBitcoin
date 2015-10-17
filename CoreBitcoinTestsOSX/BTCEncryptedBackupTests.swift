//
//  BTCEncryptedBackupTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 5/26/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCEncryptedBackupTests: XCTestCase {

    func testShortBackup() {
        let timestamp: NSTimeInterval = 1427720967
        
        let plaintext = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let masterKey = BTCSHA256("Master Key".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        XCTAssertEqual(masterKey, BTCDataFromHex("08c17482950a872178b8030c8f8a63bc6e5f9f680dd25739e1ec7e0b544f40f9"), "master key")
        let backupKey = BTCEncryptedBackup.backupKeyForNetwork(BTCNetwork.mainnet(), masterKey: masterKey)
        let backupKeyTestnet = BTCEncryptedBackup.backupKeyForNetwork(BTCNetwork.testnet(), masterKey: masterKey)
        
        XCTAssertEqual(backupKey, BTCDataFromHex("7618f25cd5faadd52d0ea3b608b0c076664f5816b81311017985ae229157057a"), "must produce a determinstic backup key")
        XCTAssertEqual(backupKeyTestnet, BTCDataFromHex("caa57de4c3d9c77186175fbfdc326997162da0ce1b74022a51c600838449b2c3"), "must produce a determinstic backup key")
        
        let backup = BTCEncryptedBackup.encrypt(plaintext, backupKey: backupKey, timestamp: timestamp)
        
        XCTAssertNotNil(backup, "Should encrypt alright")
        
        XCTAssertGreaterThanOrEqual(backup.encryptedData.length, 1 + 4 + 16 + 1 + plaintext!.length + 1 + 68, "Should be of realistic length")
        
        XCTAssertEqual(backup.encryptionKey, BTCDataFromHex("58369379e5100b58cd49c97171f29f3d"), "Should use deterministic encryption key")
        XCTAssertEqual(backup.iv, BTCDataFromHex("bf07aaa979ae8af6eebfea5da8e83cad"), "Should compute IV deterministically")
        XCTAssertEqual(backup.authenticationKey.privateKey, BTCDataFromHex("44b45878c33c974179f5363fee95f9e9d4a60c97e9c865e58b57bef3558034f4"), "Should use deterministic authentication private key")
        XCTAssertEqual(backup.authenticationKey.publicKey, BTCDataFromHex("028747be6de07552c48f9db23617792d47df1accd611175f6dfe636f4098984a09"), "Should use deterministic compressed authentication public key")
        XCTAssertEqual(backup.walletID, "WmEp7EPk8vKMgXQQGWgh1AYhmY8Usw6kwL", "Should compute WalletID deterministically")
        XCTAssertEqual(backup.ciphertext, BTCDataFromHex("5edbaade9ba4ed528a8de36c95ece996189dedf4756fba2599f94b4f370d701366e2f0ba4e59111c0787708cf4b0b82de558b4d8bf5d90b3512f09814d605d4c14f2f85b596211f83918c31c4bef19ea"), "Should compute ciphertext deterministically")
        XCTAssertEqual(backup.merkleRoot, BTCDataFromHex("9e913cd60f7df551b3baa320602bfba78489921d661362a64a03550a45add008"), "Should compute merkle root of the ciphertext correctly")
        XCTAssertEqual(backup.signature, BTCDataFromHex("3045022100ddbc9b06625c2b3c9cbfb27b6ac39596bd13daf43d4ddecbb7257a0d26f5e2c402200a5bd5fd27df7ac262ac3cff9d5398742c6fd9c76c427548667bee45dcb1134c"), "Should compute signature deterministically (RFC6979)")
        XCTAssertEqual(backup.encryptedData, BTCDataFromHex("01074b1955bf07aaa979ae8af6eebfea5da8e83cad505edbaade9ba4ed528a8de36c95ece996189dedf4756fba2599f94b4f370d701366e2f0ba4e59111c0787708cf4b0b82de558b4d8bf5d90b3512f09814d605d4c14f2f85b596211f83918c31c4bef19ea473045022100ddbc9b06625c2b3c9cbfb27b6ac39596bd13daf43d4ddecbb7257a0d26f5e2c402200a5bd5fd27df7ac262ac3cff9d5398742c6fd9c76c427548667bee45dcb1134c"), "Should compute the whole encrypted backup deterministically")
        
        let backup2 = BTCEncryptedBackup.decrypt(backup.encryptedData, backupKey: backupKey)
        
        XCTAssertNotNil(backup2, "Must decrypt")
        XCTAssertEqual(backup2.version, backup.version, "Version must be decoded correctly")
        XCTAssertEqual(backup2.timestamp, backup.timestamp, "Timestamp must be decoded correctly")
        XCTAssertEqual(backup2.decryptedData, plaintext!, "Plaintext must be decrypted correctly")
    }
    
    func testLongBackup() {
        let backupJSON: NSDictionary = [
            "version": "1",
            "network": "main",
            "accounts": [
                ["type": "bip44",  "label": "label for bip44 account 0",  "path": "44'/0'/0'"],
                ["type": "bip44",  "label": "label for bip44 account 1",  "path": "44'/0'/1'"],
                ["type": "bip44",  "label": "label for bip44 account 17", "path": "44'/0'/17'"],
                ["type": "single", "label": "Vanity Address", "wif": "5RLmtKqh..."],
                ["type": "single", "label": "Watch-Only",     "address": "1Ht3CBv..."],
                ["type": "trezor", "label": "My Trezor",      "xpub": "xpub6FHa3pjLCk8..."],
            ],
            "transactions": [
                "f10c7786f120536...":  [
                    "memo": "Hotel in Lisbon",
                    "recipient": "Expedia, Inc.",
                    "payment_request": "12008c17d661778f1249...",
                    "payment_ack": "0b2678e8a476a30e2609...",
                    "fiat_amount": "-265.10",
                    "fiat_code": "EUR",
                ],
            ],
            "currency": [
                "fiat_code": "USD",
                "fiat_source": "Coinbase",
                "btc_unit": "BTC",
            ]
        ]
        
        
        let plaintext: NSData?
        do {
            plaintext = try NSJSONSerialization.dataWithJSONObject(backupJSON, options: NSJSONWritingOptions(rawValue: 0))
        } catch {
            XCTFail("Error: \(error)")
            plaintext = nil
        }
        
        let toPrint = NSString(data: plaintext!, encoding: NSUTF8StringEncoding)
        print("plaintext = \(toPrint)")
        XCTAssertNotNil(plaintext, "Must encode to JSON")
        
        let masterKey = BTCSHA256("Master Key".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        let backupKey = BTCEncryptedBackup.backupKeyForNetwork(BTCNetwork.mainnet(), masterKey: masterKey)
        
        XCTAssertEqual(backupKey, BTCDataFromHex("7618f25cd5faadd52d0ea3b608b0c076664f5816b81311017985ae229157057a"), "must produce a determinstic backup key")
        
        let backup = BTCEncryptedBackup.encrypt(plaintext, backupKey: backupKey, timestamp: 1427720967.0)
        
        XCTAssertNotNil(backup, "Should encrypt alright")
        
        XCTAssertGreaterThanOrEqual(backup.encryptedData.length, 1 + 4 + 16 + 1 + plaintext!.length + 1 + 68, "Should be of realistic length")
        
        let backup2 = BTCEncryptedBackup.decrypt(backup.encryptedData, backupKey: backupKey)
        
        XCTAssertNotNil(backup2, "Must decrypt")
        XCTAssertEqual(backup2.version, backup.version, "Version must be decoded correctly")
        XCTAssertEqual(backup2.timestamp, backup.timestamp, "Timestamp must be decoded correctly")
        XCTAssertEqual(backup2.decryptedData, plaintext!, "Plaintext must be decrypted correctly")
        
    }
    
}
