//
//  BTCAddressTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 4/20/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCAddressTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPublicKeyAddress() {
        let addr = BTCPublicKeyAddress(string: "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T")!
        XCTAssert(addr.dynamicType === BTCPublicKeyAddress.self, "Address should be an instance of BTCPublicKeyAddress")
        
        // Crashes Xcode 7.1.1 when using addr.data.hex()
        XCTAssertEqual("c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827", BTCHexFromData(addr.data), "Must decode hash160 correctly.")
        XCTAssertEqual(addr, addr.publicAddress, "Address should be equal to its publicAddress")
        
        let addr2 = BTCPublicKeyAddress(data: BTCDataFromHex("c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"))!
        
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", addr2.string, "Must encode hash160 correctly.")
    }

    func testPrivateKeyAddress() {
        let addr = BTCPrivateKeyAddress(string: "5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS")!
        XCTAssert(addr.dynamicType === BTCPrivateKeyAddress.self, "Address should be an instance of BTCPrivateKeyAddress")
        XCTAssert(!addr.publicKeyCompressed, "Address should be not compressed")
        
        // Crashes Xcode 7.1.1 when using addr.data.hex()
        XCTAssertEqual("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a", BTCHexFromData(addr.data), "must provide proper public address")
        
        let addr2 = BTCPrivateKeyAddress(data: BTCDataFromHex("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"))!
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS", addr2.string, "Must encode secret key correctly.")
    }
    
    func testPrivateKeyAddressWithCompressedPoint() {
        let addr = BTCPrivateKeyAddress(string: "L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu")!
        XCTAssert(addr.dynamicType === BTCPrivateKeyAddress.self, "Address should be an instance of BTCPrivateKeyAddress")
        XCTAssert(addr.publicKeyCompressed, "address should be compressed")
        
        // Crashes Xcode 7.1.1 when using addr.data.hex()
        XCTAssertEqual("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a", BTCHexFromData(addr.data), "Must decode secret key correctly.")
        XCTAssertEqual(addr.publicAddress.string, "1C7zdTfnkzmr13HfA2vNm5SJYRK6nEKyq8", "must provide proper public address")
        
        let addr2 = BTCPrivateKeyAddress(data: BTCDataFromHex("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"))!
        addr2.publicKeyCompressed = true
        XCTAssertEqual("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu", addr2.string, "Must encode secret key correctly.")
        addr2.publicKeyCompressed = false
        XCTAssertEqual("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS", addr2.string, "Must encode secret key correctly.")
    }


    func testScriptHashKeyAddress() {

        let addr = BTCScriptHashAddress(string: "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8")!
        XCTAssert(addr.dynamicType === BTCScriptHashAddress.self, "Address should be an instance of BTCScriptHashAddress")

        // Crashes Xcode 7.1.1 when using addr.data.hex()
        XCTAssertEqual("e8c300c87986efa84c37c0519929019ef86eb5b4", BTCHexFromData(addr.data), "Must decode hash160 correctly.")
        XCTAssertEqual(addr, addr.publicAddress, "Address should be equal to its publicAddress")
        let addr2 = BTCScriptHashAddress(data: BTCDataFromHex("e8c300c87986efa84c37c0519929019ef86eb5b4"))!
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8", addr2.string, "Must encode hash160 correctly.")
    }

    func testAssetAddress() {
        let btcAddr = BTCPublicKeyAddress(string: "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")!
        let assetAddr = BTCAssetAddress(bitcoinAddress:btcAddr)
        XCTAssertEqual("akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy", assetAddr.string, "Must encode to Open Assets format correctly.")

        let assetAddr2 = BTCAssetAddress(string:"akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy")!
        XCTAssertEqual("16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM", assetAddr2.bitcoinAddress.string, "Must decode underlying Bitcoin address from Open Assets address.")
    }

    func testParseErrors() {
        XCTAssertNil(BTCAddress(string: "X6UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM"), "Must fail to parse incorrect address")
        XCTAssertNil(BTCPublicKeyAddress(string: "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8"), "Must fail to parse valid address of non-matching type")
        XCTAssertNil(BTCPrivateKeyAddress(string: "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8"), "Must fail to parse valid address of non-matching type")
        XCTAssertNil(BTCScriptHashAddress(string: "L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu"), "Must fail to parse valid address of non-matching type")
        XCTAssertNil(BTCAssetAddress(string: "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8"), "Must fail to parse valid address of non-matching type")
    }

}
