//
//  BTCTransaction+Tests.m
//  CoreBitcoin
//
//  Created by Oleg Andreev on 24.01.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BTCTransaction+Tests.h"
#import "BTCBlockchainInfo.h"
#import "BTCTransactionInput.h"
#import "BTCTransactionOutput.h"
#import "BTCData.h"
#import "BTCKey.h"
#import "BTCScript.h"
#import "BTCScriptMachine.h"
#import "BTCAddress.h"
#import "BTCChainCom.h"

typedef enum : NSUInteger {
    BTCAPIChain,
    BTCAPIBlockchain,
} BTCAPI;

@implementation BTCTransaction (Tests)

+ (void) runAllTests
{
    [self testSerialization];
    [self testSpendCoins:BTCAPIChain];
    [self testSpendCoins:BTCAPIBlockchain];
}

+ (void) testSerialization
{
//    NSData* txdata = BTCDataWithHexString(@"0100000001f117de362f2d9825659b108f2dd9e6612765fab65c74a1731dae2067e58e52f301000000fd1f0100473044022026be9a250e10a3c2a1686ed485d76e9f87e66a8db022eb0f110519c7d2ec965b02203a67ae8ee70790167c0e747dfd14b833752bc3dc66816c6889cf6e9e65861781014830450221009da95c8c8c8ebae29f1fe8410f18af61e63c6d3e910b7e0ce9fda3516108c374022044b84c8053e18be1975d75c60070af6e1b45993d95c3cf3023ed4062fcd40ee2014c8b52210391e4786b4c7637c160247ad6d5702d9bb2860cbb8130d59b0fd9808a0220d50f2102e191fcff2849099988fbe1592b6788707a61401058c09ef97363c9d96c43a0cf21027f10a51295e8e96d5957f3665168426249a006e548e48cbfa5882d2bf89ab67e2103d39801bafef0cc3c211101a54a47874c0a835efa2c17c47ebbe380c803345a2354aeffffffff0254150000000000002a6a2866666430306265626332343430336464626531363632643934626633386239663463613865663935e48707000000000017a9143497d771b10abc57525200d5676a5ab7901d4a998700000000");
//    
//    BTCTransaction* tx = [[BTCTransaction alloc] initWithData:txdata];
//    
//    BTCTransactionInput* txin = tx.inputs.firstObject;
//    
//    BTCScript* script = txin.signatureScript;
//    
//    for (BTCScriptChunk* chunk in script.scriptChunks)
//    {
//        NSLog(@"chunk = %@", chunk.pushdata);
//        if (chunk.pushdata.length > 0)
//        {
//            NSData* sigWithHashtype = chunk.pushdata; //[ subdataWithRange:NSMakeRange(0, chunk.pushdata.length - 1)];
//            
//            NSError* error = nil;
//            if (![BTCKey isCanonicalSignatureWithHashType:sigWithHashtype verifyEvenS:YES error:&error])
//            {
//                NSLog(@"Chunk not canonical! %@", error);
//            }
//            else
//            {
//                NSLog(@"Chunk is canonical.");
//            }
//        }
//    }
//    
//    NSLog(@"txin = %@", txin.dictionaryRepresentation);
//    NSLog(@"tx = %@", tx.dictionaryRepresentation);



// August 27, 2014
//    NSData* txdata = BTCDataWithHexString(@"010000000470f391618f92098591f6f362ff71b2da80c53da20886d59e91f82993ef8d22ab010000006a47304402206b9ee432d0452f0f4a3459f6559072ac3e2d4c19cce28067329ccae0bd29b53002207cac7460949714e2f68f9b98cbe32bbcad66d8b959965ee6f14d845e5dd5acbd012103a61fda0fb5615942a7c22a8c9f70cb683021951fc6d0fd61596a02dfc65ff87dffffffff56dbee00e8f12a41b9c9e45f0f97f13a24cd7df7e0f3e3ee4aeec94b025ff2dd000000006b483045022100e7b15d2490c71459c659c0fb1b6b4d0a554c469619beb0a21ede91452d127d530220770218c04bca0a305a875d8d2d5bc72bd3ced7828ffff0c9916ea2c92aaba07e012103a7d7efd7238981e2103e564661ed2042055b5216bdcb006d14f7099f8f06168cffffffffe8f24ee413786c39d6ee034efed3f429645c5d6f3ce59b6d8cb4273d6f769dd7010000006b4830450221009f247975662e2f25fe693a94d224711f1c03a761c59502ef7ea83974fa2393370220533c41d16595851a033340eb3c6ee1f8d762cb3fb8ac3c86099bd387fc4c3ec3012103a7d7efd7238981e2103e564661ed2042055b5216bdcb006d14f7099f8f06168cffffffff739e752dd9f0b5a0c237d7f1c1e3e9f4acffbc2e187b1c9a7cc0c6e838e785e7010000006b483045022100c84adc31c47e6edfc785919368a6bd54baaff9052f67bea304ae685592c934650220691e7bec0f72f67e406dc915bdf346169ead144234bbeea76fa1e8359ad87c41012103a7d7efd7238981e2103e564661ed2042055b5216bdcb006d14f7099f8f06168cffffffff030100000000000000166a144b184e318c886e179b847398bd1cd0ac5f9cf2ea54150000000000001976a914ccaf5b88620ed28c1d9621fac271a928c0ac6b0c88ac838a00000000000017a9148ce0e2794443d26bd2c1dbea8157e42734667e168700000000");
//
//    BTCTransaction* tx = [[BTCTransaction alloc] initWithData:txdata];
//
//    NSLog(@"txdata size = %d", (int)txdata.length);
//    
//    int idx = 0;
//    for (BTCTransactionInput* txin in tx.inputs)
//    {
//        BTCScript* script = txin.signatureScript;
//        
//        NSLog(@"INPUT[%d] script = %@", idx, script.string);
//        
//        NSLog(@"INPUT[%d] txin = %@", idx, txin.dictionaryRepresentation);
//        
//        for (BTCScriptChunk* chunk in script.scriptChunks)
//        {
//            NSLog(@"chunk = %@", BTCHexStringFromData(chunk.pushdata));
//            if (chunk.pushdata.length > 0)
//            {
//                NSData* pushdata = chunk.pushdata; //[ subdataWithRange:NSMakeRange(0, chunk.pushdata.length - 1)];
//                
//                NSError* error = nil;
//                if (![BTCKey isCanonicalSignatureWithHashType:pushdata verifyLowerS:YES error:&error])
//                {
//                    NSString* sigFailure = error.localizedDescription;
//                    if (![BTCKey isCanonicalPublicKey:pushdata error:&error])
//                    {
//                        NSLog(@"Chunk is not canonical! 1) %@ 2) %@", sigFailure, error.localizedDescription);
//                    }
//                    else
//                    {
//                        NSLog(@"Chunk is canonical pubkey.");
//                    }
//                }
//                else
//                {
//                    NSLog(@"Chunk is canonical signature.");
//                }
//            }
//        }
//        idx++;
//    }
//    
//    idx = 0;
//    for (BTCTransactionOutput* txout in tx.outputs)
//    {
//        BTCScript* script = txout.script;
//        
//        NSLog(@"OUTPUT[%d] script = %@", idx, script.string);
//        
//        NSLog(@"OUTPUT[%d] txout = %@", idx, txout.dictionaryRepresentation);
//        
//        for (BTCScriptChunk* chunk in script.scriptChunks)
//        {
//            //NSLog(@"           chunk = %@", BTCHexStringFromData(chunk.string));
////            if (chunk.pushdata.length > 1)
////            {
////                NSData* pushdata = chunk.pushdata; //[ subdataWithRange:NSMakeRange(0, chunk.pushdata.length - 1)];
////                
////                NSError* error = nil;
////                if (![BTCKey isCanonicalSignatureWithHashType:pushdata verifyLowerS:YES error:&error])
////                {
////                    NSString* sigFailure = error.localizedDescription;
////                    if (![BTCKey isCanonicalPublicKey:pushdata error:&error])
////                    {
////                        NSLog(@"Chunk is not canonical! 1) %@ 2) %@", sigFailure, error.localizedDescription);
////                    }
////                    else
////                    {
////                        NSLog(@"Chunk is canonical pubkey.");
////                    }
////                }
////                else
////                {
////                    NSLog(@"Chunk is canonical signature.");
////                }
////            }
//        }
//        idx++;
//    }
//    
//    //NSLog(@"tx = %@", tx.dictionaryRepresentation);


    
    
}


+ (void) testSpendCoins:(BTCAPI)btcAPI
{
    // For safety I'm not putting a private key in the source code, but copy-paste here from Keychain on each run.
    printf("Private key in hex:\n");
    char str[1000] = {0};
    gets(str);
    
    NSData* privateKey = BTCDataWithHexCString(str);
    NSLog(@"Private key: %@", privateKey);
    
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKey];
    
    NSLog(@"Address: %@", key.compressedPublicKeyAddress);
    
    if (![@"1TipsuQ7CSqfQsjA9KU5jarSB1AnrVLLo" isEqualToString:key.compressedPublicKeyAddress.base58String])
    {
        NSLog(@"WARNING: incorrect private key is supplied");
        return;
    }
    
    NSError* error = nil;
    BTCTransaction* transaction = [self transactionSpendingFromPrivateKey:privateKey
                                                                       to:[BTCPublicKeyAddress addressWithBase58String:@"1A3tnautz38PZL15YWfxTeh8MtuMDhEPVB"]
                                                                   change:key.compressedPublicKeyAddress // send change to the same address
                                                                   amount:100000
                                                                      fee:0
                                                                      api:btcAPI
                                                                    error:&error];
    
    if (!transaction)
    {
        NSLog(@"Can't make a transaction: %@", error);
    }
    
    NSLog(@"transaction = %@", [transaction dictionaryRepresentation]);
    NSLog(@"transaction in hex:\n------------------\n%@\n------------------\n", BTCHexStringFromData([transaction data]));
    
    NSLog(@"Sending in 5 sec...");
    sleep(5);
    NSLog(@"Sending...");
    sleep(1);
    NSURLRequest* req = [[[BTCChainCom alloc] initWithToken:@"Free API Token form chain.com"] requestForTransactionBroadcastWithData:[transaction data]];
    NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    
    NSLog(@"Broadcast result: data = %@", data);
    NSLog(@"string = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}


// Simple method for now, fetching unspent coins on the fly
+ (BTCTransaction*) transactionSpendingFromPrivateKey:(NSData*)privateKey
                                         to:(BTCPublicKeyAddress*)destinationAddress
                                     change:(BTCPublicKeyAddress*)changeAddress
                                     amount:(BTCSatoshi)amount
                                                  fee:(BTCSatoshi)fee
                                                  api:(BTCAPI)btcApi
                                                error:(NSError**)errorOut
{
    // 1. Get a private key, destination address, change address and amount
    // 2. Get unspent outputs for that key (using both compressed and non-compressed pubkey)
    // 3. Take the smallest available outputs to combine into the inputs of new transaction
    // 4. Prepare the scripts with proper signatures for the inputs
    // 5. Broadcast the transaction
    
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKey];

    NSError* error = nil;
    NSArray* utxos = nil;
    
    switch (btcApi) {
        case BTCAPIBlockchain: {
            BTCBlockchainInfo* bci = [[BTCBlockchainInfo alloc] init];
            utxos = [bci unspentOutputsWithAddresses:@[ key.compressedPublicKeyAddress ] error:&error];
            break;
        }
        case BTCAPIChain: {
            BTCChainCom* chain = [[BTCChainCom alloc] initWithToken:@"Free API Token form chain.com"];
            utxos = [chain unspentOutputsWithAddress:key.compressedPublicKeyAddress error:&error];
            break;
        }
        default:
            break;
    }
    
    NSLog(@"UTXOs for %@: %@ %@", key.compressedPublicKeyAddress, utxos, error);

    // Can't download unspent outputs - return with error.
    if (!utxos)
    {
        *errorOut = error;
        return nil;
    }
    
    
    // Find enough outputs to spend the total amount.
    BTCSatoshi totalAmount = amount + fee;
    BTCSatoshi dustThreshold = 100000; // don't want less than 1mBTC in the change.
    
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
    utxos = [utxos sortedArrayUsingComparator:^(BTCTransactionOutput* obj1, BTCTransactionOutput* obj2) {
        if ((obj1.value - obj2.value) < 0) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    NSArray* txouts = nil;
    
    for (BTCTransactionOutput* txout in utxos)
    {
        if (txout.value > (totalAmount + dustThreshold) && txout.script.isHash160Script)
        {
            txouts = @[ txout ];
            break;
        }
    }
    
    // We support spending just one output for now.
    if (!txouts) return nil;
    
    // Create a new transaction
    BTCTransaction* tx = [[BTCTransaction alloc] init];
    
    BTCSatoshi spentCoins = 0;
    
    // Add all outputs as inputs
    for (BTCTransactionOutput* txout in txouts)
    {
        BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
        txin.previousHash = txout.transactionHash;
        txin.previousIndex = txout.index;
        [tx addInput:txin];
        
        NSLog(@"txhash: http://blockchain.info/rawtx/%@", BTCHexStringFromData(txout.transactionHash));
        NSLog(@"txhash: http://blockchain.info/rawtx/%@ (reversed)", BTCHexStringFromData(BTCReversedData(txout.transactionHash)));
        
        spentCoins += txout.value;
    }
    
    NSLog(@"Total satoshis to spend:       %lld", spentCoins);
    NSLog(@"Total satoshis to destination: %lld", amount);
    NSLog(@"Total satoshis to fee:         %lld", fee);
    NSLog(@"Total satoshis to change:      %lld", (spentCoins - (amount + fee)));
    
    // Add required outputs - payment and change
    BTCTransactionOutput* paymentOutput = [[BTCTransactionOutput alloc] initWithValue:amount address:destinationAddress];
    BTCTransactionOutput* changeOutput = [[BTCTransactionOutput alloc] initWithValue:(spentCoins - (amount + fee)) address:changeAddress];
    
    // Idea: deterministically-randomly choose which output goes first to improve privacy.
    [tx addOutput:paymentOutput];
    [tx addOutput:changeOutput];
    
    
    // Sign all inputs. We now have both inputs and outputs defined, so we can sign the transaction.
    for (int i = 0; i < txouts.count; i++)
    {
        // Normally, we have to find proper keys to sign this txin, but in this
        // example we already know that we use a single private key.
        
        BTCTransactionOutput* txout = txouts[i]; // output from a previous tx which is referenced by this txin.
        BTCTransactionInput* txin = tx.inputs[i];
        
        BTCScript* sigScript = [[BTCScript alloc] init];
        
        NSData* d1 = tx.data;
        
        BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
        
        NSData* hash = [tx signatureHashForScript:txout.script inputIndex:i hashType:hashtype error:errorOut];
        
        NSData* d2 = tx.data;
        
        NSAssert([d1 isEqual:d2], @"Transaction must not change within signatureHashForScript!");
        
        // 134675e153a5df1b8e0e0f0c45db0822f8f681a2eb83a0f3492ea8f220d4d3e4
        NSLog(@"Hash for input %d: %@", i, BTCHexStringFromData(hash));
        if (!hash)
        {
            return nil;
        }
        
        NSData* signatureForScript = [key signatureForHash:hash withHashType:hashtype];
        [sigScript appendData:signatureForScript];
        [sigScript appendData:key.publicKey];
        
        NSData* sig = [signatureForScript subdataWithRange:NSMakeRange(0, signatureForScript.length - 1)]; // trim hashtype byte to check the signature.
        NSAssert([key isValidSignature:sig hash:hash], @"Signature must be valid");
        
        txin.signatureScript = sigScript;
    }
    
    // Validate the signatures before returning for extra measure.
    
    {
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:[[(BTCTransactionOutput*)txouts[0] script] copy] error:&error];
        NSLog(@"Error: %@", error);
        NSAssert(r, @"should verify first output");
    }
    
    // Transaction is signed now, return it.


    return tx;
}



@end
