//
//  BTCMerkleTreeTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 12/6/15.
//  Copyright © 2015 Oleg Andreev. All rights reserved.
//

import XCTest

class BTCMerkleTreeTests: XCTestCase {
    
    func testAll() {
        
        do {
            let tree = BTCMerkleTree(hashes: nil)
            XCTAssertNil(tree, "Empty tree is not allowed")
        }
        
        do {
            let tree = BTCMerkleTree(hashes: [])
            XCTAssertNil(tree, "Empty tree is not allowed")
        }
        
        do {
            let a = BTCDataFromHex("5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456")
            let tree = BTCMerkleTree(hashes: [a])
            XCTAssertEqual(tree.merkleRoot, a, "One-hash tree should have the root == that hash")
        }
        
        do {
            let a = BTCDataFromHex("9c2e4d8fe97d881430de4e754b4205b9c27ce96715231cffc4337340cb110280")
            let b = BTCDataFromHex("0c08173828583fc6ecd6ecdbcca7b6939c49c242ad5107e39deb7b0a5996b903")
            let r = BTCDataFromHex("7de236613dd3d9fa1d86054a84952f1e0df2f130546b394a4d4dd7b76997f607")
            let tree = BTCMerkleTree(hashes: [a,b])
            XCTAssertEqual(tree.merkleRoot, r, "Two-hash tree should have the root == Hash(a+b)")
        }
        
        do {
            let a = BTCDataFromHex("9c2e4d8fe97d881430de4e754b4205b9c27ce96715231cffc4337340cb110280")
            let b = BTCDataFromHex("0c08173828583fc6ecd6ecdbcca7b6939c49c242ad5107e39deb7b0a5996b903")
            let c = BTCDataFromHex("80903da4e6bbdf96e8ff6fc3966b0cfd355c7e860bdd1caa8e4722d9230e40ac")
            let r = BTCDataFromHex("5b7534123197114fa7e7459075f39d89ffab74b5c3f31fad48a025b931ff5a01")
            let tree = BTCMerkleTree(hashes: [a,b,c])
            XCTAssertEqual(tree.merkleRoot, r, "Root(a,b,c) == Hash(Hash(a+b)+Hash(c+c))")
        }
    }
    
}
