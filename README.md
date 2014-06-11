CoreBitcoin
===========

CoreBitcoin is an implementation of Bitcoin protocol in Objective-C. It's already a useful toolkit, but does not yet provide full node implementation.

Due to "all or nothing" nature of blockchain, CoreBitcoin must perfectly match implementation of BitcoinQT ("Satoshi client"), including all its features, oddities and bugs. If you come across things that CoreBitcoin does differently from BitcoinQT, this might be a subtle bug in our implementation and should be investigated.

Features
--------

- EC keys and signatures for binary and Bitcoin text messages.
- Addresses
- Transactions
- Scripts
- Blockchain.info API to fetch unspent outputs and send signed transactions
- BIP32 hierarchical deterministic wallets
- Math on elliptic curves: big numbers, curve points, conversion between keys, numbers and points.
- Various cryptographic primitives: hash functions, ECC, encryption.

Still missing:

- Blocks
- P2P communication with other nodes
- Importing BitcoinQT, Electrum and Blockchain.info wallets


Using CoreBitcoin CocoaPod
--------------------------

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


Contribute
----------

Feel free to open issues, drop me pull requests or contact me to discuss how to do things.

Code style: follow existing style and use 4 spaces instead of tabs. There's no line width limit.

Email: [oleganza@gmail.com](mailto:oleganza@gmail.com)

Twitter: [@oleganza](http://twitter.com/oleganza)


Donate
------

Please send your donations here: 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG.

All funds will be used only for bounties to fix stuff.

You can also donate for a specific bounty. The amount will be reserved for that bounty and listed above.


License
-------

Released under the [WTFPL](http://www.wtfpl.net) except for OpenSSL. It is not MIT License because no one reads your legalese anyway and it only adds burden. Instead, you are encouraged to donate money for development and use sources how you like.

