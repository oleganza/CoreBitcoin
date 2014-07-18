CoreBitcoin
===========

CoreBitcoin implements Bitcoin protocol in Objective-C. It is far from being complete, but it is already a useful toolkit.

Due to "all or nothing" nature of blockchain, CoreBitcoin must perfectly match implementation of BitcoinQT ("Satoshi client"), including all its features, oddities and bugs. If you come across things that CoreBitcoin does differently from BitcoinQT, this might be a subtle bug in our implementation and should be investigated.

CoreBitcoin deliberately implements as much as possible directly in Objective-C with limited dependency on OpenSSL. This gives everyone an opportunity to learn Bitcoin on a clean codebase and enables all Mac and iOS developers to extend and improve Bitcoin protocol.

Note that "Bitcoin Core" (previously known as BitcoinQT or "Satoshi client") is a completely different project.


Features
--------

- EC keys and signatures for binary and Bitcoin text messages.
- Addresses
- Transactions
- Scripts
- Blockchain.info and Chain.com API to fetch unspent outputs and broadcast transactions.
- BIP32 hierarchical deterministic wallets (BTCKeychain).
- Blind signatures implementation.
- Math on elliptic curves: big numbers, curve points, conversion between keys, numbers and points.
- Various cryptographic primitives like hash functions and AES encryption.

Not done yet:

- Blocks and block headers.
- P2P communication with other nodes.
- Full blockchain verification procedure and storage.
- Importing BitcoinQT, Electrum and Blockchain.info wallets.
- SPV mode.
- Various BIPs (BIP39, BIP44, BIP70 etc.)

The goal is to implement everything useful related to Bitcoin and organize it nicely in a single powerful library. Ladies and gentlemen, send me your pull requests.


Starting points
---------------

To encode/decode addresses, P2SH and private keys in sipa format see BTCAddress.

To perform cryptographic operations, use BTCKey, BTCBigNumber and BTCCurvePoint. BTCKeychain implements BIP32 (hierarchical deterministic wallet).

To fetch unspent coins and broadcast transactions use one of the 3rd party APIs: BTCBlockchainInfo (blockchain.info) or BTCChainCom (chain.com).

For full wallet workflow see BTCTransaction+Tests.m (fetch unspent outputs, compose a transaction, sign inputs, verify and broadcast).

For multisignature scripts usage see BTCScript+Tests.m: compose and unlock multisig output.

All other files with "+Tests" in their name are worth checking out as they contain useful sample code.


Using CoreBitcoin CocoaPod (recommended)
----------------------------------------

Add this to your Podfile:

    pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec'

Run in Terminal:

    $ pod install

Include headers:

	#import <CoreBitcoin/CoreBitcoin.h>

If you'd like to use categories, include different header:

	#import <CoreBitcoin/CoreBitcoin+Categories.h>


Using CoreBitcoin.framework
---------------------------

Clone this repository and build all libraries:

	$ ./update_openssl.sh
	$ ./build_libraries.sh

Copy iOS or OS X framework located in binaries/iOS or binaries/OSX to your project.

Include headers:

	#import <CoreBitcoin/CoreBitcoin.h>
	
There are also raw universal libraries (.a) with headers located in binaries/include, if you happen to need them for some reason. Frameworks and binary libraries have OpenSSL built-in. If you have different version of OpenSSL in your project, consider using CocoaPods or raw sources of CoreBitcoin.


Bounties
--------

- [done] 0.1 BTC for a CocoaPod. OpenSSL should be bundled automatically (or as a dependency). [@oleganza]
- [done] 0.5 BTC for building CoreBitcoin.a with headers and support for x86_64, armv7, armv7s, armv64. OpenSSL should be bundled inside. [@oleganza]
- [done] extra 0.5 BTC for building CoreBitcoin.framework with support for x86_64, armv7, armv7s, armv64. OpenSSL should be bundled inside. It's okay to have one framework for OS X and one for iOS. [@oleganza]
- 0.25 BTC for P2P communication

To add your own bounty, add a line here (or edit an existing one), make a pull request and donate to the address below. Your donation will be reserved for that bounty only. I will contact you to check if the implementation is acceptable before paying out.


Swift
-----

We love Swift and design the code to be compatible with Swift. That means using modern enums, favoring initializers over factory methods, avoiding obscure C features etc. You are welcome to try using CoreBitcoin from Swift, please file bugs if you have problems.

Swift is awesome to write crypto in it (due to explicit optionals, generics and first-class structs) and we would love to rewrite the entire CoreBitcoin and even relevant portions of OpenSSL in it. Unfortunately, for a year or two it's just out of the question due to instability. And then, using Swift-only features on the API level would mean that Objective-C code wouldn't be able to use CoreBitcoin. Given that, in the medium term we will focus solely on Objective-C implementation compatible with Swift. When everyone jumps exclusively on Swift, we'll make a complete rewrite.


Contribute
----------

Feel free to open issues, drop us pull requests or contact us to discuss how to do things.

Follow existing code style and use 4 spaces instead of tabs. Methods have opening braces on a new line. There's no line width limit.

Email: [oleganza@gmail.com](mailto:oleganza@gmail.com)

Twitter: [@oleganza](http://twitter.com/oleganza)


Donate
------

Please send your donations here: 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG.

All funds will be used only for bounties.

You can also donate to a specific bounty. The amount will be reserved for that bounty and listed above. Contact Oleg to arrange that.


License
-------

Released under the [WTFPL](http://www.wtfpl.net) except for OpenSSL. No contributor to CoreBitcoin will ever be able to drag you in court if you do not mention CoreBitcoin in your legalese. Crediting authors or contributing improvements is voluntary and would be appreciated. Have a nice day.


