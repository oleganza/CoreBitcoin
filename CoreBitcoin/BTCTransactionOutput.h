// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"

@class BTCScript;
@class BTCAddress;

// Transaction output (aka "tx out") is a value with rules attached in form of a script.
// To spend money one need to choose a transaction output and provide an appropriate
// input which makes the script execute with success.
@interface BTCTransactionOutput : NSObject

// Creates an output with a standard script redeeming to an address (OP_DUP OP_HASH160 <addr> OP_EQUALVERIFY OP_CHECKSIG).
// Also supports P2SH addresses.
// Address is a Base58-encoded.
+ (instancetype) outputWithValue:(BTCSatoshi)value address:(BTCAddress*)address;

// Serialized binary form of the output (payload)
@property(nonatomic, readonly) NSData* data;

// Value of output in satoshis.
@property(nonatomic) BTCSatoshi value;

// Script defining redemption rules for this output (aka scriptPubKey or pk_script)
@property(nonatomic) BTCScript* script;

// Parses tx output from a data buffer.
- (id) initWithData:(NSData*)data;

// Read tx output from the stream.
- (id) initWithStream:(NSInputStream*)stream;

// Constructs transaction output from a dictionary representation
- (id) initWithDictionary:(NSDictionary*)dictionary;

// Returns a dictionary representation suitable for encoding in JSON or Plist.
- (NSDictionary*) dictionaryRepresentation;

@end
