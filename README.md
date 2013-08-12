
CoreBitcoin
===========

CoreBitcoin is an implementation of Bitcoin protocol in Objective-C. When it's complete, it will let you create an application that acts as a full Bitcoin node. Today, you can encode/decode addresses, apply various hash functions, sign and verify messages and parse some data structures. Transaction support is incomplete.

The only external dependency is OpenSSL (used for Bignum, ECC and RIPEMD160). Today OpenSSL source is stored in this repo and is built with update_openssl.sh script. OpenSSL binaries are OSX-only and committed in the repo. This is far from perfect and binary does not support iOS architectures. This will be fixed in the future.

Ideally, we wouldn't require OpenSSL at all, but keep in mind that BitcoinQT uses OpenSSL and some quirks of OpenSSL are now part of the protocol. So if you are going to reimplement ECC, it must be bug-to-bug compatible with OpenSSL implementation.

How To
------

Clone this repo and make sure you can run "UnitTests" target. It is a simple command-line app that runs a bunch of asserts. If nothing fails, the program silently exits.

If it works well, add this repo as a submodule to your project. Then add all source files, openssl headers and libcrypto.a and libssl.a. 

In your project settings, add `$(SRCROOT)/CoreBitcoin/openssl/include` to "Headers Search Paths" and `$(SRCROOT)/CoreBitcoin/openssl/lib` in "Library Search Paths".

If you'd like to help me building self-contained CoreBitcoin.framework, there is a bounty for that.


TODO
----

- Universal OpenSSL libraries. Or as a part of a build process.
- Universal CoreBitcoin.framework bundle with OpenSSL inside.
- Full transaction support.
- Full blockchain support.
- Unit tests for EC sign/verify.
- Unit tests for transaction parsing/serialization.
- Modern unit test suite.
- Security analysis. Do we use truly random numbers? Do we sign things correctly? Do we have buffer overflows? And so on.


Bounties
--------

- 1 BTC for building CoreBitcoin.framework with support for x86_64, armv7, armv7s. OpenSSL should be bundled inside. [@oleganza]

To add your own bounty, add a line here (or edit an existing one), make a pull request and donate to the address below. Your donation will be reserved for that bounty only. I will contact you to check if the implementation is acceptable before paying out.


Contribute
----------

Feel free to open issues, drop me pull requests or contact me to discuss how to do things.

Code style: follow existing style and use 4 spaces instead of tabs. There's no line width limit.

Email: [oleganza@gmail.com](mailto:oleganza@gmail.com)

Twitter: [@oleganza](http://twitter.com/oleganza)


Donate
------

Please send your donations here: 1Ec2aXPDBqvSi6iLepA3Vz1j5Cxtc2fwj8.

All funds will be used only for bounties to fix stuff. Every withdrawal from this address will be documented.

If you want to donate for a specific bounty, feel free to let me know. The amount will be reserved for that bounty and listed in the list of bounties.


License
-------

Released under the [WTFPL](http://www.wtfpl.net) except for OpenSSL. You don't need to advertise CoreBitcoin in your app, but please consider donating money for development.

