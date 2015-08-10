//
//  BTCTransactionTests.swift
//  CoreBitcoin
//
//  Created by Robert S Mozayeni on 8/10/15.
//  Copyright (c) 2015 Oleg Andreev. All rights reserved.
//

import Cocoa
import XCTest

class BTCTransactionTests: XCTestCase {
    
    enum BTCAPI: UInt {
        case Chain
        case Blockchain
    }
    
    
    func testFees() {
        
        let TransactionDefaultFeeRate: BTCAmount = 10000 //Because Xcode is having trouble with BTCTransactionDefaultFeeRate
        
        XCTAssertEqual(BTCTransaction().estimatedFee, TransactionDefaultFeeRate, "smallest tx must have a fee == default fee rate")
        XCTAssertEqual(BTCTransaction().estimatedFeeWithRate(12345), 12345, "smallest tx must have a fee == fee rate")
        XCTAssertEqual(BTCTransaction().estimatedFeeWithRate(0), 0, "zero fee rate should always yield zero fee")
        
        let tx = BTCTransaction()
        for i in 0 ..< 10 {
            let txin = BTCTransactionInput()
            txin.previousIndex = 0
            txin.signatureScript = BTCScript()
            txin.signatureScript.appendData(BTCDataWithUTF8CString("A very long text simulating a signature script inside the transaction input."))
            tx.addInput(txin)
        }
        
        XCTAssertEqual(tx.data.length, 1200, "Must be over 1K")
        XCTAssertEqual(tx.estimatedFee, 2 * TransactionDefaultFeeRate, "Must have double the fee rate if there is more than 1000 bytes")
        XCTAssertEqual(tx.estimatedFeeWithRate(123), 246, "Must have double the fee rate if there is more than 1000 bytes")
        XCTAssertEqual(tx.estimatedFeeWithRate(0), 0, "Must have zero fee for zero rate.")
    }
    
    func transactionSpendingFromPrivateKey(privateKey: NSData, destinationAddress: BTCPublicKeyAddress, changeAddress: BTCPublicKeyAddress, amount: BTCAmount, fee: BTCAmount, api: BTCAPI) -> (BTCTransaction?, NSError?) {
        
        // 1. Get a private key, destination address, change address and amount
        // 2. Get unspent outputs for that key (using both compressed and non-compressed pubkey)
        // 3. Take the smallest available outputs to combine into the inputs of new transaction
        // 4. Prepare the scripts with proper signatures for the inputs
        // 5. Broadcast the transaction
        
        let key = BTCKey(privateKey: privateKey)
        
        var errorOut: NSError?
        
        var error: NSError?
        var utxos: [BTCTransactionOutput]?
        
        switch api {
        case .Blockchain:
            let bci = BTCBlockchainInfo()
            utxos = bci.unspentOutputsWithAddresses([key.compressedPublicKeyAddress], error: &error) as! [BTCTransactionOutput]?
        case .Chain:
            let chain = BTCChainCom(token: "Free API Token form chain.com")
            utxos = chain.unspentOutputsWithAddress(key.compressedPublicKeyAddress, error: &error) as! [BTCTransactionOutput]?
        }
        
        
        println("UTXOs for \(key.compressedPublicKeyAddress): \(utxos) \(error)")
        
        // Can't download unspent outputs - return with error.
        if utxos == nil { //Good place for a guard in Swift 2
            errorOut = error
            return (nil, errorOut)
        }
        
        // Find enough outputs to spend the total amount.
        let totalAmount = amount + fee
        let dustThreshold = 100000  // don't want less than 1mBTC in the change.
        
        // We need to avoid situation when change is very small. In such case we should leave smallest coin alone and add some bigger one.
        // Ideally, we need to maintain more-or-less binary distribution of coins: having 0.001, 0.002, 0.004, 0.008, 0.016, 0.032, 0.064, 0.128, 0.256, 0.512, 1.024 etc.
        // Another option is to spend a coin which is 2x bigger than amount to be spent.
        // Desire to maintain a certain distribution of change to closely match the spending pattern is the best strategy.
        // Yet another strategy is to minimize both current and future spending fees. Thus, keeping number of outputs low and change sum above "dust" threshold.
        
        // For this test we'll just choose the smallest output.
        
        // 1. Sort outputs by amount
        // 2. Find the output that is bigger than what we need and closer to 2x the amount.
        // 3. If not, find a bigger one which covers the amount + reasonably big change (to avoid dust), but as small as possible.
        // 4. If not, find a combination of two outputs closer to 2x amount from the top.
        // 5. If not, find a combination of two outputs closer to 1x amount with enough change.
        // 6. If not, find a combination of three outputs.
        // Maybe Monte Carlo method is a way to go.
        
        
        // Another way:
        // Find the minimum number of txouts by scanning from the biggest one.
        // Find the maximum number of txouts by scanning from the lowest one.
        // Scan with a minimum window increasing it if needed if no good enough change can be found.
        // Yet another option: finding combinations so the below-the-dust change can go to miners.
        
        
        // Sort utxo in order of
        utxos?.sort { $0.value() < $1.value() }
        
        var txouts: [BTCTransactionOutput]!
        
        for txout in utxos! {
            if txout.value() > (totalAmount + dustThreshold) && txout.script.isPayToPublicKeyHashScript {
                txouts = [txout]
                break
            }
        }
        
        // We support spending just one output for now.
        if (txouts == nil) { return (nil, nil) } //Another good place for a guard
        
        // Create a new transaction
        let tx = BTCTransaction()
        
        var spentCoins = BTCAmount(0)
        
        // Add all outputs as inputs
        for txout in txouts {
            let txin = BTCTransactionInput()
            txin.previousHash = txout.transactionHash
            txin.previousIndex = txout.index
            tx.addInput(txin)
            
            println("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(txout.transactionHash))")
            println("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(BTCReversedData(txout.transactionHash))) (reversed)")
            
            spentCoins += txout.value()
        }
        
        println(String(format: "Total satoshis to spend:       %lld", spentCoins))
        println(String(format: "Total satoshis to destination: %lld", amount))
        println(String(format: "Total satoshis to fee:         %lld", fee))
        println(String(format: "Total satoshis to change:      %lld", spentCoins - (amount + fee)))
        
        // Add required outputs - payment and change
        let paymentOutput = BTCTransactionOutput(value: amount, address: destinationAddress)
        let changeOutput = BTCTransactionOutput(value: (spentCoins - (amount + fee)), address: changeAddress)
        
        // Idea: deterministically-randomly choose which output goes first to improve privacy.
        tx.addOutput(paymentOutput)
        tx.addOutput(changeOutput)
        
        for i in 0 ..< txouts.count {
            // Normally, we have to find proper keys to sign this txin, but in this
            // example we already know that we use a single private key.
            
            let txout = txouts[i] // output from a previous tx which is referenced by this txin.
            let txin = tx.inputs[i] as! BTCTransactionInput
            
            let sigScript = BTCScript()
            
            let d1 = tx.data
            
            let hashType = BTCSignatureHashType.SIGHASH_ALL
            
            var err: NSError?
            let hash = tx.signatureHashForScript(txout.script, inputIndex: UInt32(i), hashType: hashType, error: &errorOut)
            
            let d2 = tx.data
            
            XCTAssertEqual(d1, d2, "Transaction must not change within signatureHashForScript!")
            
            // 134675e153a5df1b8e0e0f0c45db0822f8f681a2eb83a0f3492ea8f220d4d3e4
            println(String(format: "Hash for input %d: \(BTCHexFromData(hash))", i))
            if hash == nil { return (nil, err) } //Another good place for a guard
            
            let signatureForScript = key.signatureForHash(hash, hashType: hashType)
            sigScript.appendData(signatureForScript)
            sigScript.appendData(key.publicKey)
            
            let sig = signatureForScript.subdataWithRange(NSRange(location: 0, length: signatureForScript.length - 1))  // trim hashtype byte to check the signature.
            XCTAssertTrue(key.isValidSignature(sig, hash: hash), "Signature must be valid")
            
            txin.signatureScript = sigScript
        }
        
        // Validate the signatures before returning for extra measure.
        
        do {
            let sm = BTCScriptMachine(transaction: tx, inputIndex: 0)
            var error: NSError?
            let r = sm.verifyWithOutputScript((txouts.first as BTCTransactionOutput!).script.copy() as! BTCScript, error: &error)
            println("Error: \(error)")
            XCTAssertTrue(r, "should verify first output")
            
        } while false //this last while can be removed in Swift 2. Just using `do` for scoping, as Swift 2 does.
        
        // Transaction is signed now, return it.
        
        return (tx, errorOut)
    }
    
    
    func spendCoinTestWithAPI(api: BTCAPI) { //Not prefixed with `test` because we don't want Xcode to try and call it
        let privStr = ""
        let str = UnsafeMutablePointer<Int8>((privStr as NSString).UTF8String)
        gets(str)
        
        let privateKey = BTCDataWithHexCString(str)
        println("Private key: \(privateKey)")
        
        let key = BTCKey(privateKey: privateKey)
        
        println("Address: \(key.compressedPublicKeyAddress)")
        
        XCTAssertEqual("1TipsuQ7CSqfQsjA9KU5jarSB1AnrVLLo", key.compressedPublicKeyAddress.string, "WARNING: incorrect private key is supplied")
        
        
        let (transaction, error) = self.transactionSpendingFromPrivateKey(privateKey, destinationAddress: BTCPublicKeyAddress(string: "1A3tnautz38PZL15YWfxTeh8MtuMDhEPVB")!, changeAddress: key.compressedPublicKeyAddress, amount: 100000, fee: 0, api: api)
        
        XCTAssertNotNil(transaction, "Can't make a transaction: \(error)")
        
        println("transaction = \(transaction?.dictionary)")
        println("transaction in hex:\n------------------\n\(BTCHexFromData(transaction?.data))\n------------------\n")
        
        println("Sending in 5 sec...")
        sleep(5)
        println("Sending...")
        sleep(1)
        
        let req = BTCChainCom(token: "Free API Token form chain.com").requestForTransactionBroadcastWithData(transaction!.data)
        let data = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil)
        
        println("Broadcast result: data = \(data)")
        println("string = \(NSString(data: data!, encoding: NSUTF8StringEncoding))")
        
    }
    
    func testSpendCoins() {
        spendCoinTestWithAPI(.Chain)
        spendCoinTestWithAPI(.Blockchain)
    }

}

