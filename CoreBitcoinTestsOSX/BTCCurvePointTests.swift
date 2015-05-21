//
//  BTCCurvePointTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 5/21/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCCurvePointTests: XCTestCase {
    
    func testPublicKey() {
        
        // Should be able to create public key N = n*G via BTCKey API as well as raw EC arithmetic using BTCCurvePoint.
        let privateKeyData = BTCHash256("Private Key Seed".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        
        // 1. Make the pubkey using BTCKey API.
        
        let key = BTCKey(privateKey: privateKeyData)
        
        
        // 2. Make the pubkey using BTCCurvePoint API.
        
        let bn = BTCBigNumber(unsignedBigEndian: privateKeyData)
        
        let generator = BTCCurvePoint.generator()
        let pubKeyPoint = generator.copy().multiply(bn)
        let keyFromPoint = BTCKey(curvePoint: pubKeyPoint)
        
        // 2.1. Test serialization
        
        XCTAssertEqual(pubKeyPoint, BTCCurvePoint(data: pubKeyPoint.data), "test serialization")
        
        // 3. Compare the two pubkeys.
        
        XCTAssertEqual(keyFromPoint, key, "pubkeys should be equal")
        XCTAssertEqual(key.curvePoint, pubKeyPoint, "points should be equal")
        
    }
    
    func testDiffieHellman() {
        // Alice: a, A=a*G. Bob: b, B=b*G.
        // Test shared secret: a*B = b*A = (a*b)*G.
        
        let alicePrivateKeyData = BTCHash256("alice private key".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        let bobPrivateKeyData = BTCHash256("bob private key".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        
//        println("Alice privkey: \(BTCHexFromData(alicePrivateKeyData))")
//        println("Bob privkey: \(BTCHexFromData(bobPrivateKeyData))")
        
        let aliceNumber = BTCBigNumber(unsignedBigEndian: alicePrivateKeyData)
        let bobNumber = BTCBigNumber(unsignedBigEndian: bobPrivateKeyData)
        
//        println("Alice number: \(aliceNumber.hexString)")
//        println("Bob number: \(bobNumber.hexString)")
        
        let aliceKey = BTCKey(privateKey: alicePrivateKeyData)
        let bobKey = BTCKey(privateKey: bobPrivateKeyData)
        
        XCTAssertEqual(aliceKey.privateKey, aliceNumber.unsignedBigEndian, "")
        XCTAssertEqual(bobKey.privateKey, bobNumber.unsignedBigEndian, "")
        
        let aliceSharedSecret = bobKey.curvePoint.multiply(aliceNumber)
        let bobSharedSecret = aliceKey.curvePoint.multiply(bobNumber)
        
//        println("(a*B).x = \(aliceSharedSecret.x.decimalString)")
//        println("(b*A).x = \(bobSharedSecret.x.decimalString)")
        
        let sharedSecretNumber = aliceNumber.mutableCopy().multiply(bobNumber, mod: BTCCurvePoint.curveOrder())
        let sharedSecret = BTCCurvePoint.generator().multiply(sharedSecretNumber)
        
        XCTAssertEqual(aliceSharedSecret, bobSharedSecret, "Should have the same shared secret")
        XCTAssertEqual(aliceSharedSecret, sharedSecret, "Multiplication of private keys should yield a private key for the shared point")
        
    }
}
