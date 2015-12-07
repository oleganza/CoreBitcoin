//
//  BTCProtocolSerializationTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 12/6/15.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

import XCTest
import Foundation

class BTCProtocolSerializationTests: XCTestCase {
    
    
    func assertNumber(number: UInt64, serializesToHex hexForm: String) { //Using NSString because an Xcode bug is preventing String.count from being used
        let requiredLength = (hexForm as NSString).length / 2
        let data = BTCProtocolSerialization.dataForVarInt(number)
        print("data = \(data)")
        XCTAssertEqual(data, BTCDataFromHex(hexForm), "Should encode correctly")
        var value: UInt64 = 0
        var len = BTCProtocolSerialization.readVarInt(&value, fromData: data)
        XCTAssertEqual(Int(len), requiredLength, "Should read correct number of bytes")
        XCTAssertEqual(value, number, "Should read original value")
        
        let stream = NSInputStream(data: data)
        stream.open()
        len = BTCProtocolSerialization.readVarInt(&value, fromStream: stream)
        stream.close()
        XCTAssertEqual(Int(len), requiredLength, "Should read 1 byte")
        XCTAssertEqual(value, number, "Should read original value")
    }
    
    func testAll() {
        self.assertNumber(0, serializesToHex: "00")
        self.assertNumber(252, serializesToHex: "fc")
        self.assertNumber(CUnsignedLongLong(255), serializesToHex: "fdff00")
        self.assertNumber(CUnsignedLongLong(12345), serializesToHex: "fd3930")
        self.assertNumber(CUnsignedLongLong(65535), serializesToHex: "fdffff")
        self.assertNumber(CUnsignedLongLong(65536), serializesToHex: "fe00000100")
        self.assertNumber(CUnsignedLongLong(1234567890), serializesToHex: "fed2029649")
        self.assertNumber(CUnsignedLongLong(1234567890123), serializesToHex: "ffcb04fb711f010000")
        self.assertNumber(UINT64_MAX, serializesToHex: "ffffffffffffffffff")
    }
}
