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

        let ssss = BTCSecretSharing(version: .Compact128)
        XCTAssertEqual(ssss.order.hexString, "ffffffffffffffffffffffffffffff61")

        let testVectors:[[String:AnyObject]] = [
            [
                "secret": "31415926535897932384626433832795",
                "1-of-1": ["1131415926535897932384626433832795"],
                "1-of-2": ["1131415926535897932384626433832795", "1231415926535897932384626433832795"],
                "2-of-2": ["215af384f05d9b45f0e4e348f95b371acd", "2284a5b0ba67ddf44ea6422f8e82eb0e05"],
                "1-of-3": ["1131415926535897932384626433832795", "1231415926535897932384626433832795", "1331415926535897932384626433832795"],
                "2-of-3": ["215af384f05d9b45f0e4e348f95b371acd", "2284a5b0ba67ddf44ea6422f8e82eb0e05", "23ae57dc847220a2ac67a11623aa9f013d"],
                "3-of-3": ["316cb005ab037e85ed9c8befbe72fef75c", "321387c8a1b34863197fae486ca60c1b97", "3325c8a20a62b62f16cceb6c6eccaa93a7"],
                "4-of-6": ["416c4b3a8dc218696f8b1aed23385496eb", "429b14a744ce462bdc71b910b5cf0890ba", "4384d4d7881b01db3881cd0f17457112c8",
                "44f0c303944b6b73e265c52a42e9601a3c", "45a61663a602a2f238c80fa43408a7a57b", "466c062ff9e3c8529a531abee5f119b1ac"],
                "10-of-16": ["a1a8b4077b75b0b18aefa63399d0b8d749", "a2e015e817190296d9ebe29f1c8cdc21c7", "a3c65760010c358c9760cece5da815edb4", "a4129891c5efd375a8367c854ab08010d6",
                "a53c138386a55b0b35447ca03e44ab4eeb", "a6182993f21038c5d3bf548dac9dee7e20", "a769f010c04a4996b471a82addd4ea05d4", "a88e27a316dda9822f81616b2d48cb5e23",
                "a9b0298820dc8c26989b6f8a2e8b00c3c4", "aa98042e1bcdf63b7283503ac4ad364380", "ab27bed0235b651dd92e764fa8cea25ba8", "ac05890d2177c48f4ec6cabd1047d9dbdc",
                "adba7838775b82e4022af68f19d9985368", "aeb96045352c20fd24c6de8563cb2446f2", "af4f51af0a774592f9eabb71aaf0348def", "a06f50a680d22280f31b853d941c7eb158"],
            ],
            [
                "secret": "deadbeefcafebabedeadbeefcafebabe",
                "1-of-1": ["11deadbeefcafebabedeadbeefcafebabe"],
                "2-of-2": ["217f21b8a8329e69ea75a518485c8da19d", "221f95b2609a3e19160c9c71a0ee1c887c"],
                "2-of-3": ["217f21b8a8329e69ea75a518485c8da19d", "221f95b2609a3e19160c9c71a0ee1c887c", "23c009ac1901ddc841a393caf97fab6ebc"],
                "3-of-3": ["31d6b7c83a2587dd06be735c2ba5c719c0", "32762d76edcca00dd227bccb825a8daa75", "33bd0ecb0ac0474d211a8a0cf3e9526c3e"],
            ],
            [
                "secret": "ffffffffffffffffffffffffffffff60",
                "1-of-1": ["11ffffffffffffffffffffffffffffff60"],
                "2-of-2": ["21375c71bcaf077f5946f9e901efb9cf70", "226eb8e3795e0efeb28df3d203df739ee1"],
                "2-of-3": ["21375c71bcaf077f5946f9e901efb9cf70", "226eb8e3795e0efeb28df3d203df739ee1", "23a61555360d167e0bd4edbb05cf2d6e52"],
                "3-of-3": ["3112dac40bb910928263e5cf3971c39c8b", "32dec3f6359b1f7671aa60dd821c4969d3", "3363bb967da62cabcdd3712ad9ff916915"],
            ],
            [
                "secret": "00000000000000000000000000000000",
                "1-of-1": ["1100000000000000000000000000000000"],
                "2-of-2": ["2125df3f1da76af07c37689382bc8201a6", "224bbe7e3b4ed5e0f86ed127057904034c"],
                "2-of-3": ["2125df3f1da76af07c37689382bc8201a6", "224bbe7e3b4ed5e0f86ed127057904034c", "23719dbd58f640d174a639ba88358604f2"],
                "3-of-3": ["31651161eeddabb39134be97908f0d7d9e", "32671d1a7e6d7ef24037990a5285a75164", "33062329aeaf79bc0d088f5845e3cd7b52"],
            ]
        ]

        for test in testVectors {
            let hexsecret = test["secret"] as! String
            let secret = BTCDataFromHex(hexsecret)
            for (key, definedShares) in test where key != "secret" {
                let mn:[Int] = key.componentsSeparatedByString("-of-").map{ ($0 as NSString).integerValue }
                let m = mn[0]
                let n = mn[1]

                // Test split
                let shares:[NSData] = try! ssss.splitSecret(secret, threshold:m, shares:n)
                let hexshares:[String] = shares.map{ BTCHexFromData($0) }
                XCTAssertEqual(hexshares, definedShares as! [String])

                // Test restore
                let subshares = Array(shares[0..<m])
                let restoredSecret = try! ssss.joinShares(subshares)
                // TBD. XCTAssertEqual(secret, restoredSecret)
            }

        }


        print("ssss order: \(ssss.order.hexString) = \(ssss.order.decimalString)")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

 

}
