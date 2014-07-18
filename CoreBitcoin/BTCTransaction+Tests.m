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
    [self testSpendCoins:BTCAPIChain];
    [self testSpendCoins:BTCAPIBlockchain];
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
    
    NSLog(@"Address: %@", key.publicKeyAddress);
    
    if (![@"1TipsuQ7CSqfQsjA9KU5jarSB1AnrVLLo" isEqualToString:key.publicKeyAddress.base58String])
    {
        NSLog(@"WARNING: incorrect private key is supplied");
        return;
    }
    
    NSError* error = nil;
    BTCTransaction* transaction = [self transactionSpendingFromPrivateKey:privateKey
                                                                       to:[BTCPublicKeyAddress addressWithBase58String:@"1A3tnautz38PZL15YWfxTeh8MtuMDhEPVB"]
                                                                   change:key.publicKeyAddress // send change to the same address
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
            utxos = [bci unspentOutputsWithAddresses:@[ key.publicKeyAddress ] error:&error];
            break;
        }
        case BTCAPIChain: {
            BTCChainCom* chain = [[BTCChainCom alloc] initWithToken:@"Free API Token form chain.com"];
            utxos = [chain unspentOutputsWithAddress:key.publicKeyAddress error:&error];
            break;
        }
        default:
            break;
    }
    
    NSLog(@"UTXOs for %@: %@ %@", key.publicKeyAddress, utxos, error);

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
