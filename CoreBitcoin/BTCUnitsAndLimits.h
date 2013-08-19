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
static const unsigned int BTC_MAX_BLOCK_SIZE = 1000000;

// The maximum allowed number of signature check operations in a block
static const unsigned int BTC_MAX_BLOCK_SIGOPS = BTC_MAX_BLOCK_SIZE/50;

// No amount larger than this (in satoshi) is valid
static const BTCSatoshi BTC_MAX_MONEY = 21000000 * BTCCoin;

// Coinbase transaction outputs can only be spent after this number of new blocks
static const int BTC_COINBASE_MATURITY = 100;

// Threshold for -[BTCTransaction lockTime]: below this value it is interpreted as block number, otherwise as UNIX timestamp. */
static const unsigned int BTC_LOCKTIME_THRESHOLD = 500000000; // Tue Nov  5 00:53:20 1985 UTC (max block number is in year ≈11521)

// P2SH BIP16 didn't become active until Apr 1 2012. All txs before this timestamp should not be verified with P2SH rule.
static const uint32_t BTC_BIP16_TIMESTAMP = 1333238400;

// Scripts longer than 10000 bytes are invalid.
static const NSUInteger BTC_SCRIPT_MAX_SIZE = 10000;


// Soft Rules (can bend these without becoming incompatible with everyone)

// The maximum number of entries in an 'inv' protocol message
static const unsigned int BTC_MAX_INV_SZ = 50000;

// The maximum size for mined blocks
static const unsigned int BTC_MAX_BLOCK_SIZE_GEN = BTC_MAX_BLOCK_SIZE/2;

// The maximum size for transactions we're willing to relay/mine
static const unsigned int BTC_MAX_STANDARD_TX_SIZE = BTC_MAX_BLOCK_SIZE_GEN/5;


#endif
