//
//  BTCBitcoinURLTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 5/16/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCBitcoinURLTests: XCTestCase {

    func testExample() {
        // This is an example of a functional test case.
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&label=Hello%20world"))
        XCTAssertNotNil(bURL, "Must parse")
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertEqual(bURL.amount, 123450009, "Must parse amount formatted as btc")
        XCTAssertEqual(bURL.address.string, "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", "Must parse address")
        XCTAssertNil(bURL.paymentRequestURL, "Must parse payment request")
        XCTAssertEqual(bURL.label, "Hello world", "Must parse label")
        XCTAssertEqual(bURL.queryParameters["label"] as! String, "Hello world", "Must provide raw query items access")
        XCTAssertEqual(bURL.queryParameters["amount"] as! String, "1.23450009", "Must provide raw query items access")
        XCTAssertEqual(bURL["label"] as! String, "Hello world", "Must provide raw query items access")
        XCTAssertEqual(bURL["amount"] as! String, "1.23450009", "Must provide raw query items access")
    }
    
    func testCompatiblePaymentRequest() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&r=http://example.com/order-1000123"))
        XCTAssertNotNil(bURL, "Must parse")
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertEqual(bURL.amount, 123450009, "Must parse amount formatted as btc")
        XCTAssertEqual(bURL.address.string, "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", "Must parse address")
        XCTAssertEqual(bURL.paymentRequestURL.absoluteString!, "http://example.com/order-1000123", "Must parse payment request")
        
    }
    
    func testNakedPaymentRequest() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?r=http://example.com/order-1000123"))
        XCTAssertNotNil(bURL, "Must parse")
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertEqual(bURL.amount, 0, "Default amount is zero")
        XCTAssertNil(bURL.address, "Default address is nill")
        XCTAssertEqual(bURL.paymentRequestURL.absoluteString!, "http://example.com/order-1000123", "Must parse payment request")
        
    }
    
    func testInvalidURL1() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?x=something"))
        XCTAssertNotNil(bURL, "Must parse")
        XCTAssertFalse(bURL.isValid, "Must not be valid")
        XCTAssertEqual(bURL.amount, 0, "Default amount is zero")
        XCTAssertNil(bURL.address, "Default address is nil")
        XCTAssertNil(bURL.paymentRequestURL, "Must have nil payment request")
        XCTAssertEqual(bURL["x"] as! String, "something", "Must have query item")
    }
    
    func testInvalidURL2() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?amount=1.2"))
        XCTAssertNotNil(bURL, "Must parse")
        XCTAssertFalse(bURL.isValid, "Must not be valid")
        XCTAssertEqual(bURL.amount, 120000000, "Must parse amount")
        XCTAssertNil(bURL.address, "Default address is nil")
        XCTAssertNil(bURL.paymentRequestURL, "Must have nil payment request")
        XCTAssertEqual(bURL["amount"] as! String, "1.2", "Must have query item")
    }

    func testMalformedURL1() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:xxxx"))
        XCTAssertNil(bURL, "Must not parse broken address")
    }
    
    func testMalformedURL2() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "http://example.com"))
        XCTAssertNil(bURL, "Must not parse other schemas than bitcoin:")
    }
    
}
