// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>
#import "BTCOpcode.h"

typedef NS_ENUM(unsigned char, BTCSignatureHashType)
{
    SIGHASH_ALL          = 1,
    SIGHASH_NONE         = 2,
    SIGHASH_SINGLE       = 3,
    SIGHASH_ANYONECANPAY = 0x80,
};

@interface BTCScript : NSObject

- (id) initWithData:(NSData*)data;

// Initializes script with space-separated hex-encoded commands and data.
- (id) initWithString:(NSString*)string;

// Binary representation
- (NSData*) data;

// Space-separated hex-encoded commands and data.
- (NSString*) string;

// Returns YES if the script is considered standard and can be relayed and mined normally by enough nodes.
// Non-standard scripts are still valid if appear in blocks, but default nodes and miners will reject them.
// Some miners do mine non-standard transactions, so it's just a matter of the delay and your connectivity.
- (BOOL) isStandard;

// Returns YES if the script is "<pubkey> OP_CHECKSIG" (old style)
- (BOOL) isPublicKeyScript;

// Returns YES if the script is "OP_DUP OP_HASH160 <20-byte hash> OP_EQUALVERIFY OP_CHECKSIG"
- (BOOL) isHash160Script;

// Returns YES if the script is "... OP_HASH160 <20-byte hash> OP_EQUAL"
- (BOOL) isPayToScriptHashScript; // aka P2SH

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" where N is 3 or less.
- (BOOL) isStandardMultisignatureScript;

// Standard script redeeming to a pubkey hash (OP_DUP OP_HASH160 <addr> OP_EQUALVERIFY OP_CHECKSIG)
// or a P2SH address. Address is encoded in Base58.
+ (instancetype) scriptWithAddress:(NSString*)address;

// Used by BitcoinQT within OP_CHECKSIG to not relay transactions with non-canonical form of signature or a public key.
// Normally, signatures and pubkeys are encoded in a canonical form and majority of the transactions are good.
// Unfortunately, sometimes OpenSSL segfaults on some garbage data in place of a signature or a pubkey.
// Read more on that here: https://bitcointalk.org/index.php?topic=8392.80
+ (BOOL) isCanonicalSignature:(NSData*)data;
+ (BOOL) isCanonicalPublicKey:(NSData*)data;

@end
