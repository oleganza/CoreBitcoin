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

@class BTCAddress;
@interface BTCScript : NSObject

// Initialized an empty script.
- (id) init;

// Inits with binary data. If data is empty or nil, empty script is initialized.
// If data is invalid script (e.g. a length prefix is not followed by matching amount of data), nil is returned.
- (id) initWithData:(NSData*)data;

// Initializes script with space-separated hex-encoded commands and data.
// If script is invalid, nil is returned.
// Note: the string may be ambigious. You are safe if it does not have 3..5-byte data or integers.
- (id) initWithString:(NSString*)string;

// Standard script redeeming to a pubkey hash (OP_DUP OP_HASH160 <addr> OP_EQUALVERIFY OP_CHECKSIG)
// or a P2SH address.
- (id) initWithAddress:(BTCAddress*)address;

// Initializes a multisignature script "OP_<M> <pubkey1> ... <pubkeyN> OP_<N> OP_CHECKMULTISIG"
// N must be >= M, M and N should be from 1 to 16.
// If you need a more customized transaction with OP_CHECKMULTISIG, create it using other methods.
- (id) initWithPublicKeys:(NSArray*)publicKeys signaturesRequired:(NSUInteger)signaturesRequired;


// Binary representation
- (NSData*) data;

// Space-separated hex-encoded commands and data.
// Small integers (data fitting in 4 bytes) incuding OP_<N> are represented with decimal digits.
// Other opcodes are represented with their names.
// Other data is hex-encoded.
// This representation is inherently ambiguous, so don't use it for anything serious.
- (NSString*) string;

// Returns YES if the script is considered standard and can be relayed and mined normally by enough nodes.
// Non-standard scripts are still valid if appear in blocks, but default nodes and miners will reject them.
// Some miners do mine non-standard transactions, so it's just a matter of the higher delay.
// Today standard = isPublicKey || isHash160 || isP2SH || isStandardMultisig
- (BOOL) isStandard;

// Returns YES if the script is "<pubkey> OP_CHECKSIG".
// This is old-style script mostly replaced by a more compact "Hash160" one.
// It is used for "send to IP" transactions. You connect to an IP address, receive
// a pubkey and send money to this key. However, this method is almost never used for security reasons.
- (BOOL) isPublicKeyScript;

// Returns YES if the script is "OP_DUP OP_HASH160 <20-byte hash> OP_EQUALVERIFY OP_CHECKSIG"
// This is the most popular type that is used to pay to "addresses" (e.g. 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG).
- (BOOL) isHash160Script;

// Returns YES if the script is "... OP_HASH160 <20-byte hash> OP_EQUAL"
// This is later added script type that allows sender not to worry about complex redemption scripts (and not pay tx fees).
// Recipient must provide a serialized script which matches the hash to redeem the output.
// P2SH base58-encoded addresses start with "3" (e.g. "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8").
- (BOOL) isPayToScriptHashScript; // aka P2SH

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" where N is up to 3.
// Scripts with up to 3 signatures are considered standard and relayed quickly, but you can create more complex ones.
- (BOOL) isStandardMultisignatureScript;

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" with any valid N or M.
- (BOOL) isMultisignatureScript;



// Used by BitcoinQT within OP_CHECKSIG to not relay transactions with non-canonical form of signature or a public key.
// Normally, signatures and pubkeys are encoded in a canonical form and majority of the transactions are good.
// Unfortunately, sometimes OpenSSL segfaults on some garbage data in place of a signature or a pubkey.
// Read more on that here: https://bitcointalk.org/index.php?topic=8392.80

// Note: non-canonical pubkey could still be valid for EC internals of OpenSSL and thus accepted by Bitcoin nodes.
+ (BOOL) isCanonicalPublicKey:(NSData*)data error:(NSError**)errorOut;

// Checks if the script signature is canonical.
// The signature is assumed to include hash type (see BTCSignatureHashType).
+ (BOOL) isCanonicalSignature:(NSData*)data verifyEvenS:(BOOL)verifyEvenS error:(NSError**)errorOut;

@end
