//
//  BTCSecretSharingTests.swift
//  CoreBitcoin
//
//  Created by Oleg Andreev on 26.11.2015.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

import XCTest

class BTCSecretSharingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVectors() {

        let testVectors = [
            [
                "secret": "31415926535897932384626433832795",
                "1-of-1": ["1131415926535897932384626433832795"],
                "1-of-2": ["1131415926535897932384626433832795", "1231415926535897932384626433832795"],
                "2-of-2": ["215af384f05d9b45f0e4e348f95b371acd", "2284a5b0ba67ddf44ea6422f8e82eb0e05"],
                "1-of-3": ["1131415926535897932384626433832795", "1231415926535897932384626433832795", "1331415926535897932384626433832795"],
                "2-of-3": ["215af384f05d9b45f0e4e348f95b371acd", "2284a5b0ba67ddf44ea6422f8e82eb0e05", "23ae57dc847220a2ac67a11623aa9f013d"],
            ],
        ]

        let ssss = BTCSecretSharing(version: .Compact128)
        print("ssss order: \(ssss.order.hexString) = \(ssss.order.decimalString)")

        let shares = try! ssss.splitSecret(BTCDataFromHex("31415926535897932384626433832795"), threshold: 2, shares: 3)
        print("ssss shares: \(shares.map{ BTCHexFromData($0 as! NSData) })")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

 

}
