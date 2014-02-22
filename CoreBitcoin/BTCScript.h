// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCOpcode.h"
#import "BTCSignatureHashType.h"

@class BTCAddress;

@interface BTCScriptChunk : NSObject

// Return YES if it is not a pushdata chunk, that is a single byte opcode without data.
// -data returns nil when the value is YES.
@property(nonatomic, readonly) BOOL isOpcode;

// Opcode used in the chunk. Simply a first byte of its raw data.
@property(nonatomic, readonly) BTCOpcode opcode;

// Data being pushed. Returns nil if the opcode is not OP_PUSHDATA*.
@property(nonatomic, readonly) NSData* pushdata;

@end

@interface BTCScript : NSObject<NSCopying>

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
// or a P2SH address (OP_HASH160 <20-byte hash> OP_EQUAL).
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

// List of parsed chunks of the script (BTCScriptChunk)
- (NSArray*) scriptChunks;

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

// Returns YES if the script is "OP_HASH160 <20-byte hash> OP_EQUAL"
// This is later added script type that allows sender not to worry about complex redemption scripts (and not pay tx fees).
// Recipient must provide a serialized script which matches the hash to redeem the output.
// P2SH base58-encoded addresses start with "3" (e.g. "3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8").
- (BOOL) isPayToScriptHashScript; // aka P2SH

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" where N is up to 3.
// Scripts with up to 3 signatures are considered standard and relayed quickly, but you can create more complex ones.
- (BOOL) isStandardMultisignatureScript;

// Returns YES if the script is "<M> <pubkey1> ... <pubkeyN> <N> OP_CHECKMULTISIG" with any valid N or M.
- (BOOL) isMultisignatureScript;

// Returns YES if the script consists of push data operations only (including OP_<N>). Aka isPushOnly in BitcoinQT.
// Used in BIP16 (P2SH).
- (BOOL) isDataOnly;

// Enumerates all available operations.
//   opIndex - index of the current operation: 0..(N-1) where N is number of ops.
//   opcode - an opcode or OP_INVALIDOPCODE if pushdata is not nil.
//   pushdata - data to push. If the operation is OP_PUSHDATA<1,2,4> or OP_<N>, then this will contain data to push (opcode will be OP_INVALIDOPCODE and should be ignored)
//   stop - if set to YES, stops iterating.
- (void) enumerateOperations:(void(^)(NSUInteger opIndex, BTCOpcode opcode, NSData* pushdata, BOOL* stop))block;

// Returns BTCPublicKeyAddress or BTCScriptHashAddress if the script is a standard output script for these addresses.
// If the script is something different, returns nil.
- (BTCAddress*) standardAddress;


#pragma mark - Modification API


// Adds an opcode to the script.
- (void) appendOpcode:(BTCOpcode)opcode;

// Adds arbitrary data to the script. nil does nothing, empty data is allowed.
- (void) appendData:(NSData*)data;

// Adds opcodes and data from another script.
// If script is nil, does nothing.
- (void) appendScript:(BTCScript*)otherScript;

// Returns a sub-script from the specified index (inclusively).
// Raises an exception if index is accessed out of bounds.
// Returns an empty subscript if the index is of the last op.
- (BTCScript*) subScriptFromIndex:(NSUInteger)index;

// Returns a sub-script to the specified index (exclusively).
// Raises an exception if index is accessed out of bounds.
// Returns an empty subscript if the index is 0.
- (BTCScript*) subScriptToIndex:(NSUInteger)index;

// Removes pushdata chunks containing the specified data.
- (void) deleteOccurrencesOfData:(NSData*)data;

// Removes chunks with an opcode.
- (void) deleteOccurrencesOfOpcode:(BTCOpcode)opcode;

// Used by BitcoinQT within OP_CHECKSIG to not relay transactions with non-canonical signature or a public key.
// Normally, signatures and pubkeys are encoded in a canonical form and majority of the transactions are good.
// Unfortunately, sometimes OpenSSL segfaults on some garbage data in place of a signature or a pubkey.
// Read more on that here: https://bitcointalk.org/index.php?topic=8392.80

// Note: non-canonical pubkey could still be valid for EC internals of OpenSSL and thus accepted by Bitcoin nodes.
+ (BOOL) isCanonicalPublicKey:(NSData*)data error:(NSError**)errorOut;

// Checks if the script signature is canonical.
// The signature is assumed to include hash type (see BTCSignatureHashType).
+ (BOOL) isCanonicalSignature:(NSData*)data verifyEvenS:(BOOL)verifyEvenS error:(NSError**)errorOut;




@end
