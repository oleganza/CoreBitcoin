//
//  BTCPaymentProtocolTests.swift
//  CoreBitcoin
//
//  Created by Oleg Andreev on 03.06.2015.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCPaymentProtocolTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOpenAssetsPaymentRequestDetails() {

        let pr = BTCPaymentDetails(data: BTCDataFromHex("12361217a9142b94378e6ed1e52e8f1fcdbce3f5106f6d0c2b4e878afa0114346282702ba85eda1796a580aa318034308a27c490fa01d209121c08ae2c1217a9141fca9ebacd3720968c7b636e5879991e05f290718718efadbdab052a04746573743211687474703a2f2f676f6f676c652e636f6d"))!

        XCTAssertEqual(pr.memo!, "test", "Memo should be 'test'")
        XCTAssertEqual(pr.paymentURL!.absoluteString!, "http://google.com", "Payment URL should be google.com")
        XCTAssertEqual(pr.inputs.count,  0, "Has no inputs")
        XCTAssertEqual(pr.outputs.count, 2, "Has 2 outputs")

        let out1 = pr.outputs[0] as! BTCTransactionOutput
        let out2 = pr.outputs[1] as! BTCTransactionOutput

        XCTAssertEqual(pr.outputs.map{$0.script!.standardAddress.string}, ["35fSY6FZS4LdELQqqHw54hDhs4hfmF7DCL", "34b7bn3tQUBMVwQjQXH9u7ZLNaDmwSVwjg"], "Outputs should have P2SH addresses")

        XCTAssertEqual(out1.value(), BTCUnspecifiedPaymentAmount, "First output has no amount specified")
        XCTAssertEqual((out1.userInfo["assetID"]! as! BTCAssetID).string, "ALYro2zndzUpPKcZXXqSYE1npuM4ycY1MA", "First output has asset ID ALYro2...")
        XCTAssertEqual(out1.userInfo["assetAmount"]! as! Int, 1234, "First output has asset amount 1234")

        XCTAssertEqual(out2.value(), 5678, "Second output has 5678")
        XCTAssert(out2.userInfo["assetID"] == nil, "Second output has no asset info")
        XCTAssert(out2.userInfo["assetAmount"] == nil, "Second output has no asset info")
    }


}
