// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"
#import "BTCSignatureHashType.h"

static const uint32_t BTCTransactionCurrentVersion = 1;

@class BTCScript;
@class BTCTransactionInput;
@class BTCTransactionOutput;
@interface BTCTransaction : NSObject<NSCopying>

// Raw transaction hash SHA256(SHA256(payload))
@property(nonatomic, readonly) NSData* transactionHash;

// Reversed hex representation of -hash
@property(nonatomic, readonly) NSString* displayTransactionHash;

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

// Used by inputs and outputs to invalidate cached payload.
- (void) invalidatePayload;

@end
