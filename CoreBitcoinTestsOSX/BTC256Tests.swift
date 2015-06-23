//
//  BTC256Tests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 6/23/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTC256Tests: XCTestCase {
    
    func testBTC256ChunkSize() {
        XCTAssertEqual(sizeof(BTC160), 20, "160-bit struct should by 160 bit long")
        XCTAssertEqual(sizeof(BTC256), 32, "256-bit struct should by 256 bit long")
        XCTAssertEqual(sizeof(BTC512), 64, "512-bit struct should by 512 bit long")
    }
    
    func testBTC256Null() {
        XCTAssertEqual(NSStringFromBTC160(BTC160Null), "82963d5edd842f1e6bd2b6bc2e9a97a40a7d8652", "null hash should be correct")
        XCTAssertEqual(NSStringFromBTC256(BTC256Null), "d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e", "null hash should be correct")
        XCTAssertEqual(NSStringFromBTC512(BTC512Null), "62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f0363e01b5d7a53c4a2e5a76d283f3e4a04d28ab54849c6e3e874ca31128bcb759e1", "null hash should be correct")
    }
    
    func testBTC256One() {
        var one = BTC256Zero
        one.words64 = (1, one.words64.1, one.words64.2, one.words64.3)
        XCTAssertEqual(NSStringFromBTC256(one), "0100000000000000000000000000000000000000000000000000000000000000", "")
    }
    
    func testBTC256Equal() {
        XCTAssert(BTC256Equal(BTC256Null, BTC256Null), "equal")
        XCTAssert(BTC256Equal(BTC256Zero, BTC256Zero), "equal")
        XCTAssert(BTC256Equal(BTC256Max,  BTC256Max),  "equal")
        
        XCTAssert(!BTC256Equal(BTC256Zero, BTC256Null), "not equal")
        XCTAssert(!BTC256Equal(BTC256Zero, BTC256Max),  "not equal")
        XCTAssert(!BTC256Equal(BTC256Max,  BTC256Null), "not equal")
    }
    
    func testBTC256Compare() {
        XCTAssert(BTC256Compare(BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
        BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSComparisonResult.OrderedSame, "ordered same")
        
        XCTAssert(BTC256Compare(BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f035"),
        BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSComparisonResult.OrderedAscending, "ordered asc")
        
        XCTAssert(BTC256Compare(BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f037"),
        BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSComparisonResult.OrderedDescending, "ordered asc")
        
        XCTAssert(BTC256Compare(BTC256FromNSString("61ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
        BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSComparisonResult.OrderedAscending, "ordered same")
        
        XCTAssert(BTC256Compare(BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
        BTC256FromNSString("61ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSComparisonResult.OrderedDescending, "ordered same")
    
    }
    
    func testBTC256Invers() {
        let chunk = BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")
        let chunk2 = BTC256Inverse(chunk)
        
        XCTAssert(!BTC256Equal(chunk, chunk2), "not equal")
        XCTAssert(BTC256Equal(chunk, BTC256Inverse(chunk2)), "equal")
        
        XCTAssertEqual(chunk2.words64.0, ~chunk.words64.0, "bytes are inversed")
        XCTAssertEqual(chunk2.words64.1, ~chunk.words64.1, "bytes are inversed")
        XCTAssertEqual(chunk2.words64.2, ~chunk.words64.2, "bytes are inversed")
        XCTAssertEqual(chunk2.words64.3, ~chunk.words64.3, "bytes are inversed")
        
        XCTAssert(BTC256Equal(BTC256Zero, BTC256AND(chunk, chunk2)), "(a & ~a) == 000000...")
        XCTAssert(BTC256Equal(BTC256Max, BTC256OR(chunk, chunk2)), "(a | ~a) == 111111...")
        XCTAssert(BTC256Equal(BTC256Max, BTC256XOR(chunk, chunk2)), "(a ^ ~a) == 111111...")
    }
    
    func testBTC256Swap() {
        let chunk = BTC256FromNSString("62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")
        let chunk2 = BTC256Swap(chunk)
        XCTAssertEqual(BTCReversedData(NSDataFromBTC256(chunk)), NSDataFromBTC256(chunk2), "swap should reverse all bytes")

        XCTAssertEqual(chunk2.words64.0, _OSSwapInt64(chunk.words64.3), "swap should reverse all bytes")
        XCTAssertEqual(chunk2.words64.1, _OSSwapInt64(chunk.words64.2), "swap should reverse all bytes")
        XCTAssertEqual(chunk2.words64.2, _OSSwapInt64(chunk.words64.1), "swap should reverse all bytes")
        XCTAssertEqual(chunk2.words64.3, _OSSwapInt64(chunk.words64.0), "swap should reverse all bytes")

    }
    
    func testBTC256AND() {
        XCTAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Max),  BTC256Max),  "1 & 1 == 1")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Zero), BTC256Zero), "1 & 0 == 0")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Zero, BTC256Max),  BTC256Zero), "0 & 1 == 0")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Zero, BTC256Null), BTC256Zero), "0 & x == 0")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Null, BTC256Zero), BTC256Zero), "x & 0 == 0")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Null), BTC256Null), "1 & x == x")
        XCTAssert(BTC256Equal(BTC256AND(BTC256Null, BTC256Max),  BTC256Null), "x & 1 == x")
    }
    
    func testBTC256OR() {
        XCTAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Max),  BTC256Max),  "1 | 1 == 1")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Zero), BTC256Max),  "1 | 0 == 1")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Zero, BTC256Max),  BTC256Max),  "0 | 1 == 1")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Zero, BTC256Null), BTC256Null), "0 | x == x")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Null, BTC256Zero), BTC256Null), "x | 0 == x")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Null), BTC256Max),  "1 | x == 1")
        XCTAssert(BTC256Equal(BTC256OR(BTC256Null, BTC256Max),  BTC256Max),  "x | 1 == 1")
    }
    
    func testBTC256XOR() {
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Max),  BTC256Zero),  "1 ^ 1 == 0")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Zero), BTC256Max),  "1 ^ 0 == 1")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Zero, BTC256Max),  BTC256Max),  "0 ^ 1 == 1")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Zero, BTC256Null), BTC256Null), "0 ^ x == x")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Null, BTC256Zero), BTC256Null), "x ^ 0 == x")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Null), BTC256Inverse(BTC256Null)),  "1 ^ x == ~x")
        XCTAssert(BTC256Equal(BTC256XOR(BTC256Null, BTC256Max),  BTC256Inverse(BTC256Null)),  "x ^ 1 == ~x")
    }
    
    func testBTC256Concat() {
        let concat = BTC512Concat(BTC256Null, BTC256Max)
        XCTAssertEqual(NSStringFromBTC512(concat), "d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e"+"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", "should concatenate properly")
        
        let concat2 = BTC512Concat(BTC256Max, BTC256Null)
        XCTAssertEqual(NSStringFromBTC512(concat2), "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"+"d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e", "should concatenate properly")
    }
    
    func testBTC256ConvertToData() {
        //TODO...
    }
    
    func testBTC256ConvertToString() {
        let chunk = BTC256FromNSString("000095409e215952" +
                                       "85b6b5982285aabf" +
                                       "a5999a5e845f44c3" +
                                       "b9411d5d1007a1")
        XCTAssert(BTC256Equal(chunk, BTC256Null), "too short string => null")
        
        let chunk2 = BTC256FromNSString("000095409e215952" +
                                        "85b6b5982285aabf" +
                                        "a5999a5e845f44c3" +
                                        "b9411d5d1007a1b166")
        XCTAssertEqual(chunk2.words64.0, _OSSwapInt64(0x000095409e215952), "parse correctly")
        XCTAssertEqual(chunk2.words64.1, _OSSwapInt64(0x85b6b5982285aabf), "parse correctly")
        XCTAssertEqual(chunk2.words64.2, _OSSwapInt64(0xa5999a5e845f44c3), "parse correctly")
        XCTAssertEqual(chunk2.words64.3, _OSSwapInt64(0xb9411d5d1007a1b1), "parse correctly")
        
        XCTAssertEqual(NSStringFromBTC256(chunk2), "000095409e215952" +
                                                   "85b6b5982285aabf" +
                                                   "a5999a5e845f44c3" +
                                                   "b9411d5d1007a1b1", "should serialize to the same string")
        
    }
}
