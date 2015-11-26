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
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&label=Hello%20world"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertTrue(bURL.isValidBitcoinURL, "Must be valid bitcoin url")
        XCTAssertEqual(bURL.amount, 123450009, "Must parse amount formatted as btc")
        XCTAssertEqual(bURL.address!.string, "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", "Must parse address")
        XCTAssertNil(bURL.paymentRequestURL, "Must parse payment request")
        XCTAssertEqual(bURL.label!, "Hello world", "Must parse label")
        XCTAssertEqual(bURL.queryParameters["label"] as? String, "Hello world", "Must provide raw query items access")
        XCTAssertEqual(bURL.queryParameters["amount"] as? String, "1.23450009", "Must provide raw query items access")
        XCTAssertEqual(bURL["label"] as? String, "Hello world", "Must provide raw query items access")
        XCTAssertEqual(bURL["amount"] as? String, "1.23450009", "Must provide raw query items access")
    }
    
    func testCompatiblePaymentRequest() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T?amount=1.23450009&r=http://example.com/order-1000123"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertTrue(bURL.isValidBitcoinURL, "Must be valid bitcoin url")
        XCTAssertEqual(bURL.amount, 123450009, "Must parse amount formatted as btc")
        XCTAssertEqual(bURL.address!.string, "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T", "Must parse address")
        XCTAssertEqual(bURL.paymentRequestURL!.absoluteString, "http://example.com/order-1000123", "Must parse payment request")
    }
    
    func testNakedPaymentRequest() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?r=http://example.com/order-1000123"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertTrue(bURL.isValidBitcoinURL, "Must be valid bitcoin url")
        XCTAssertEqual(bURL.amount, 0, "Default amount is zero")
        XCTAssertNil(bURL.address, "Default address is nil")
        XCTAssertEqual(bURL.paymentRequestURL!.absoluteString, "http://example.com/order-1000123", "Must parse payment request")
    }
    
    func testInvalidURL1() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?x=something"))!
        XCTAssertFalse(bURL.isValid, "Must not be valid")
        XCTAssertEqual(bURL.amount, 0, "Default amount is zero")
        XCTAssertNil(bURL.address, "Default address is nil")
        XCTAssertNil(bURL.paymentRequestURL, "Must have nil payment request")
        XCTAssertEqual(bURL["x"] as? String, "something", "Must have query item")
    }
    
    func testInvalidURL2() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:?amount=1.2"))!
        XCTAssertFalse(bURL.isValid, "Must not be valid")
        XCTAssertEqual(bURL.amount, 120000000, "Must parse amount")
        XCTAssertNil(bURL.address, "Default address is nil")
        XCTAssertNil(bURL.paymentRequestURL, "Must have nil payment request")
        XCTAssertEqual(bURL["amount"] as? String, "1.2", "Must have query item")
    }

    func testMalformedURL1() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:xxxx"))
        XCTAssertNil(bURL, "Must not parse broken address")
    }
    
    func testMalformedURL2() {
        let bURL = BTCBitcoinURL(URL: NSURL(string: "http://example.com"))
        XCTAssertNil(bURL, "Must not parse other schemas than bitcoin:")
    }

    func testOpenAssetsURL() {
        // This is an example of a functional test case.
        let bURL = BTCBitcoinURL(URL: NSURL(string: "openassets:akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy?amount=123&asset=ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertFalse(bURL.isValidBitcoinURL, "Must not be valid bitcoin url")
        XCTAssertTrue(bURL.isValidOpenAssetsURL, "Must be valid OA url")
        XCTAssertEqual(bURL.amount, 123, "Must parse amount")
        XCTAssertEqual(bURL.address!.string, "akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy", "Must parse address")
        XCTAssertEqual(bURL.assetID!.string, "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", "Must parse asset ID")
        XCTAssertNil(bURL.paymentRequestURL, "Must not parse payment request")
    }

    func testOpenAssetsPaymentRequestURL() {
        // This is an example of a functional test case.
        let bURL = BTCBitcoinURL(URL: NSURL(string: "openassets:?r=http://example.com"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertFalse(bURL.isValidBitcoinURL, "Must not be valid bitcoin url")
        XCTAssertTrue(bURL.isValidOpenAssetsURL, "Must be valid OA url")
        XCTAssertNotNil(bURL.paymentRequestURL, "Must parse payment request")
    }

    func testCompatibleOpenAssetsURL() {
        // This is an example of a functional test case.
        let bURL = BTCBitcoinURL(URL: NSURL(string: "bitcoin:akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy?amount=123&asset=ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC"))!
        XCTAssertTrue(bURL.isValid, "Must be valid")
        XCTAssertFalse(bURL.isValidBitcoinURL, "Must not be valid bitcoin url")
        XCTAssertTrue(bURL.isValidOpenAssetsURL, "Must be valid OA url")
        XCTAssertEqual(bURL.amount, 123, "Must parse amount")
        XCTAssertEqual(bURL.address!.string, "akB4NBW9UuCmHuepksob6yfZs6naHtRCPNy", "Must parse address")
        XCTAssertEqual(bURL.assetID!.string, "ALn3aK1fSuG27N96UGYB1kUYUpGKRhBuBC", "Must parse asset ID")
        XCTAssertNil(bURL.paymentRequestURL, "Must not parse payment request")
    }

}
