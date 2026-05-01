# CoreBitcoin

CoreBitcoin implements Bitcoin protocol in Objective-C and provides many additional APIs to make great apps.

CoreBitcoin deliberately implements as much as possible directly in Objective-C with limited dependency on OpenSSL. This gives everyone an opportunity to learn Bitcoin on a clean codebase and enables all Mac and iOS developers to extend and improve Bitcoin protocol.

> **Note:** Do not confuse this with "Bitcoin Core" (previously known as BitcoinQT or "Satoshi client"). CoreBitcoin is stylized after Apple frameworks (like CoreAnimation and CoreFoundation) and was named this way in 2013, while Bitcoin-QT was renamed into Bitcoin Core in 2014.


## Projects using CoreBitcoin

- [Chain-iOS SDK](https://github.com/chain-engineering/chain-ios) (written by Oleg Andreev)
- [Mycelium iOS Wallet](https://itunes.apple.com/us/app/mycelium-bitcoin-wallet/id943912290) (written by Oleg Andreev)
- [bitWallet](https://itunes.apple.com/us/app/bitwallet-bitcoin-wallet/id777634714)
- [Yallet](https://www.yallet.com)
- [BitStore](http://bitstoreapp.com)
- [ArcBit](http://arcbit.io)

## Features

See also [Release Notes](ReleaseNotes.md).

### Core Bitcoin Functionality

- **Address Encoding/Decoding**: P2PK, P2PKH, P2SH, WIF format ([`BTCAddress`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCAddress.h))
- **Transaction Building**: Inputs, outputs, scripts ([`BTCTransaction`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCTransaction.h), [`BTCScript`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCScript.h))
- **Cryptographic Keys**: EC keys and signatures ([`BTCKey`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCKey.h))
- **Transaction Builder**: High-level convenient and safe transaction builder ([`BTCTransactionBuilder`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCTransactionBuilder.h))
- **Bitcoin URLs**: Parsing and composing bitcoin URLs and payment requests ([`BTCBitcoinURL`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCBitcoinURL.h))
- **QR Codes**: Generator and scanner in a unified API (iOS only for now; [`BTCQRCode`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCQRCode.h))
- **Hierarchical Deterministic Wallets**: BIP32, BIP44 ([`BTCKeychain`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCKeychain.h))
- **Mnemonic Support**: BIP39 implementation ([`BTCMnemonic`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCMnemonic.h))
- **Payment Protocol**: BIP70 implementation ([`BTCPaymentProtocol`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCPaymentProtocol.h))
- **Wallet Backup**: [Automatic Encrypted Wallet Backup](https://github.com/oleganza/bitcoin-papers/blob/master/AutomaticEncryptedWalletBackups.md) scheme ([`BTCEncryptedBackup`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCEncryptedBackup.h))

### Currency Tools

- **Currency Formatter**: Bitcoin currency formatter with support for BTC, mBTC, bits ([`BTCNumberFormatter`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCNumberFormatter.h))
- **Currency Converter**: Exchange rate calculator (not linked to any exchange) ([`BTCCurrencyConverter`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCCurrencyConverter.h))
- **Price Sources**: Various price sources with abstract interface for adding new ones ([`BTCPriceSource`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCPriceSource.h)) with support for Winkdex, Coindesk, Coinbase, Paymium

### Advanced Features

- **ECDSA Signatures**: Deterministic [RFC6979](https://tools.ietf.org/html/rfc6979#section-3.2)-compliant ECDSA signatures
- **Script Evaluation**: Script evaluation machine to validate individual transactions ([`BTCScriptMachine`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCScriptMachine.h))
- **Blind Signatures**: Blind signatures implementation ([`BTCBlindSignature`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCBlindSignature.h))
- **Elliptic Curve Math**: Big numbers, curve points, conversion between keys, numbers and points ([`BTCBigNumber`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCBigNumber.h), [`BTCCurvePoint`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCCurvePoint.h))
- **Cryptographic Primitives**: Hash functions and AES encryption (see [`BTCData.h`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCData.h))


## On the Roadmap

See [all todo items](https://github.com/oleganza/CoreBitcoin/issues) for the complete list of planned features.

### Future Development

- **Blockchain Support**: Complete support for blocks and block headers
- **SPV Mode**: Support for SPV (Simplified Payment Verification) mode and P2P communication with other nodes
- **Blockchain Verification**: Full blockchain verification procedure and storage
- **Wallet Import**: Import BitcoinQT, Electrum, and Blockchain.info wallets
- **Cryptographic Libraries**: Support for [libsecp256k1](https://github.com/bitcoin/secp256k1) in addition to OpenSSL
- **Consensus Library**: Eventual support for libconsensus as it matures

The goal is to implement everything useful related to Bitcoin and organize it in a single powerful library. Pull requests are welcome!


## Starting Points

### Address Handling
To encode/decode Bitcoin addresses, see [`BTCAddress`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCAddress.h).

### Cryptographic Operations
For cryptographic operations, use:
- [`BTCKey`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCKey.h) for EC keys and signatures
- [`BTCBigNumber`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCBigNumber.h) and [`BTCCurvePoint`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCCurvePoint.h) for elliptic curve math
- [`BTCKeychain`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCKeychain.h) for BIP32 hierarchical deterministic wallets

### Blockchain Interaction
To fetch unspent coins and broadcast transactions, use one of these 3rd party APIs:
- [`BTCBlockchainInfo`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCBlockchainInfo.h) (blockchain.info)
- [Chain-iOS](https://github.com/chain-engineering/chain-ios) (recommended)

### Wallet Workflow Examples
For complete wallet workflow examples:
- See [`BTCTransaction+Tests.m`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCTransaction+Tests.m) for fetching unspent outputs, composing transactions, signing inputs, verification, and broadcasting
- See [`BTCScript+Tests.m`](https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoin/BTCScript+Tests.m) for multisignature script composition and unlocking

### Test Files
All files with `+Tests` in their names contain useful sample code and are worth exploring.


## Using CoreBitcoin CocoaPod (Recommended)

### Setup Instructions

1. Add this to your Podfile:

```ruby
pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec'
```

2. Run in Terminal:

```bash
$ pod install
```

### Header Inclusion

```objectivec
#import <CoreBitcoin/CoreBitcoin.h>
```

If you'd like to use categories, include this header instead:

```objectivec
#import <CoreBitcoin/CoreBitcoin+Categories.h>
```


## Using CoreBitcoin.framework

### Build Instructions

1. Clone this repository and build all libraries:

```bash
$ ./update_openssl.sh
$ ./build_libraries.sh
```

2. Copy the iOS or OS X framework from `binaries/iOS` or `binaries/OSX` to your project.

### Header Inclusion

```objectivec
#import <CoreBitcoin/CoreBitcoin.h>
```
	
### Additional Options

There are also raw universal libraries (.a) with headers located in `binaries/include`, if you need them for some reason. Frameworks and binary libraries have OpenSSL built-in. If you have a different version of OpenSSL in your project, consider using CocoaPods or raw sources of CoreBitcoin.


## Swift Support

We love Swift and design the code to be compatible with Swift. This includes using modern enums, favoring initializers over factory methods, and avoiding obscure C features.

You are welcome to try using CoreBitcoin from Swift. If you encounter any issues, please file bugs.

Swift is an excellent language for writing cryptographic code due to its explicit optionals, generics, and first-class structs. We would love to rewrite the entire CoreBitcoin and relevant portions of OpenSSL in Swift, but this is currently out of the question due to Swift's instability.

For now, we focus on maintaining an Objective-C implementation that remains compatible with Swift. When the ecosystem matures and everyone moves exclusively to Swift, we'll consider a complete rewrite.


## Contributing

We welcome contributions! Feel free to:

- Open issues for bug reports or feature requests
- Submit pull requests with your improvements
- Contact us to discuss how to contribute

### Code Style Guidelines

- Follow the existing code style
- Use 4 spaces instead of tabs
- Place opening braces on a new line
- There's no strict line width limit

### Contact Information

- Email: [oleganza@gmail.com](mailto:oleganza@gmail.com)
- Twitter: [@oleganza](http://twitter.com/oleganza)

### Publishing to CocoaPods

```bash
$ pod trunk push --verbose --use-libraries
```

## License

CoreBitcoin is released under the [WTFPL](http://www.wtfpl.net) license, except for OpenSSL components which have their own licensing.

Have a nice day!

