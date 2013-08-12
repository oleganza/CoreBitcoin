// Oleg Andreev <oleganza@gmail.com>

#ifndef BitcoinWallet_BTCUnits_h
#define BitcoinWallet_BTCUnits_h

// The smallest unit in Bitcoin is 1 satoshi.
// Satoshis are 64-bit signed integers.
// The value is signed to allow special value -1 in BTCTransactionOutput.
typedef int64_t BTCSatoshi;

// 100 mln satoshis is one Bitcoin
static const BTCSatoshi BTCCoin = 100000000;

// Bitcent is 0.01 BTC
static const BTCSatoshi BTCCent = 1000000;


// Network Rules (changing these either way will result in incompatibility with other nodes)

// The maximum allowed size for a serialized block, in bytes
static const unsigned int MAX_BLOCK_SIZE = 1000000;

// The maximum allowed number of signature check operations in a block
static const unsigned int MAX_BLOCK_SIGOPS = MAX_BLOCK_SIZE/50;

// No amount larger than this (in satoshi) is valid
static const BTCSatoshi MAX_MONEY = 21000000 * BTCCoin;

// Coinbase transaction outputs can only be spent after this number of new blocks
static const int COINBASE_MATURITY = 100;

// Threshold for -[BTCTransaction lockTime]: below this value it is interpreted as block number, otherwise as UNIX timestamp. */
static const unsigned int LOCKTIME_THRESHOLD = 500000000; // Tue Nov  5 00:53:20 1985 UTC (max block number is in year ≈11521)


// Soft Rules (can bend these without becoming incompatible with everyone)

// The maximum number of entries in an 'inv' protocol message
static const unsigned int MAX_INV_SZ = 50000;

// The maximum size for mined blocks
static const unsigned int MAX_BLOCK_SIZE_GEN = MAX_BLOCK_SIZE/2;

// The maximum size for transactions we're willing to relay/mine
static const unsigned int MAX_STANDARD_TX_SIZE = MAX_BLOCK_SIZE_GEN/5;


#endif
