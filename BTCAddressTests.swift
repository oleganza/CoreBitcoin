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
        let addr = BTCPublicKeyAddress(string: "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T")
        XCTAssertNotNil(addr, "Address should be decoded")
        XCTAssert(addr!.dynamicType === BTCPublicKeyAddress.self, "Address should be an instance of BTCPublicKeyAddress")
        XCTAssertEqual("c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827", addr!.data.hex(), "Must decode hash160 correctly.")
        XCTAssertEqual(addr!, addr!.publicAddress, "Address should be equal to its publicAddress")
        
        let addr2 = BTCPublicKeyAddress(data: BTCDataFromHex("c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"))
        
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", addr2.string, "Must encode hash160 correctly.")
        
    }
    
    func testPrivateKeyAddress() {
        let addr = BTCPrivateKeyAddress(string: "5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS")
        XCTAssertNotNil(addr, "Address should be decoded")
        XCTAssert(addr!.dynamicType === BTCPrivateKeyAddress.self, "Address should be an instance of BTCPrivateKeyAddress")
        XCTAssert(!addr.publicKeyCompressed, "Address should be not compressed")
        XCTAssertEqual("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a", addr.data.hex(), "must provide proper public address")
        
        let addr2 = BTCPrivateKeyAddress(data: BTCDataFromHex("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"))
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS", addr2.string, "Must encode secret key correctly.")
    }
    
    func testPrivateKeyAddressWithCompressedPoint() {
        let addr = BTCPrivateKeyAddress(string: "L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu")
        XCTAssertNotNil(addr, "Address should be decoded")
        XCTAssert(addr!.dynamicType === BTCPrivateKeyAddress.self, "Address should be an instance of BTCPrivateKeyAddress")
        XCTAssert(addr.publicKeyCompressed, "address should be compressed")
        XCTAssertEqual("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a", addr.data.hex(), "Must decode secret key correctly.")
        XCTAssertEqual(addr.publicAddress.string, "1C7zdTfnkzmr13HfA2vNm5SJYRK6nEKyq8", "must provide proper public address")
        
        let addr2 = BTCPrivateKeyAddress(data: BTCDataFromHex("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"))
        XCTAssertNotNil(addr2, "Address should be created")
        addr2.publicKeyCompressed = true
        XCTAssertEqual("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu", addr2.string, "Must encode secret key correctly.")
        addr2.publicKeyCompressed = false
        XCTAssertEqual("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS", addr2.string, "Must encode secret key correctly.")
    }
    
    func testScriptHashKeyAddress() {
        let addr = BTCScriptHashAddress(string: "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8")
        XCTAssertNotNil(addr, "Address should be decoded")
        XCTAssert(addr!.dynamicType === BTCScriptHashAddress.self, "Address should be an instance of BTCScriptHashAddress")
        XCTAssertEqual("e8c300c87986efa84c37c0519929019ef86eb5b4", addr.data.hex(), "Must decode hash160 correctly.")
        XCTAssertEqual(addr, addr.publicAddress, "Address should be equal to its publicAddress")
        
        let addr2 = BTCScriptHashAddress(data: BTCDataFromHex("e8c300c87986efa84c37c0519929019ef86eb5b4"))
        XCTAssertNotNil(addr2, "Address should be created")
        XCTAssertEqual("3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8", addr2.string, "Must encode hash160 correctly.")
    }

}
