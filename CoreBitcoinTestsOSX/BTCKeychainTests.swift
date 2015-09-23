//
//  BTCKeychainTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 7/22/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCKeychainTests: XCTestCase {
    
    func testPaths() {
        
        let keychain = BTCKeychain(extendedKey: "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")
        
        XCTAssertEqual(keychain.derivedKeychainWithPath("").extendedPublicKey, keychain.extendedPublicKey, "must return root key")
        XCTAssertEqual(keychain.derivedKeychainWithPath("m").extendedPublicKey, keychain.extendedPublicKey, "must return root key")
        XCTAssertEqual(keychain.derivedKeychainWithPath("/").extendedPublicKey, keychain.extendedPublicKey, "must return root key")
        XCTAssertEqual(keychain.derivedKeychainWithPath("m//").extendedPublicKey, keychain.extendedPublicKey, "must return root key")
        
        XCTAssertEqual(keychain.derivedKeychainWithPath("m/0'").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: true).extendedPublicKey, "must return hardened child at index 0")
        XCTAssertEqual(keychain.derivedKeychainWithPath("/0'").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: true).extendedPublicKey, "must return hardened child at index 0")
        XCTAssertEqual(keychain.derivedKeychainWithPath("0'").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: true).extendedPublicKey, "must return hardened child at index 0")
        
        XCTAssertEqual(keychain.derivedKeychainWithPath("m/0").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: false).extendedPublicKey, "must return non-hardened child at index 0")
        XCTAssertEqual(keychain.derivedKeychainWithPath("/0").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: false).extendedPublicKey, "must return non-hardened child at index 0")
        XCTAssertEqual(keychain.derivedKeychainWithPath("0").extendedPublicKey, keychain.derivedKeychainAtIndex(0, hardened: false).extendedPublicKey, "must return non-hardened child at index 0")
        
        XCTAssertNil(keychain.derivedKeychainWithPath("m / 0 / 1"), "must return nil if path contains spaces")
        XCTAssertNil(keychain.derivedKeychainWithPath("m/b/c"), "must return nil if path contains irrelevant characters")
        XCTAssertNil(keychain.derivedKeychainWithPath("1/m/2"), "must return nil if path contains irrelevant characters")
        XCTAssertNil(keychain.derivedKeychainWithPath("m/1.2^3"), "must return nil if path contains irrelevant characters")
        
    }
    
    func testVector1() {
        /*
        
        Master (hex): 000102030405060708090a0b0c0d0e0f
        * [Chain m]
        * ext pub: xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8
        * ext prv: xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
        * [Chain m/0']
        * ext pub: xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw
        * ext prv: xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7
        * [Chain m/0'/1]
        * ext pub: xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
        * ext prv: xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs
        * [Chain m/0'/1/2']
        * ext pub: xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5
        * ext prv: xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM
        * [Chain m/0'/1/2'/2]
        * ext pub: xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV
        * ext prv: xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334
        * [Chain m/0'/1/2'/2/1000000000]
        * ext pub: xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy
        * ext prv: xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76
        */
        
        let seed = BTCDataWithHexCString("000102030405060708090a0b0c0d0e0f")
        
        let masterChain = BTCKeychain(seed: seed)
        
        XCTAssertEqual(masterChain.key.compressedPublicKeyAddress.string, "15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma", "")
        
//        println("identifier: \(masterChain.identifier) fingerprint: \(masterChain.fingerprint)")
        XCTAssertEqual(masterChain.identifier, BTCDataFromHex("3442193e1bb70916e914552172cd4e2dbc9df811"), "")
        XCTAssertEqual(masterChain.fingerprint, 876747070, "")
        XCTAssertEqual(masterChain.parentFingerprint, 0, "")
        XCTAssertEqual(masterChain.depth, 0, "")
        XCTAssertEqual(masterChain.index, 0, "")
        XCTAssertFalse(masterChain.isHardened, "")
        
        XCTAssertEqual("xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8", masterChain.extendedPublicKey, "")
        XCTAssertEqual("xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi", masterChain.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: masterChain)
        
        let m0prv = masterChain.derivedKeychainWithPath("m/0'")
        
        XCTAssertNotEqual(m0prv.parentFingerprint, 0, "")
        XCTAssertEqual(m0prv.depth, 1, "")
        XCTAssertEqual(m0prv.index, 0, "")
        XCTAssertTrue(m0prv.isHardened, "")
        
        XCTAssertEqual("xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw", m0prv.extendedPublicKey, "")
        XCTAssertEqual("xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7", m0prv.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0prv)
        
        let m0prv1pub = masterChain.derivedKeychainWithPath("m/0'/1")
        
        XCTAssertNotEqual(m0prv1pub.parentFingerprint, 0, "")
        XCTAssertEqual(m0prv1pub.depth, 2, "")
        XCTAssertEqual(m0prv1pub.index, 1, "")
        XCTAssertFalse(m0prv1pub.isHardened, "")
        
        XCTAssertEqual("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ", m0prv1pub.extendedPublicKey, "")
        XCTAssertEqual("xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs", m0prv1pub.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0prv1pub)
        
        let m0prv1pub2prv = masterChain.derivedKeychainWithPath("m/0'/1/2'")
        XCTAssertEqual("xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5", m0prv1pub2prv.extendedPublicKey, "")
        XCTAssertEqual("xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM", m0prv1pub2prv.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0prv1pub2prv)
        
        let m0prv1pub2prv2pub = m0prv1pub2prv.derivedKeychainAtIndex(2)
        XCTAssertEqual("xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV", m0prv1pub2prv2pub.extendedPublicKey, "")
        XCTAssertEqual("xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334", m0prv1pub2prv2pub.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0prv1pub2prv2pub)
        
        let m0prv1pub2prv2pub1Gpub = masterChain.derivedKeychainWithPath("m/0'/1/2'/2/1000000000")
        XCTAssertEqual("xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy", m0prv1pub2prv2pub1Gpub.extendedPublicKey, "")
        XCTAssertEqual("xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76", m0prv1pub2prv2pub1Gpub.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0prv1pub2prv2pub1Gpub)
        
    }
    
    func testVector2() {
        /*
        Master (hex): fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
        * [Chain m]
        * ext pub: xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB
        * ext prv: xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
        * [Chain m/0]
        * ext pub: xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH
        * ext prv: xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt
        * [Chain m/0/2147483647']
        * ext pub: xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a
        * ext prv: xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9
        * [Chain m/0/2147483647'/1]
        * ext pub: xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon
        * ext prv: xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef
        * [Chain m/0/2147483647'/1/2147483646']
        * ext pub: xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL
        * ext prv: xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc
        * [Chain m/0/2147483647'/1/2147483646'/2]
        * ext pub: xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt
        * ext prv: xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j
        */
        
        let seed = BTCDataWithHexCString("fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")
        
        let masterChain = BTCKeychain(seed: seed)
        
//        println("identifier: \(masterChain.identifier) fingerprint: \(masterChain.fingerprint)")
        XCTAssertEqual(masterChain.identifier, BTCDataFromHex("bd16bee53961a47d6ad888e29545434a89bdfe95"), "")
        XCTAssertEqual(masterChain.fingerprint, 3172384485, "")
        XCTAssertEqual(masterChain.parentFingerprint, 0, "")
        XCTAssertEqual(masterChain.depth, 0, "")
        XCTAssertEqual(masterChain.index, 0, "")
        XCTAssertFalse(masterChain.isHardened, "")
        
        XCTAssertEqual("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB", masterChain.extendedPublicKey, "")
        XCTAssertEqual("xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U", masterChain.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: masterChain)
        
        let m0pub = masterChain.derivedKeychainAtIndex(0)
        XCTAssertEqual("xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH", m0pub.extendedPublicKey, "")
        XCTAssertEqual("xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt", m0pub.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0pub)
        
        let m0pubFFprv = m0pub.derivedKeychainAtIndex(2147483647, hardened: true)
        XCTAssertEqual("xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a", m0pubFFprv.extendedPublicKey, "")
        XCTAssertEqual("xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9", m0pubFFprv.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0pubFFprv)
        
        let m0pubFFprv1 = m0pubFFprv.derivedKeychainAtIndex(1)
        XCTAssertEqual("xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon", m0pubFFprv1.extendedPublicKey, "")
        XCTAssertEqual("xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef", m0pubFFprv1.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0pubFFprv1)
        
        let m0pubFFprv1pubFEprv = masterChain.derivedKeychainWithPath("m/0/2147483647'/1/2147483646'")
        XCTAssertEqual("xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL", m0pubFFprv1pubFEprv.extendedPublicKey, "")
        XCTAssertEqual("xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc", m0pubFFprv1pubFEprv.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0pubFFprv1pubFEprv)
        
        let m0pubFFprv1pubFEprv2 = masterChain.derivedKeychainWithPath("m/0/2147483647'/1/2147483646'/2")
        XCTAssertEqual("xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt", m0pubFFprv1pubFEprv2.extendedPublicKey, "")
        XCTAssertEqual("xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j", m0pubFFprv1pubFEprv2.extendedPrivateKey, "")
        
        verifyDeserialization(keychain: m0pubFFprv1pubFEprv2)
        
    }
    
    func testZeroPaddedPrivateKeys() {
        let keychain = BTCKeychain(seed: "stress test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        
        for i in 0 ..< 2*256 {
            //#puts i # i=70 yields a zero-prefixed private key.
            let key = keychain.keyAtIndex(UInt32(i), hardened: true)
            
            XCTAssertEqual(key.privateKey.length, 32, "privkey must be 32 bytes long")
            XCTAssertEqual(key.publicKey.length, 33, "pubkey must be 33 bytes long")
            
//            if unsafeBitCast(key.privateKey.bytes, UnsafePointer<uint8>.self)[0] == 0 {
//                println("i = \(i) address: \(key.address.string)")
//            }
        }
        
        XCTAssertEqual(keychain.keyAtIndex(70, hardened: true).address.string, "1FZQfsXwAoUcn9WVwbfRb4jMMkPJEozLWH", "")
        XCTAssertEqual(unsafeBitCast(keychain.keyAtIndex(70, hardened: true).privateKey.bytes, UnsafePointer<uint8>.self)[0], 0, "must be zero-prefixed")
        XCTAssertEqual(keychain.keyAtIndex(227, hardened: true).address.string, "1LRbeWJC3sLGRk7ob82djVYTNhsH2UdR4f", "")
        XCTAssertEqual(unsafeBitCast(keychain.keyAtIndex(227, hardened: true).privateKey.bytes, UnsafePointer<uint8>.self)[0], 0, "must be zero-prefixed")
        XCTAssertEqual(keychain.keyAtIndex(455, hardened: true).address.string, "1HSr4B5Hr3hc7vAzNHbp7SV7rsFzUhQSeF", "")
        XCTAssertEqual(unsafeBitCast(keychain.keyAtIndex(455, hardened: true).privateKey.bytes, UnsafePointer<uint8>.self)[0], 0, "must be zero-prefixed")
        
    }
    
    func verifyDeserialization(keychain keychain: BTCKeychain) { //Not prefixed with `test` because we don't want Xcode to automatically run this
        
        let pubchain = BTCKeychain(extendedKey: keychain.extendedPublicKey)
        let prvchain = BTCKeychain(extendedKey: keychain.extendedPrivateKey)
        
        XCTAssertNotEqual(pubchain, keychain, "Public-only chain is not equal to private chain with the same parameters")
        XCTAssertEqual(prvchain, keychain, "Private chain is equal to private chain with the same parameters")
        XCTAssertEqual(prvchain.extendedPublicKey, pubchain.extendedPublicKey, "Private and public chains should have the same extended public keys")
        
        XCTAssertEqual(prvchain.keyAtIndex(123), pubchain.keyAtIndex(123), "both chains should be able to derive the same key")
    }
    
}
