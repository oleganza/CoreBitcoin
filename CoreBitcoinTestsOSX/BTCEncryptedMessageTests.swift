//
//  BTCEncryptedMessageTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 12/6/15.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

import XCTest

class BTCEncryptedMessageTests: XCTestCase {
    
    func testAll() {
        let em = BTCEncryptedMessage()
        em.senderKey = BTCKey(WIF: "L1Ejc5dAigm5XrM3mNptMEsNnHzS7s51YxU7J61ewGshZTKkbmzJ")
        em.recipientKey = BTCKey(WIF: "KxfxrUXSMjJQcb3JgnaaA6MqsrKQ1nBSxvhuigdKRyFiEm6BZDgG")
        
        let message = "attack at dawn".dataUsingEncoding(NSUTF8StringEncoding)
        let expectedCiphertext = BTCDataFromHex("0339e504d6492b082da96e11e8f039796b06cd4855c101e2492a6f10f3e056a9e712c732611c6917ab5c57a1926973bc44a1586e94a783f81d05ce72518d9b0a80e2e13c7ff7d1306583f9cc7a48def5b37fbf2d5f294f128472a6e9c78dede5f5")
        
        let ciphertext = em.encrypt(message)
        XCTAssertEqual(ciphertext, expectedCiphertext, "Must encrypt correctly")
        
        //Must decrypt
        let plaintext = em.decrypt(expectedCiphertext)
        XCTAssertEqual(plaintext, message, "Must decrypt correctly")
    }
    
}
