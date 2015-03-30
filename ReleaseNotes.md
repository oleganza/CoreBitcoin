CoreBitcoin Release Notes
=========================

CoreBitcoin 0.6.7
-----------------

March 30, 2015.

* Implemented RFC6979 deterministic signatures (`BTCKey`). Previously signatures were also deterministic, but non-standard.
* Implemented [Automatic Encrypted Wallet Backup scheme](https://github.com/oleganza/bitcoin-papers/blob/master/AutomaticEncryptedWalletBackups.md) (`BTCEncryptedBackup`).
* Fixed crash in BTCBitcoinURL parser on invalid amounts.

CoreBitcoin 0.6.6
-----------------

March 29, 2015.

* Added support for BIP70 Payment Requests (`BTCPaymentProtocol`). Note: X.509 signatures are [not verified on OS X](https://github.com/oleganza/CoreBitcoin/issues/42) yet.
* Implemented ECIES compatible with [Bitcore-ECIES](https://github.com/bitpay/bitcore-ecies) implementation (`BTCEncryptedMessage`).
* Merged improved Xcode SDK detection to `update_openssl.sh` by Mark Pfluger (@mpfluger).
* Added SHA512 function (`BTCSHA512`).
* Added tail mutation checks to `BTCMerkleTree`.

CoreBitcoin 0.6.5
-----------------

March 6, 2015.

* Added merkle tree implementation (`BTCMerkleTree`).

CoreBitcoin 0.6.4
-----------------

March 6, 2015.

* Optimized hash functions to efficiently work with memory-mapped `NSData` instances (`BTCSHA1`, `BTCSHA256`, `BTCSHA256Concat` etc).


CoreBitcoin 0.6.3
-----------------

March 3, 2015.

* Added Payment Request support to `BTCBitcoinURL` according to [BIP72](https://github.com/bitcoin/bips/blob/master/bip-0072.mediawiki).
* Added Payment Request support to `BTCNetwork` according to [BIP70](https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki).
* Added support for `tpub...` and `tprv...` extended key encoding on testnet (`BTCKeychain`).
* Improved format conversion API of `BTCBigNumber`.


CoreBitcoin 0.6.2
-----------------

January 30, 2015.

* Added price source API (`BTCPriceSource`) with support for Coinbase, Coindesk, Winkdex, Paymium and custom implementations.
* Added label to `BTCBitcoinURL`.
* Improved linking of inputs and outputs to their transaction instance (`BTCTransaction`).
* Added safety check to QR code scanner (`BTCQRCode`).
* Fixed rounding bug in `BTCNumberFormatter`.


CoreBitcoin 0.6.0
-----------------

December 3, 2014.

* Improved property declarations to work better with Swift.
* Streamlined hex-related methods (`BTCHexFromData`, `BTCDataFromHex` etc)


CoreBitcoin 0.5.3
-----------------

December 2, 2014.

* Block and block headers API (`BTCBlock`, `BTCBlockHeader`).
* Unified hash-to-ID conversion for transactions and blocks (`BTCHashFromID`, `BTCIDFromHash`).
* Added various optional properties to transaction, inputs and outputs (`BTCTransaction`, `BTCTransactionInput`, `BTCTransactionOutput`).
* Renamed type `BTCSatoshi` to `BTCAmount`.


CoreBitcoin 0.5.2
-----------------

November 21, 2014.

* Added WIF API and testnet support to `BTCKey`.
* Swift interoperability improvements.

CoreBitcoin 0.5.1
-----------------

November 18, 2014.

* Fixed dependencies on UIKit and AppKit.


CoreBitcoin 0.5.0
-----------------

November 18, 2014.

* First CocoaPod published.


CoreBitcoin 0.1.0
-----------------

August 11, 2013.

* First commit.








