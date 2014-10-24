// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"
#import "BTCSignatureHashType.h"

static const uint32_t BTCTransactionCurrentVersion = 1;

@class BTCScript;
@class BTCTransactionInput;
@class BTCTransactionOutput;

/*!
 * Converts string transaction ID (reversed tx hash in hex format) to transaction hash.
 */
NSData* BTCTransactionHashFromID(NSString* txid);

/*!
 * Converts hash of the transaction to its string ID (reversed tx hash in hex format).
 */
NSString* BTCTransactionIDFromHash(NSData* txhash);


/*!
 * BTCTransaction represents a Bitcoin transaction structure which contains
 * inputs, outputs and additional metadata.
 */
@interface BTCTransaction : NSObject<NSCopying>

// Raw transaction hash SHA256(SHA256(payload))
@property(nonatomic, readonly) NSData* transactionHash;

/*!
 * Hex representation of reversed `-transactionHash`.
 * This property is deprecated. Use `-transactionID` instead.
 */
@property(nonatomic, readonly) NSString* displayTransactionHash DEPRECATED_ATTRIBUTE;

/*!
 * Hex representation of reversed `-transactionHash`. Also known as "txid".
 */
@property(nonatomic, readonly) NSString* transactionID;

// Array of BTCTransactionInput objects
@property(nonatomic, readonly) NSArray* inputs;

// Array of BTCTransactionOutput objects
@property(nonatomic, readonly) NSArray* outputs;

// Binary representation on tx ready to be sent over the wire (aka "payload")
@property(nonatomic, readonly) NSData* data;

// Version. Default is 1.
@property(nonatomic, readonly) uint32_t version;

// Lock time. Either a block height or a unix timestamp.
// Default is 0.
@property(nonatomic) uint32_t lockTime; // aka "lock_time"

// Informational property, could be set by some APIs that fetch transactions.
// Note: unconfirmed transactions may be marked with -1 block height.
// Default is 0.
@property(nonatomic) NSInteger blockHeight;

// Date and time of the block if specified by the API that returns this transaction.
// Default is nil.
@property(nonatomic) NSDate* blockDate;

// Number of confirmations. Default is NSNotFound.
@property(nonatomic) NSUInteger confirmations;

// Arbitrary information attached to this instance.
// The reference is copied when this instance is copied.
// Default is nil.
@property(nonatomic) NSDictionary* userInfo;

// Parses tx from data buffer.
- (id) initWithData:(NSData*)data;

// Parses input stream (useful when parsing many transactions from a single source, e.g. a block).
- (id) initWithStream:(NSInputStream*)stream;

// Constructs transaction from its dictionary representation
- (id) initWithDictionary:(NSDictionary*)dictionary;

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation;

// Hash for signing a transaction.
// You should supply the output script of the previous transaction, desired hash type and input index in this transaction.
- (NSData*) signatureHashForScript:(BTCScript*)subscript inputIndex:(uint32_t)inputIndex hashType:(BTCSignatureHashType)hashType error:(NSError**)errorOut;

// Adds input script
- (void) addInput:(BTCTransactionInput*)input;

// Adds output script
- (void) addOutput:(BTCTransactionOutput*)output;

// Replaces inputs with an empty array.
- (void) removeAllInputs;

// Replaces outputs with an empty array.
- (void) removeAllOutputs;

// Returns YES if this txin generates new coins.
- (BOOL) isCoinbase;



// These fee methods need to be reviewed. They are for validating incoming transactions, not for
// calculating a fee for a new transaction.

// Minimum fee to relay the transaction
- (BTCSatoshi) minimumRelayFee;

// Minimum fee to send the transaction
- (BTCSatoshi) minimumSendFee;

// Minimum base fee to send a transaction.
+ (BTCSatoshi) minimumFee;
+ (void) setMinimumFee:(BTCSatoshi)fee;

// Minimum base fee to relay a transaction.
+ (BTCSatoshi) minimumRelayFee;
+ (void) setMinimumRelayFee:(BTCSatoshi)fee;


@end
