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

    func testConfigurations() {
        let ssss128 = BTCSecretSharing(version: .Compact128)
        XCTAssertEqual(ssss128.order.hexString, "ffffffffffffffffffffffffffffff61")
        XCTAssertEqual(ssss128.bitlength, 128)

        let ssss104 = BTCSecretSharing(version: .Compact104)
        XCTAssertEqual(ssss104.order.hexString, "ffffffffffffffffffffffffef")
        XCTAssertEqual(ssss104.bitlength, 104)

        let ssss96 = BTCSecretSharing(version: .Compact96)
        XCTAssertEqual(ssss96.order.hexString, "ffffffffffffffffffffffef")
        XCTAssertEqual(ssss96.bitlength, 96)
    }

    func testVectors() {

        let testVectors:[[String:AnyObject]] = [

            // 128-bit secrets

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
            ],

            // 104-bit secrets

            [
                "secret": "31415926535897932384626433",
                "1-of-1": ["1131415926535897932384626433"],
                "1-of-2": ["1131415926535897932384626433", "1231415926535897932384626433"],
                "2-of-2": ["21a8453099fb8ae36aab2c1b6000", "221f49080da3bd2f4232d3d45bde"],
                "1-of-3": ["1131415926535897932384626433", "1231415926535897932384626433", "1331415926535897932384626433"],
                "2-of-3": ["21a8453099fb8ae36aab2c1b6000", "221f49080da3bd2f4232d3d45bde", "23964cdf814bef7b19ba7b8d57ab"],
                "3-of-3": ["312b1880cc54fa4f009a4828f7d1", "3229a1cb3a58caea9c2bf0a31cb3", "332cdd38705eca6a65d87dd0d2d9"],
                "4-of-6": ["414dc7bfe7e209630e44617d9737", "422da138cfafb6fa65f2556740c0", "43bd57245c5ccd2a2b2018645fa5", "44e972e30c89b7beeec062b9f2df", "459e7dd55ed6e28541c5ecacf956", "46c9015bd1e4b949b5236e8271e1"],
                "10-of-16": ["a1b7a1ae5c3b1de94a8f4b8f7e05", "a25906c43a8969f6b5bf4be06006", "a3e97beb27daf0e2f81e0346a327", "a4d1a2cbee6be940edf213ccbc5f", "a50810074c61f554e9790453f951", "a629b4cf2ee2e5692af73337a0ca", "a7902bbc8ad42f8f9d15128e8758", "a8e6e7bce215a6f69d903a756a02", "a9834eca7f01f1a00215cf0ab33c", "aaa7b73a49f876d11a0b258fec2f", "abde0dc1d5af02f828197e7e0ac7", "acbc9befd7052707b1821140074e", "adadfaa8b410696a0d9089baaf84", "aebcb2502c16b5afd4f377c98514", "afeb62a04f2c15fa2f540d669b95", "a04b86c51029a5de8538e14edf9e"],
            ],
            [
                "secret": "deadbeefcafebabedeadbeefca",
                "1-of-1": ["11deadbeefcafebabedeadbeefca"],
                "2-of-2": ["210833159d705e79f32a1c8cea96", "2231b86c4b15be3927758b5ae551"],
                "2-of-3": ["210833159d705e79f32a1c8cea96", "2231b86c4b15be3927758b5ae551", "235b3dc2f8bb1df85bc0fa28e00c"],
                "3-of-3": ["3112462cb0571d40f6e704adf5b7", "320841c292cc488c414627a293e1", "33c0a080972a809c9dfc169cca48"],
            ],
            [
                "secret": "ffffffffffffffffffffffffee",
                "1-of-1": ["11ffffffffffffffffffffffffee"],
                "2-of-2": ["21b47b7bca3c91cfa72ec99d9ded", "2268f6f79479239f4e5d933b3bec"],
                "2-of-3": ["21b47b7bca3c91cfa72ec99d9ded", "2268f6f79479239f4e5d933b3bec", "231d72735eb5b56ef58c5cd8d9eb"],
                "3-of-3": ["31354043caf86f780c8d306fa32b", "32fc8f21351fc80c54a2b8604700", "3355ec983e7609bcd84097d1eba0"],
            ],
            [
                "secret": "00000000000000000000000000",
                "1-of-1": ["1100000000000000000000000000"],
                "2-of-2": ["219aa26f55d8a706cb6801023e74", "223544deabb14e0d96d002047cf9"],
                "2-of-3": ["219aa26f55d8a706cb6801023e74", "223544deabb14e0d96d002047cf9", "23cfe74e0189f51462380306bb6d"],
                "3-of-3": ["315a50b9d324cbf8cf4546d9e085", "32ca50d93a5f8028070814b77faa", "3350005e35b01c8da7486998dd80"],
            ],


            // 96-bit secrets

            [
                "secret": "314159265358979323846264",
                "1-of-1": ["11314159265358979323846264"],
                "1-of-2": ["11314159265358979323846264", "12314159265358979323846264"],
                "2-of-2": ["219c6d2fc2303e0a64e380b5a8", "220799065e0d237d36a37d08fd"],
                "1-of-3": ["11314159265358979323846264", "12314159265358979323846264", "13314159265358979323846264"],
                "2-of-3": ["219c6d2fc2303e0a64e380b5a8", "220799065e0d237d36a37d08fd", "2372c4dcf9ea08f00863795c41"],
                "3-of-3": ["318934eda6285292a6b6f2fd0a", "321f6b0d5fe662e2dec79d1572", "33f3e3b8538d89883b5582ab7a"],
                "4-of-6": ["4174b316d14c485cf444325100", "4273da5159c33a43335df79a53", "4337969f2f75a6c630f732b1a1", "44c8c796c2210661cd96420a1d", "45304cce8182d191e9c184172d", "467705dcdd5880d265ff574bf3"],
                "10-of-16": ["a1090ba03f98fe44fb0c9cbc92", "a28a63d4872a1372ba8bcaa0d9", "a3a6970d6bf596f299b7eea31b", "a43c1da6ae60d076ed901e8853", "a591259cce1d7845820d77ff69", "a685b97fb8b78b4a60fddc7e8c", "a77f135e267940f39c0eb82fb0", "a8586914b4373d3485c68cb2b7", "a9838f54e6dc7e957ebe2c0af8", "aaf53281e124ae4daa376055fc", "ab7d182aacdc5f0d7f3629e66b", "acc2e1748f396e5c4183c7122f", "ad4b1e32f36a2436f87f5f6eb7", "aea729b60757d4fd78576f54f4", "af44458534c9b2a98538f06161", "a033b3472c9623ccff2db82f42"]
            ],
            [
                "secret": "deadbeefcafebabedeadbeef",
                "1-of-1": ["11deadbeefcafebabedeadbeef"],
                "2-of-2": ["21b7d008c40782c660de3f2759", "2290f252984406d202ddd08fc3"],
                "2-of-3": ["21b7d008c40782c660de3f2759", "2290f252984406d202ddd08fc3", "236a149c6c808adda4dd61f82d"],
                "3-of-3": ["31f0e31071c238b0b8edf3e099", "32bc5fadd11bda67369fbdfebe", "334123970dd7e3de37f40c195e"],
            ],
            [
                "secret": "ffffffffffffffffffffffee",
                "1-of-1": ["11ffffffffffffffffffffffee"],
                "2-of-2": ["21177a5ce6e086a40df2a3892c", "222ef4b9cdc10d481be5471259"],
                "2-of-3": ["21177a5ce6e086a40df2a3892c", "222ef4b9cdc10d481be5471259", "23466f16b4a193ec29d7ea9b86"],
                "3-of-3": ["315adf89c7779b2169a341572a", "32ea101e87f4972984b102f614", "33ad91be4176f418512944dcce"],
            ],
            [
                "secret": "000000000000000000000000",
                "1-of-1": ["11000000000000000000000000"],
                "2-of-2": ["21197de3ef5aae4f1df4e98384", "2232fbc7deb55c9e3be9d30708"],
                "2-of-3": ["21197de3ef5aae4f1df4e98384", "2232fbc7deb55c9e3be9d30708", "234c79abce100aed59debc8a8c"],
                "3-of-3": ["317119aa02f2a7f1fccb38a7f7", "324dc572966cb5fdac97a47389", "33960359ba6e2a230f654362a5"],
            ],
        ]

        for test in testVectors {
            let hexsecret = test["secret"] as! String
            let secret = BTCDataFromHex(hexsecret)

            let ssss:BTCSecretSharing

            switch secret.length {
            case 128/8:
                ssss = BTCSecretSharing(version: .Compact128)
            case 104/8:
                ssss = BTCSecretSharing(version: .Compact104)
            case 96/8:
                ssss = BTCSecretSharing(version: .Compact96)
            default:
                XCTFail("Unsupported secret length")
                ssss = BTCSecretSharing(version: .Compact128)
            }

            for (key, definedShares) in test where key != "secret" {
                let mn:[Int] = key.componentsSeparatedByString("-of-").map{ ($0 as NSString).integerValue }
                let m = mn[0]
                let n = mn[1]

                // Test split
                let shares:[NSData] = try! ssss.splitSecret(secret, threshold:m, shares:n)
                let hexshares:[String] = shares.map{ BTCHexFromData($0) }
                XCTAssertEqual(hexshares, definedShares as! [String])

                // Test restore
                let variants:[[NSData]] = [
                    Array(shares[0..<m]),
                    Array(shares.reverse()[0..<m]),
                    Array(shares[0..<m]).reverse(),
                    Array(shares.reverse()[0..<m]).reverse()
                ]

                for shs in variants {
                    let restoredSecret = try! ssss.joinShares(shs)
                    XCTAssertEqual(secret, restoredSecret)
                }
            }

        }
    }

 

}
