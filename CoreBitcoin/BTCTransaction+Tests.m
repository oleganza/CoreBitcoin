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

@implementation BTCTransaction (Tests)

+ (void) runAllTests
{
    [self testSpendCoins];
}

+ (void) testSpendCoins
{
    NSData* d = BTCDataWithHexCString("0100000013fd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82230000008b483045022056c9fcf251fe4bbbf51cc91b3a57539dfea17593e652474499452f31a3481e7f022100ae87c8649d8d3342dadaf0037f5b021618f3bb21ea295a535b80757857b71fa80141047c19f94831a41d9176544a0fbb2c4a05846ee088fb2339eabe11d992d9ca6eebf7551042f54c20ba455737fa73361c71c0a2205783ce0ae054f650f0c092aabdfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf820c0000008c493046022100b6cf5c7cae26efe3f9647935d44c425e4992e06374043e753d1c59ff2d332170022100893cf5568866cbe5b74292b7f756f933e1e400704a4e74f037b1d7fd55e7d54d0141043343bee164ed1a7a838c386d013f27f972d05bb267664077e4a51cb941432a3080dd267ab8fdcd2d2f1f0acf85f9bd626adb83464a95524d2eb86db774ecac7efffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82200000008c493046022100c6489ac2fd9012ce88abc6f5a50bba30de7cd60c3e75ab4d03a51ac8d4dc9a32022100f3a749e1e00d21cad2ff79f48d2eaa18666ffae5502ec41333d16bdab2c68f8e01410448d208a641a91ab50a395842394e0fb35429351debb79745fcab6169069bcbcaa4128e6ac08230f5fe3932f6ebdd0b5564cd486a9f1d217803e796aba7e1036dfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82010000006b483045022100ed69da07e3d3a151050173875f1a049689b90d220f3b9b0ed2f2ff490b3b939802200beed202d8d24cdde593197bb10704d565150e775905a447892f864164e57f010121021be4febd588f4e57ddc647cbbd5304fc1ca873e2bf22ea1312f1db928984db4cfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82130000006b4830450221009559d4ea54a182f50a8ad7093d3b698d3bfd013a162e2f0fc68f229b6954330e02202cf5dc2c1adbd9a0699dc14641752c1068c3f661c363c352a3269e112e992c80012102a6f4cdd3b7cda4cf0d712f6eaa8ff403e5d9c38cc60091e9ae2219058121ed78fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82270000008a47304402200bae5bd3bf5f46c0b1092acaf01cdb61f163a2103fabbd38ac71733d6632b2ca02206f38589a741d0d2b762c7b9c06b51a2a79dac2c3e3712bb3c855ae2555f164d70141049731225169e6700d6eeb5461b8264e8a63be74d20dd1891a1f73a47d66676557baaee8bdd75d9e344e9868d3e4de6d7a669deb7a443f18dc6c31f4988eccae6bfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf820d0000008b4830450220138305e8c22cafc89b2d427c97c8049a9fedb3b0be2faeae976d8320f8c0ca00022100b22cad506b47111de49259a72d33bb44ce3c40d7ff55724dd9eb91de4131e4ce014104a9816010aedbde8ade794b60cf35418e38882d070dbfffb935d0fd6347275d0fdcd1e60b8319eff248ffa2c8f27a91d179576fc11613ff0f86d441e8b29360a0fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82020000008a473044022035d8e5b63aafd610c0fd254f4b48b0b424ca0ac566f777e87dc2bf6219f1017102204e50da0b15e3ac060e4600de007e370e700a3d24b1dd6c257cbfd9c46cb0518c01410434bbe22541f90b8f5415cbc05ac27871b874d4a643ae829a4d6b9c116c99a608c2838715e13d1cf5b3824437def3d9126bd0540a7c23e6fe279edfa9295431c4fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82150000008a473044022061f917f2117ded6586a9b9c1e7c5a0177941b92ba26c168f9f5dc9107ed807b10220106047beb59b90931e419bf0f5a38651f8b08200fe58723d3376fdf4cd0770f6014104a372da5c3524b39f3d240ee100a93427b1fb6f5519b04588a6f9c09887d55b6b50881589810a469393b3f2e2aff82b3afaf24dc203d34f2d5582ff571b382c3dfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82220000006b483045022024cf8d2923376208a76900d8c3db014f8316b0464dcbf77c04701ef0c1294db902210083e64ddbe0fc78f77437d2f144ccc7a2788946f7a9d3e34e80c1c41ae6b68f4d0121036c7c51373c8f81bbf1e0d88391a922d18d97f3eabbb51eb637a4d37a352ec93cfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf820e0000008c493046022100fd8bd22ba98214c4631b2b081317d86dcfa90a80b5befc46b8739e85b637fd68022100b2ee5c5291a50ee39a1c221f83b14d7d1f6861144efcff040f252c49db68c61301410498016b9f8cfc16695601021899463ccd267cae9abdc593cc058018aeeeb1df52fbc003a896ec921664828e61df3077c91f5760851751662b52f77b4e8fd12d41fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82210000008b4830450220281b58aa38344c4c7051adcf7b619a4d89b56409339c85ab32f475db56a8a185022100b12b9227cc4cf926c81dad411213c28bc876065aad1e0b4996a34fcfaf406f8c0141044926b471e745785bb8a1ea699345f8f5c9c28eda036929812cb46fe917cca22280029e6d3fb21dd749e0720b1590ca6ed05ee33fd5eb0a85786e115c9b1dd7a2fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82000000006a4730440220178050173ede81dcbf96c7d34288b0fb165984e2186cb519fe269798c2d78078022029901e348ac742505a109dbd6c41d93074b645a620c649f8594a3f49374584de01210229e8ca82c533861d5a6d7ad1fdf99b2826d7dab6a2d5edec2d3bacde17c07b9bfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf820f0000006b48304502202105e2243bceddb81741d89f1dbdbbc1782199df14b458f9b6ebd006d2875a64022100a077c29fc1b272f9361fadd0133ad141cde1469e57f855ee19d75a81f36f87aa012103c39b22ab6ecb52fb7b2c645850d08230496f6e1ddeaf292ec91c8215bcfde53cfffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf820a0000006a473044022020396e7424194ce017d22136a3601a6c68361e6c7e86a9957fbbfdd736191337022068b66427a4fe7e51ead2927f3133c737918208a58aee6c30ce0d3146902af8ef012102690bc61ec6fef6061c87d52cf1a67080784420e931a5ccf35ce9700e14da5813fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf821d0000008c493046022100ed2fd3b9dc8176b296716e259651153c23d7bbbd135ab2fadd3454a334dab23a022100b3432bc3e4d891dd201dce335d4eb37dfa22394049ace30a2a892051fb16c90001410453efd33d12166426ea46e06e3f6bb2fdea5d0388a62b9f3f2e034955dba9bc52f05959e337e0f67e06d473eba09acaa39a4509539ba0dc0e3ef66557f82e2111fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82170000006b483045022100f438b46d01346da50486e44e69f020819f68397e71d1de22de97c813f5ad9cc7022027a2b1d7692a0bf96bef3f73d48fd0877a712d2696c60d6d60e51e6c1a36b3eb0121037867eeb7e59a74a961f66ce3ce54c387ad0c8b15e95e8a4a0cbab2993dec0a2ffffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82120000006b483045022100dd7b6249c6a8114efbace53838e9295c6820174371df5da30313ea1285a10f07022015c780aec3fb57031075281cb6cded96d6119c45f9e20e9d6e38b44fd8556b3d012102a5277a30f63dac1af5413a027364b246925c4e45a1ea82bccdb2343e484b0e83fffffffffd2555336d65a6d0400f15e64bc787c8afc58aa19e510f1e310db72b8584bf82030000006a47304402202fa17a351dab9becf5ca01dc62ceca0f8fed93c8c47ca4c68b56dcc5cced1eba02205fa784e3c5be9bb0af62ca3bd623bf734f0563e4a895bf898928bec0dc3297a1012102a7157cc5c869899c6df46718eb156791d627fcd9d302688747dedcfd8084af68ffffffff1340420f00000000001976a9146f14e3afa181c8df21b5a161b1d1b8a1a100f7ed88ac40420f00000000001976a9142aafe22ef8953c143e1c702addfc2c3d1cce4dc488ace0c81000000000001976a914c7e28aba85a3ce39e3438fc884bd87fdbbd49e5288ac40420f00000000001976a9144b660ea0b8899fc583ba134d4f48c829652ad3ac88ac40420f00000000001976a914f4fa974fb6a7063b7f8d9a15f46598c063dd5aa188acaa701200000000001976a9145bdd14a04eb459fde6ceab514df7c652676f59d888ac40420f00000000001976a914e07db40f031dd03214d5ec5f126f9dda580e006e88ac40420f00000000001976a914050dbaa9fa56d7f80844e3d9c82be0849e760c5b88ace0c81000000000001976a91491b35125c1d6cd3bba47abacf60e6a4b18ae31ed88ac40420f00000000001976a9141bc999fe21b036d1a83dcc75ae8258dd6120b88b88ac40420f00000000001976a9145d84497991fb4e29affbc668f5599e1915d46bfb88ac40420f00000000001976a9142510330d5e6a7af9e8dae97f19e7cff4a4159c0188ac40420f00000000001976a9142b38314f806f9af16152f981de70434e68585b0788ac40420f00000000001976a91465b28c31a4a5a7af19e1d35010237ee4924be6c088ace0c81000000000001976a91436ee747acaa515a6b7217838d02695693aeef3a288ace0c81000000000001976a91430c914cd0b11e59a0872dcc86a8d5d1f4d3b42c388ac40420f00000000001976a9142250e11f935556bb1940a93ca0e23cfc1778758b88acc07a1000000000001976a914f57887ae2f48e39c511c2299280a7a7aad199cb588ace0c81000000000001976a9146549a73f1df8f4aa5c8df98a7f8b0003fe91c35988ac00000000");
    
    
    NSLog(@"d hash = %@", BTCHash256(d));
    
    printf("Private key in hex:\n");
    char str[1000] = {0};
    gets(str);
    
    NSData* privateKey = BTCDataWithHexCString(str);
    NSLog(@"Private key: %@", privateKey);
    
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKey];
    
    NSLog(@"Address: %@", key.publicKeyAddress);
    NSAssert([@"1TipsuQ7CSqfQsjA9KU5jarSB1AnrVLLo" isEqualToString:key.publicKeyAddress.base58String], @"Should get the address from the privkey correctly");
    
    NSError* error = nil;
    BTCTransaction* transaction = [self transactionSpendingFromPrivateKey:privateKey
                                                                       to:[BTCPublicKeyAddress addressWithBase58String:@"1TipsuQ7CSqfQsjA9KU5jarSB1AnrVLLo"]
                                                                   change:key.publicKeyAddress // send change to the same address
                                                                   amount:100000
                                                                      fee:100
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
    NSURLRequest* req = [[[BTCBlockchainInfo alloc] init] requestForTransactionBroadcastWithData:[transaction data]];
    NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    
    NSLog(@"Broadcast result: data = %@", data);
    NSLog(@"string = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}


// Simple method for now, fetching unspent coins on the fly from blockchain.info
+ (BTCTransaction*) transactionSpendingFromPrivateKey:(NSData*)privateKey
                                         to:(BTCPublicKeyAddress*)destinationAddress
                                     change:(BTCPublicKeyAddress*)changeAddress
                                     amount:(BTCSatoshi)amount
                                        fee:(BTCSatoshi)fee
                                                error:(NSError**)errorOut
{
    // 1. Get a private key, destination address, change address and amount
    // 2. Get unspent outputs for that key (using both compressed and non-compressed pubkey)
    // 3. Take the smallest available outputs to combine into the inputs of new transaction
    // 4. Prepare the scripts with proper signatures for the inputs
    // 5. Broadcast the transaction

    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKey];
    
    BTCBlockchainInfo* bci = [[BTCBlockchainInfo alloc] init];
    
    NSError* error = nil;
    NSArray* utxos = [bci unspentOutputsWithAddresses:@[ key.publicKeyAddress ] error:&error];

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
    BTCTransactionOutput* paymentOutput = [BTCTransactionOutput outputWithValue:amount address:destinationAddress];
    BTCTransactionOutput* changeOutput = [BTCTransactionOutput outputWithValue:(spentCoins - (amount + fee)) address:changeAddress];
    
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
        
        NSData* hash = [tx signatureHashForScript:txout.script inputIndex:i hashType:BTCSignatureHashTypeAll error:errorOut];
        
        NSData* d2 = tx.data;
        
        NSAssert([d1 isEqual:d2], @"Transaction must not change within signatureHashForScript!");
        
        // 134675e153a5df1b8e0e0f0c45db0822f8f681a2eb83a0f3492ea8f220d4d3e4
        NSLog(@"Hash for input %d: %@", i, BTCHexStringFromData(hash));
        if (!hash)
        {
            return nil;
        }
        
        NSData* signature = [key signatureForHash:hash];
        
        NSMutableData* signatureForScript = [signature mutableCopy];
        unsigned char hashtype = BTCSignatureHashTypeAll;
        [signatureForScript appendBytes:&hashtype length:1];
        [sigScript appendData:signatureForScript];
        [sigScript appendData:key.publicKey];
        
        NSAssert([key isValidSignature:signature hash:hash], @"Signature must be valid");
        
        txin.signatureScript = sigScript;
    }
    
    // Transaction is signed now, return it.
    
    // TODO: validate the signatures before returning for extra measure.
    
    {
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:[[(BTCTransactionOutput*)txouts[0] script] copy] error:&error];
        NSLog(@"Error: %@", error);
        NSAssert(r, @"should verify first output");
    }

    return tx;
}



@end
