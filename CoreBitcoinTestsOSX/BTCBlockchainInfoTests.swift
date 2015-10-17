//
//  BTCBlockchainInfoTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 4/20/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCBlockchainInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyUnspents() {
        
        do {
            let outputs = try BTCBlockchainInfo().unspentOutputsWithAddresses([BTCAddress(string: "1LKF45kfvHAaP7C4cF91pVb3bkAsmQ8nBr")!])
            XCTAssert(outputs.count == 0, "should return an empty array")
        } catch {
            XCTFail("Error: \(error)")
        }
        
    }
    
    func testNonEmptyUnspents() {
        
        do {
            let outputs = try BTCBlockchainInfo().unspentOutputsWithAddresses([BTCAddress(string: "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")!])
            XCTAssert(outputs.count > 0, "should return a non-empty array")
            XCTAssert((outputs.first as! BTCTransactionOutput?) != nil, "should contain BTCTransactionOutput objects")
        } catch {
            XCTFail("Error: \(error)")
        }
        
    }
    
    
}
