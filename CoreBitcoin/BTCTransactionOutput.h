// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"

@class BTCScript;
@class BTCAddress;
@class BTCTransaction;

static uint32_t const BTCTransactionOutputIndexUnknown = 0xffffffff;

// Transaction output (aka "tx out") is a value with rules attached in form of a script.
// To spend money one need to choose a transaction output and provide an appropriate
// input which makes the script execute with success.
@interface BTCTransactionOutput : NSObject<NSCopying>

// Serialized binary form of the output (payload)
@property(nonatomic, readonly) NSData* data;

// Value of output in satoshis.
@property(nonatomic) BTCSatoshi value;

// Script defining redemption rules for this output (aka scriptPubKey or pk_script)
@property(nonatomic) BTCScript* script;

// Reference to owning transaction. Set on [tx addOutput:...] and reset to nil on [tx removeAllOutputs].
@property(weak, nonatomic) BTCTransaction* transaction;

// These are informational properties updated in certain context.
// E.g. when loading unspent outputs from blockchain.info (BTCBlockchainInfo), all these properties will be set.
// index and transactionHash are kept up to date when output is added/removed from the transaction.

// Index of this output in its transaction. Default is BTCTransactionOutputIndexUnknown
@property(nonatomic) uint32_t index;

// Number of confirmations. Default is NSNotFound.
@property(nonatomic) NSUInteger confirmations;

// Identifier of the transaction. Default is nil.
@property(nonatomic) NSData* transactionHash;

// Parses tx output from a data buffer.
- (id) initWithData:(NSData*)data;

// Reads tx output from the stream.
- (id) initWithStream:(NSInputStream*)stream;

// Makes tx output from a dictionary representation
- (id) initWithDictionary:(NSDictionary*)dictionary;

// Makes tx output with a certain amount of coins on the output.
- (id) initWithValue:(BTCSatoshi)value;

// Makes tx output with a standard script redeeming to an address (pubkey hash or P2SH).
- (id) initWithValue:(BTCSatoshi)value address:(BTCAddress*)address;

// Makes tx output with a given script.
- (id) initWithValue:(BTCSatoshi)value script:(BTCScript*)script;

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation;

@end
