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

        let pr = BTCPaymentDetails(data: BTCDataFromHex("121c0888271217a914bb22ad9011886eef754e2be30931f6cd89d13a668712371217a914278f4f9e5c8b2bbbcabd0711a84730c0317c9374878afa0114346282702ba85eda1796a580aa318034308a27c490fa01a09c0118c1cdbda60520a0f6bea6052a0e74686973206973206120746573743211687474703a2f2f676f6f676c652e636f6d42240a20807164529ec1b7866d7801d7dbc34edc326a991633573b549116c62dfd9b4f4f1000"))!

        XCTAssertEqual(pr.memo!, "this is a test", "Memo should be present")
        XCTAssertEqual(pr.paymentURL!.absoluteString, "http://google.com", "Payment URL should be google.com")
        XCTAssertEqual(pr.inputs.count,  1, "Has 1 input")
        XCTAssertEqual(pr.outputs.count, 2, "Has 2 outputs")

        let in1 = pr.inputs[0] as! BTCTransactionInput
        let out1 = pr.outputs[0] as! BTCTransactionOutput
        let out2 = pr.outputs[1] as! BTCTransactionOutput

        XCTAssertEqual(in1.previousIndex, 0, "First input has output index 0")
        XCTAssertEqual(BTCHexFromData(in1.previousHash), "807164529ec1b7866d7801d7dbc34edc326a991633573b549116c62dfd9b4f4f", "First input has output txid 807164529...")

        XCTAssertEqual(pr.outputs.map{$0.script!.standardAddress.string}, ["3JkVptF3n9VS6FGR6NjrEr8NnUCh4TPvMs", "35JBxSyefxmVj34obKC2od3r98MuaJ34am"], "Outputs should have P2SH addresses")

        XCTAssertEqual(out1.value, 5000, "First output has 5000")
        XCTAssert(out1.userInfo["assetID"] == nil, "First output has no asset info")
        XCTAssert(out1.userInfo["assetAmount"] == nil, "First output has no asset info")

        XCTAssertEqual(out2.value, BTCUnspecifiedPaymentAmount, "Second output has no amount specified")
        XCTAssertEqual((out2.userInfo["assetID"]! as! BTCAssetID).string, "ALYro2zndzUpPKcZXXqSYE1npuM4ycY1MA", "Second output has asset ID ALYro2...")
        XCTAssertEqual(out2.userInfo["assetAmount"]! as? Int, 20000, "Second output has asset amount 1234")
    }


}
