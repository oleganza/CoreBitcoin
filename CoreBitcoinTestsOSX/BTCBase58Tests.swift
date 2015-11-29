//
//  BTCBase58Tests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 11/27/15.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

import XCTest

class BTCBase58Tests: XCTestCase {
    
    func testAll() {
        BTCAssertDetectsInvalidBase58(nil)
        BTCAssertDetectsInvalidBase58(" ")
        BTCAssertDetectsInvalidBase58("lLoO")
        BTCAssertDetectsInvalidBase58("l")
        BTCAssertDetectsInvalidBase58("L")
        BTCAssertDetectsInvalidBase58("o")
        BTCAssertDetectsInvalidBase58("O")
        BTCAssertDetectsInvalidBase58("öまи")
        
        BTCAssertHexEncodesToBase58("", base58: "") // Empty string is valid encoding of an empty binary string
        BTCAssertHexEncodesToBase58("61", base58: "2g")
        BTCAssertHexEncodesToBase58("626262", base58: "a3gV")
        BTCAssertHexEncodesToBase58("636363", base58: "aPEr")
        BTCAssertHexEncodesToBase58("73696d706c792061206c6f6e6720737472696e67", base58: "2cFupjhnEsSn59qHXstmK2ffpLv2")
        BTCAssertHexEncodesToBase58("00eb15231dfceb60925886b67d065299925915aeb172c06647", base58: "1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L")
        BTCAssertHexEncodesToBase58("516b6fcd0f", base58: "ABnLTmg")
        BTCAssertHexEncodesToBase58("bf4f89001e670274dd", base58: "3SEo3LWLoPntC")
        BTCAssertHexEncodesToBase58("572e4794", base58: "3EFU7m")
        BTCAssertHexEncodesToBase58("ecac89cad93923c02321", base58: "EJDM8drfXA6uyA")
        BTCAssertHexEncodesToBase58("10c8511e", base58: "Rt5zm")
        BTCAssertHexEncodesToBase58("00000000000000000000", base58: "1111111111")
        
        
        if false { //in Objective-C version, is `if ((0))`
            // Search for vanity prefix
            let prefix = "s"
            
            var payload = BTCRandomDataWithLength(32)
            for (var i = UInt32(0x10000000); i <= UINT32_MAX; i++) {
                var j = 10
                var serialization: String? = nil
                repeat
                {
                    let data = NSMutableData()
                    
                    var idx: UInt32 = 0
                    data.appendBytes(&i, length: sizeof(UInt32))
                    data.appendBytes(&idx, length: sizeof(UInt32))
                    data.appendData(payload)
                    
                    serialization = BTCBase58CheckStringWithData(data)
                    
                    payload = BTCRandomDataWithLength(32)
                    
                } while serialization!.hasPrefix(prefix) && j-- > 0
                
                if serialization!.hasPrefix(prefix) {
                    print("integer for prefix %@ is %d", prefix, i)
                    break;
                }
            }
        }
        
        
    }
    

}


func BTCAssertHexEncodesToBase58(hex: String, base58: String) {
    let data = BTCDataFromHex(hex)
    
    //Encode
    XCTAssertEqual(BTCBase58StringWithData(data), base58, "should encode in base58 correctly")
    
    //Decode
    let data2 = BTCDataFromBase58(base58)
    XCTAssertEqual(data2, data, "should decode base58 correctly")
}

func BTCAssertDetectsInvalidBase58(text: String?) {
    let data = BTCDataFromBase58Check(text)
    XCTAssertNil(data, "should return nil if base58 is invalid")
}

