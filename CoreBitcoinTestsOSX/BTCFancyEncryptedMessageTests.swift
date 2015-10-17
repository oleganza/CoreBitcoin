//
//  BTCFancyEncryptedMessageTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 7/1/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCFancyEncryptedMessageTests: XCTestCase {
    
    func testMessages() {
        let key = BTCKey(privateKey: BTCSHA256("some key".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)))
        
        let originalString = "Hello!"
        
        let msg = BTCFancyEncryptedMessage(data: originalString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        msg.difficultyTarget = 0x00FFFFFF
        
        print(NSString(format: "difficulty: %@ (%x)", self.binaryString32(msg.difficultyTarget), msg.difficultyTarget))
        
        let encryptedMsg = msg.encryptedDataWithKey(key, seed: BTCDataFromHex("deadbeef"))
        
        XCTAssertEqual(msg.difficultyTarget, 0x00FFFFFF, "check the difficulty target")
        
        print(NSString(format: "encrypted msg = %@   hash: %@...", BTCHexFromData(encryptedMsg), BTCHexFromData(BTCHash256(encryptedMsg).subdataWithRange(NSMakeRange(0, 8)))))
        
        let receivedMsg = BTCFancyEncryptedMessage(encryptedData: encryptedMsg)
        
        XCTAssertNotNil(receivedMsg, "pow and format are correct")
        
        do {
            let decryptedData = try receivedMsg.decryptedDataWithKey(key)
            XCTAssertNotNil(decryptedData, "should decrypt correctly")
            
            let str = NSString(data: decryptedData, encoding: NSUTF8StringEncoding)
            XCTAssertNotNil(str, "should decode a UTF-8 string")
            XCTAssertEqual(str!, originalString, "should decrypt the original string")
            
        } catch {
            XCTFail("Error: \(error)")
            
        }
        
        
    }
    
    func testProofOfWork() {
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(0), 0, "0x00 -> 0")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(0xFF), 0xFFFFFFFF, "0x00 -> 0")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(1), 0, "order is zero")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(2), 0, "order is zero")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(3), 0, "order is zero")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(4), 1, "order is zero, and tail starts with 1")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(5), 1, "order is zero, and tail starts with 1")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(6), 1, "order is zero, and tail starts with 1")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(7), 1, "order is zero, and tail starts with 1")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(8), 2, "order is one, but tail is zero")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(8+3), 2, "order is one, but tail is zero")
        XCTAssertEqual(BTCFancyEncryptedMessage.targetForCompactTarget(8+4), 3, "order is one, and tail starts with 1")
        
        
        var t: UInt8 = 0
        
        while true {
            var nt = t
            let order: UInt32 = UInt32(t >> 3)
            if order == 0 { nt = t >> 2 }
            if order == 1 { nt = t & (0xff - 1 - 2) }
            if order == 2 { nt = t & (0xff - 1) }
            
            let target: UInt32 = BTCFancyEncryptedMessage.targetForCompactTarget(t)
            
            let t2: UInt8 = BTCFancyEncryptedMessage.compactTargetForTarget(target)
            
            // uncomment this line to visualize data
            
//            println(NSString(format: "byte = % 4d %@   target = %@ % 11d", Int(t), self.binaryString8(t), self.binaryString32(target), target))
//            println(NSString(format: "t = % 4d %@ (%@) -> %@ % 11d -> %@ % 3d", Int(t), self.binaryString8(t), self.binaryString8(nt), self.binaryString32(target), target, self.binaryString8(t2), Int(t2)))
            
            XCTAssertEqual(nt, t2, "should transform back and forth correctly")
            
            if t == 0xff { break }
            t++
            
        }
        
    }
    
    func binaryString8(byte: UInt8) -> NSString {
        return NSString(format: "%d%d%d%d%d%d%d%d",
            Int(((byte >> 7) & 1)),
            Int(((byte >> 6) & 1)),
            Int(((byte >> 5) & 1)),
            Int(((byte >> 4) & 1)),
            Int(((byte >> 3) & 1)),
            Int(((byte >> 2) & 1)),
            Int(((byte >> 1) & 1)),
            Int(((byte >> 0) & 1)))
    }
    
    func binaryString32(eent: UInt32) -> NSString{
        return NSString(format: "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
            Int(((eent >> 31) & 1)),
            Int(((eent >> 30) & 1)),
            Int(((eent >> 29) & 1)),
            Int(((eent >> 28) & 1)),
            Int(((eent >> 27) & 1)),
            Int(((eent >> 26) & 1)),
            Int(((eent >> 25) & 1)),
            Int(((eent >> 24) & 1)),
            Int(((eent >> 23) & 1)),
            Int(((eent >> 22) & 1)),
            Int(((eent >> 21) & 1)),
            Int(((eent >> 20) & 1)),
            Int(((eent >> 19) & 1)),
            Int(((eent >> 18) & 1)),
            Int(((eent >> 17) & 1)),
            Int(((eent >> 16) & 1)),
            Int(((eent >> 15) & 1)),
            Int(((eent >> 14) & 1)),
            Int(((eent >> 13) & 1)),
            Int(((eent >> 12) & 1)),
            Int(((eent >> 11) & 1)),
            Int(((eent >> 10) & 1)),
            Int(((eent >> 9) & 1)),
            Int(((eent >> 8) & 1)),
            Int(((eent >> 7) & 1)),
            Int(((eent >> 6) & 1)),
            Int(((eent >> 5) & 1)),
            Int(((eent >> 4) & 1)),
            Int(((eent >> 3) & 1)),
            Int(((eent >> 2) & 1)),
            Int(((eent >> 1) & 1)),
            Int(((eent >> 0) & 1)))
    }
    
}
