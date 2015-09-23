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
        
        var error: NSError?
        
        let outputs: [AnyObject]!
        do {
            outputs = try BTCBlockchainInfo().unspentOutputsWithAddresses([BTCAddress(string: "1LKF45kfvHAaP7C4cF91pVb3bkAsmQ8nBr")!])
        } catch let error1 as NSError {
            error = error1
            outputs = nil
        }
        
        XCTAssert(outputs.count == 0, "should return an empty array")
        XCTAssert(error == nil, "should have no error")
        
    }
    
    func testNonEmptyUnspents() {
        
        var error: NSError?
        
        let outputs: [AnyObject]!
        do {
            outputs = try BTCBlockchainInfo().unspentOutputsWithAddresses([BTCAddress(string: "1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")!])
        } catch let error1 as NSError {
            error = error1
            outputs = nil
        }
        
        XCTAssert(outputs.count > 0, "should return a non-empty array")
        XCTAssert((outputs.first as? BTCTransactionOutput) != nil, "should contain BTCTransactionOutput objects")
        XCTAssert(error == nil, "should have no error")
    }
    
    
}
