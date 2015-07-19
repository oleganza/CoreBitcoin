//
//  BTCDataTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 7/2/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCDataTests: XCTestCase {

    func testBTCData() {
        
        XCTAssertEqual(NSData().SHA256().hex(), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "Test vector")
        XCTAssertEqual(NSData().SHA256().uppercaseHex(), "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", "Test vector")
        XCTAssertEqual(BTCDataWithUTF8CString("The quick brown fox jumps over the lazy dog").SHA256().hex(), "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592", "Test vector")
        
        XCTAssertEqual(BTCDataWithUTF8CString("hello").SHA256().hex(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", "Test vector")
        XCTAssertEqual(BTCSHA256Concat(BTCDataWithUTF8CString("hel"), BTCDataWithUTF8CString("lo")).hex(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", "Test vector")
        
        XCTAssertEqual(BTCDataWithUTF8CString("hello").SHA256().SHA256().hex(), "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50", "Test vector")
        XCTAssertEqual(BTCDataWithUTF8CString("hello").BTCHash256().hex(), "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50", "Test vector")
        
        XCTAssertEqual(BTCDataWithUTF8CString("hello").SHA256().RIPEMD160().hex(), "b6a9c8c230722b7c748331a8b450f05566dc7d0f", "Test vector")
        
        XCTAssertEqual(BTCDataWithUTF8CString("hello").BTCHash160().hex(), "b6a9c8c230722b7c748331a8b450f05566dc7d0f", "Test vector")
        
        
        let bytes1: [CUnsignedChar] = [0xde, 0xad, 0xBE, 0xEF]
        XCTAssertEqual(BTCDataFromHex("deadBEEF"), NSData(bytes: bytes1, length: bytes1.count), "Init data with hex string")
        
        XCTAssertEqual(BTCDataFromHex("0xdeadBEEF"), NSData(bytes: bytes1, length: bytes1.count), "Init data with hex string")
        
        let bytes2: [CUnsignedChar] = [0xde, 0xad, 0xBE, 0xFE]
        XCTAssertNotEqual(BTCDataFromHex("0xdeadBEEF"), NSData(bytes: bytes2, length: bytes2.count), "Init data with hex string")
        
        
        // Base58 decoding
        
        XCTAssertEqual(NSString(string: "6h8cQN").dataFromBase58().hex(), "deadbeef", "Decodes base58")
        XCTAssertEqual(NSString(string: "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T").dataFromBase58Check().hex(), "00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827", "Decodes base58 with checksum")
        
        
        // Base58 encoding
        
        XCTAssertEqual(BTCDataFromHex("deadBeeF").base58String(), "6h8cQN", "Encodes base58")
        XCTAssertEqual(BTCDataFromHex("00c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827").base58CheckString(), "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", "Encodes base58 with checksum")
        
        
        
        
        // Excluding the Memory-hard KDF tests that are in BTCData+Tests.m because they're all commented-out there
       
    }

}
