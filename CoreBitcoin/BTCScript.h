// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>
#import "BTCOpcode.h"

// Hash type determines how OP_CHECKSIG hashes the transaction to create or
// verify the signature in a transaction input.
// Depending on hash type, transaction is modified in some way before its hash is computed.
// Hash type is a single byte appended to a signature in a transaction input.
typedef NS_ENUM(unsigned char, BTCSignatureHashType)
{
    // First three types are mutually exclusive (tested using "type & 0x1F").
    
    // Default. Signs all inputs and outputs.
    // Other inputs have scripts and sequences zeroed out, current input has its script
    // replaced by the previous transaction's output script (or, in case of P2SH,
    // by the signatures and the redemption script).
    // If (type & 0x1F) is not NONE or SINGLE, then this type is used.
    SIGHASH_ALL          = 1,
    
    // All outputs are removed. "I don't care where it goes as long as others pay".
    // Note: this is not safe when used with ANYONECANPAY, because then anyone who relays the transaction
    // can pick your input and use in his own transaction.
    SIGHASH_NONE         = 2,
    
    // Hash only the output with the same index as the current input.
    // Preceding outputs are "nullified", other outputs are removed.
    // Special case: if there is no matching output, hash is "010000000..." (32 bytes)
    SIGHASH_SINGLE       = 3,
    
    // Removes all inputs except for current txin before hashing.
    // This allows to sign the transaction outputs without knowing who and how adds other inputs.
    // E.g. a crowdfunding transaction with 100 BTC output can be signed independently by any number of people
    // and will become valid only when someone combines all inputs in a single transaction to make it valid.
    // Can be used together with any of the above types.
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
// Some miners do mine non-standard transactions, so it's just a matter of the higher delay.
// Today standard = isPublicKey || isHash160 || isP2SH || isStandardMultisig
- (BOOL) isStandard;

// Returns YES if the script is "<pubkey> OP_CHECKSIG".
// This is old-style script mostly replaced by a more compact "Hash160" one.
- (BOOL) isPublicKeyScript;

// Returns YES if the script is "OP_DUP OP_HASH160 <20-byte hash> OP_EQUALVERIFY OP_CHECKSIG"
// This is the most popular type that is used to pay to "addresses" (e.g. 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG).
- (BOOL) isHash160Script;

// Returns YES if the script is "... OP_HASH160 <20-byte hash> OP_EQUAL"
// This is later added script type that allows sender not to worry about complex redemption scripts (and not pay tx fees).
// Recipient must provide a serialized script which matches the hash to redeem the output.
// P2SH base58-encoded addresses start with "3" (e.g. "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8").
- (BOOL) isPayToScriptHashScript; // aka P2SH

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" where N is 3 or less.
// Scripts with up to 3 signatures are considered standard, but you can create more complex ones.
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
