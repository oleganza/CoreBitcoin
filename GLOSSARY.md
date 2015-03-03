Bitcoin Glossary
================

### ATTENTION

This glossary has been moved to [Oleg Andreev's Bitcoin Papers](https://github.com/oleganza/bitcoin-papers/blob/master/BitcoinGlossary.md).

The content below will not be updated and eventually will be removed.

***

Some unusual terms are frequently used in Bitcoin documentation and discussions like *tx* or *coinbase*. Or words like *scriptPubKey* were badly chosen and now deserve some extra explanation. This glossary will help you understand exact meaning of all Bitcoin-related terms.

If you find an inaccuracy, please report it to oleganza@gmail.com or clone this repo and submit pull requests. Thanks!

### Address

Bitcoin address is a *Base58Check* representation of a *Hash160* of a *public key* with a version byte 0x00 which maps to a prefix "1". Typically represented as text (ex. 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG) or as a QR code. 

A more recent variant of an address is a *P2SH* address: a hash of a spending script with a version byte 0x05 which maps to a prefix "3" (ex. 3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8).

Another variant of an address is not a hash, but a raw private key representation (e.g. 5KQntKuhYWSRXNqp2yhdXzjekYAR7US3MT1715Mbv5CyUKV6hVe). It is rarely used, only for importing/exporting private keys or printing them on *paper wallets*.


### Altcoin

A clone of the protocol with some modifications. Usually all altcoins have rules incompatible with Bitcoin and have their own genesis blocks. Most notable altcoins are Litecoin (uses faster block confirmation time and scrypt as a proof-of-work) and Namecoin (has a special key-value storage). In theory, an altcoin can be started from an existing Bitcoin blockchain if someone wants to support a different set of rules (although, there was no such example to date). See also *Fork*.


### ASIC

Stands for "application-specific integrated circuit". In other words, a chip designed to perform a narrow set of tasks (compared to CPU or GPU that perform a wide range of functions). ASIC typically refers to specialized *mining* chips or the whole machines built on these chips. Some ASIC manufacturers: Avalon, ASICMiner, Butterfly Labs (BFL) and Cointerra. 


### ASICMiner

A Chinese manufacturer that makes custom mining hardware, sells shares for bitcoins, pays dividends from on-site mining and also ships actual hardware to customers.


### Base58

A compact human-readable encoding for binary data invented by *Satoshi Nakamoto* to make more user-friendly *addresses*. It consists of alphanumeric characters, but does not allow "0", "O", "I", "l" characters that look the same in some fonts and could be used to create visually identical looking addresses. Lowercase "o" and "1" are allowed.


### Base58Check

A variant of Base58 encoding that appends first 4 bytes of *Hash256* of the encoded data to that data before converting to Base58. It is used in *addresses* to detect typing errors.


### BIP

Bitcoin Improvement Proposals. RFC-like documents modeled after PEPs (Python Enhancement Proposals) discussing different aspects of the protocol and software. Most interesting BIPs describe *hard fork* changes in the core protocol that require supermajority of Bitcoin users (or, in some cases, only miners) to agree on the change and accept it in an organized manner.


### Bit

Name of a Bitcoin denomination equal to 100 *satoshis* (1 millionth of 1 *BTC*). In 2014 several companies including Bitpay and Coinbase, and various wallet apps adopted *bit* to display bitcoin amounts.


### Bitcoin

Refers to a protocol, network or a unit of currency. 

As a protocol, Bitcoin is a set of rules that every *client* must follow to accept transactions and have its own transactions accepted by other clients. Also includes a message protocol that allows nodes to connect to each other and exchange *transactions* and *blocks*.

As a network, Bitcoin is all the computers that follow the same rules and exchange transactions and blocks between each other.

As a unit, one Bitcoin (*BTC*, *XBT*) is defined as 100 million *satoshis*, the smallest units available in the current transaction format. Bitcoin is not capitalized when speaking about the amount: "I received 0.4 bitcoins."


### Bitcoin Core

New name of *BitcoinQT* since release of version 0.9 on March 19, 2014. Not to confuse with *CoreBitcoin*, an Objective-C implementation published in August 2013. See also *Bitcore*, a JavaScript implementation for Node.js by Bitpay.


### Bitcoinj

A Java implementation of a full Bitcoin node by Mike Hearn. Also includes *SPV* implementation among other features.


### Bitcoinjs

A JavaScript Bitcoin library. Allows singing transactions and performing several elliptic curve operations. Used on *brainwallet.org*. See also *Bitcore*, another JS library.


### BitcoinQT

Bitcoin implementation based on original code by *Satoshi Nakamoto*. Includes a graphical interface for Windows, OS X and Linux (using QT) and a command-line executable *bitcoind* that is typically used on servers.

It is considered a *reference implementation* as it's the most used *full node* implementation, especially among *miners*. Other implementations must be bug-for-bug compatible with it to avoid being *forked*. BitcoinQT uses OpenSSL for its ECDSA operations which has its own quirks that became a part of the standard (e.g. non-canonically encoded public keys are accepted by OpenSSL without an error, so other implementations must do the same).


### Bitcoind

Original implementation of Bitcoin with a command line interface. Currently a part of *BitcoinQT* project. "D" stands for "daemon" per UNIX tradition to name processes running in background. See also *BitcoinQT*.


### Bitcoin-ruby

A Bitcoin utilities library in Ruby by Julian Langschaedel. Used in production on *Coinbase.com*.


### Bitcore

A Bitcoin toolkit by Bitpay written in JavaScript. More complete than *Bitcoinjs*.


### Block

A data structure that consists of a *block header* and a *merkle tree* of transactions. Each block (except for *genesis block*) references one previous block thus forming a tree called the *blockchain*. Block can be though of as a group of transactions with a timestamp and a *proof-of-work* attached.


### Block Header

A data structure containing a previous block hash, a hash of a merkle tree of transactions, a timestamp, a *difficulty* and a *nonce*.


### Block Height

A sequence number of a block in the blockchain. Height 0 refers to the *genesis block*. Several blocks may share the same height (see *Orphan*), but only one of them belongs to the *main chain*. Block height is used in *Lock time*.


### Blockchain

A public ledger of all confirmed transactions in a form of a tree of all valid *blocks* (including *orphans*). Most of the time, "blockchain" means the *main chain*, a single most *difficult* chain of blocks. Blockchain is updated by *mining* blocks with new transactions. *Unconfirmed transactions* are not part of the blockchain. If some clients disagree on which chain is main or which blocks are valid, a *fork* happens.


### Blockchain.info

A web service running a Bitcoin *node* and displaying statistics and raw data of all the transactions and blocks. It also provides a *web wallet* functionality with *lightweight clients* for Android, iOS and OS X.


### Brain wallet

Brain wallet is a concept of storing *private keys* as a memorable phrase without any digital or paper trace. Either a single key is used for a single address, or a *deterministic wallet* derived from a single key. If done properly, a brain wallet greatly reduces the risk of theft because it is completely deniable: no one could say which or how much bitcoins you own as there are no actual wallet files to be found anywhere. However, it is the most error-prone method as one can simply forget the secret phrase, or make it too simple for anyone to brute force and steal all the funds. Additional risks are added by a complex wallet software. E.g. BitcoinQT always sends *change* amount to a new address. If a private key is imported temporarily to spend 1% of the funds and then the wallet is deleted, the remaining 99% will be lost forever as they are moved as a change to a completely new address. This already happened to a number of people.


### Brainwallet.org

Utility based on bitcoinjs to craft transactions by hand, convert *private keys* to addresses and work with a *brain wallet*.


### BTC

The most popular informal currency code for 1 Bitcoin (defined as 100 000 000 *Satoshis*). See also *XBT* and *Bit*.


### Casascius Coins

Physical collectible coins [produced](https://www.casascius.com) by Mike Caldwell. Each coin contains a *private key* under a tamper-evident hologram. The name "Casascius" is formed from a phrase "call a spade a spade", as a response to a name of Bitcoin itself. 


### Change

Informal name for a portion of a *transaction output* that is returned to a sender as a "change" after spending that output. Since *transaction outputs* cannot be partially spent, one can spend 1 BTC out of 3 BTC output only be creating two new outputs: a "payment" output with 1 BTC sent to a payee address, and a "change" output with remaining 2 BTC (minus *transaction fees*) sent to the payer's addresses. *BitcoinQT* always uses new address from a *key pool* for a better privacy. *Blockchain.info* sends to a default address in the wallet. 

A common mistake when working with a *paper wallet* or a *brain wallet* is to make a change transaction to a different address and then accidentally delete it. E.g. when importing a private key in a temporary BitcoinQT wallet, making a transaction and then deleting the temporary wallet.


### Checkpoint

A hash of a block before which the *BitcoinQT* client downloads blocks without verifying digital signatures for performance reasons. A checkpoint usually refers to a very deep block (at least several days old) when it's clear to everyone that that block is accepted by the overwhelming majority of users and *reorganization* will not happen past that point. 

It also helps protecting most of the history from a *51% attack*. Since checkpoints affect how the *main chain* is determined, they are part of the protocol and must be recognized by alternative clients (although, the risk of reorganization past the checkpoint would be incredibly low).


### Client

See *Node*.


### Coin

An informal term that means either 1 bitcoin, or an unspent *transaction output* that can be *spent*.


### Coinbase

An input script of a transaction that generates new bitcoins. Or a name of that transaction itself ("coinbase transaction"). Coinbase transaction does not spend any existing transactions, but contains exactly one input which may contain any data in its script. *Genesis block* transaction contains a reference to The Times article from January 3rd 2009 to prove that more blocks were not created before that date. Some *mining pools* put their names in the coinbase transactions (so everyone can estimate how much *hashrate* each pool produces). 

Coinbase is also used to vote on a protocol change (e.g. *P2SH*). Miners vote by putting some agreed-upon marker in the coinbase to see how many support the change. If a majority of miners support it and expect non-mining users to accept it, then they simply start enforcing new rule. Minority then should either continue with a forked blockchain (thus producing an *altcoin*) or accept new rule.


### Coinbase.com

US-based Bitcoin/USD exchange and web wallet service.


### Colored Coin

A concept of adding a special meaning to certain transaction outputs. This could be used to create a tradable commodity on top of Bitcoin protocol. For instance, a company may create 1 million shares and declare a single transaction output containing 10 BTC (1 bln *satoshis*) as a source of these shares. Then, some or all of these bitcoins can be moved to other addresses, sold or exchanged for anything. During a voting process or a dividend distribution, share owners can prove ownership by simply singing a particular message by the private keys associated with addresses holding bitcoins derived from the initial source.


### Cold Storage

A collective term for various security measures to reduce the risk of remote access to the private keys. It could be a normal computer disconnected from the internet, or a dedicated hardware wallet, or a USB stick with a wallet file, or a *paper wallet*.


### CompactSize

Original name of a variable-length integer format used in transaction and block serialization. Also known as "Satoshi's encoding". It uses 1, 3, 5 or 9 bytes to represent any 64-bit unsigned integer. Values lower than 253 are represented with 1 byte. Bytes 253, 254 and 255 indicate 16-, 32- or 64-bit integer that follows. Smaller numbers can be presented differently.  In *bitcoin-ruby* it is called "var_int", in *Bitcoinj* it is VarInt. *BitcoinQT* also has even more compact representation called VarInt which is not compatible with CompactSize and used in block storage.


### Confirmed Transaction

Transaction that has been included in the blockchain. Probability of transaction being rejected is measured in a number of confirmations. See *Confirmation Number*.


### Confirmation Number

Confirmation number is a measure of probability that transaction could be rejected from the *main chain*. "Zero confirmations" means that transaction is *unconfirmed* (not in any block yet). One confirmation means that the transaction is included in the latest block in the main chain. Two confirmations means the transaction is included in the block right before the latest one. And so on. Probability of transaction being reversed (*"double spent"*) is diminishing exponentially with more blocks added "on top" of it.


### Difficulty

Difficulty is a measure of how difficult it is to find a new block compared to the easiest it can ever be. By definition, it is a maximum *target* divided by the current target. Difficulty is used in two Bitcoin rules: 1) every block must be meet difficulty target to ensure 10 minute interval between blocks and 2) transactions are considered confirmed only when belonging to a *main chain* which is the one with the biggest cumulative difficulty of all blocks.  As of July 27, 2014 the difficulty is 18 736 441 558 and grows by 3-5% every two weeks. See also *Target*.


### Denial of Service

Is a form of attack on the network. Bitcoin *nodes* punish certain behavior of other nodes by banning their IP addresses for 24 hours to avoid DoS. Also, some theoretical attacks like *51% attack* may be used for network-wide DoS.


### Depth

Depth refers to a place in the blockchain. A transaction with 6 *confirmations* can also be called "6 blocks deep".


### Deterministic Wallet

A collective term for different ways to generate a sequence of *private keys* and/or *public keys*. Deterministic wallet does not need a *Key Pool*. The simplest form of a deterministic wallet is based on hashing a secret string concatenated with a key number. For each number the resulting hash is used as a private key (public key is derived from it). More complex scheme uses *elliptic curve arithmetic* to derive sequences of public and private keys separately which allows generating new *addresses* for every payment request without storing private keys on a web server. [More information on Bitcoin Wiki](https://en.bitcoin.it/wiki/Deterministic_wallet). See also *Wallet*.


### DoS

See *Denial of Service*.


### Double Spend

A fraudulent attempt to spend the same *transaction output* twice. There are two major ways to perform a double spend: reverting an *unconfirmed transaction* by making another one which has a higher chance of being included in a block (only works with merchants accepting zero-confirmation transactions) or by *mining* a parallel blockchain with a second transaction to overtake the chain where the first transaction was included.

Bitcoin *proof-of-work* scheme makes a probabilistic guarantee of difficulty to double spend transactions included in the *blockchain*. The deeper transaction is recorded in the blockchain, the more expensive it is to "reverse" it. See also *51% attack*.


### Dust

A transaction output that is smaller than a typically fee required to spend it. This is not a strict part of the protocol, as any amount more than zero is valid. BitcoinQT refuses to mine or relay "dust" transactions to avoid uselessly increasing the size of unspent transaction outputs (UTXO) index. See also discussion about *UTXO*.


### ECDSA

Stands for *Elliptic Curve Digital Signature Algorithm*. Used to verify transaction ownership when making a transfer of bitcoins. See *Signature*.


### Elliptic Curve Arithmetic

A set of mathematical operations defined on a group of points on a 2D elliptic curve. Bitcoin protocol uses predefined curve [secp256k1](https://en.bitcoin.it/wiki/Secp256k1). Here's the simplest possible explanation of the operations: you can add and subtract points and multiply them by an integer. Dividing by an integer is computationally infeasible (otherwise cryptographic signatures won't work). The private key is a 256-bit integer and the public key is a product of a predefined point G ("generator") by that integer: A = G * a. Associativity law allows implementing interesting cryptographic schemes like Diffie-Hellman key exchange (ECDH): two parties with private keys *a* and *b* may exchange their public keys *A* and *B* to compute a shared secret point C: C = A * b = B * a because (G * a) * b == (G * b) * a. Then this point C can be used as an AES encryption key to protect their communication channel.


### Extra nonce

A number placed in *coinbase* script and incremented by a miner each time the *nonce* 32-bit integer overflows. This is not the required way to continue mining when nonce overflows, one can also change the *merkle tree* of transactions or change a public key used for collecting a block *reward*. See also *nonce*.


### Fee

See *Transaction Fee*.


### Fork

Refers either to a fork of a source code (see *Altcoin*) or, more often, to a split of the blockchain when two different parts of the network see different *main chains*. In a sense, fork occurs every time two blocks of the same *height* are created at the same time. Both blocks always have the different hashes (and therefore different *difficulty*), so when a node sees both of them, it will always choose the most difficult one. However, before both blocks arrive to a majority of nodes, two parts of the network will see different blocks as tips of the main chain.

Term *fork* or *hard fork* also refers to a change of the protocol that may lead to a split of the network (by design or because of a bug). On March 11 2013 a smaller half of the network running version 0.7 of *bitcoind* could not include a large (>900 Kb) block at height 225430 created by a miner running newer version 0.8. The block could not be included because of the bug in v0.7 which was fixed in v0.8. Since the majority of computing power did not have a problem, it continued to build a chain on top of a problematic block. When the issue was noticed, majority of 0.8 miners agreed to abandon 24 blocks incompatible with 0.7 miners and mine on top of 0.7 chain. Except for one double spend experiment against OKPay, all transactions during the fork were properly included in both sides of the blockchain.


### Full Node

A *node* which implements all of Bitcoin protocol and does not require trusting any external service to validate transactions. It is able to download and validate the entire *blockchain*. All full nodes implement the same peer-to-peer messaging protocol to exchange transactions and blocks, but that is not a requirement. A full node may receive and validate data using any protocol and from any source. However, the highest security is achieved by being able to communicate as fast as possible with as many nodes as possible.


### Genesis Block

A very first block in the blockchain with hard-coded contents and a all-zero reference to a previous block. Genesis block was released on 3rd of January 2009 with a newspaper quote in its *coinbase*: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks" as a proof that there are no secretly pre-mined blocks to overtake the blockchain in the future. The message ironically refers to a reason for Bitcoin existence: a constant inflation of money supply by governments and banks.


### Halving

Refers to reducing *reward* every 210 000 blocks (approximately every 4 years). Since the *genesis block* to a block 209999 in December 2012 the reward was 50 BTC. Till 2016 it will be 25 BTC, then 12.5 BTC and so on till 1 *satoshi* around 2140 after which point no more bitcoins will ever be created. Due to reward halving, the total supply of bitcoins is limited: only about 2100 trillion *satoshis* will ever be created.


### Hard Fork

Some people use term *hard fork* to stress that changing Bitcoin protocol requires overwhelming majority to agree with it, or some noticeable part of the economy will continue with original blockchain following the old rules. See *Fork* and *Soft Fork* for further discussion.


### Hash Function

Bitcoin protocol mostly uses two cryptographic hash functions: SHA-256 and RIPEMD-160. First one is almost exclusively used in the two round hashing (*Hash256*), while the latter one is only used in computing an *address* (see also *Hash160*). *Scripts* may use not only Hash256 and Hash160, but also SHA-1, SHA-256 and RIPEMD-160.


### Hash, Hash256

When not speaking about arbitrary hash functions, *Hash* refers to two rounds of SHA-256. That is, you should compute a SHA-256 hash of your data and then another SHA-256 hash of that hash. It is used in *block header* hashing, *transaction* hashing, making a *merkle tree* of transactions, or computing a checksum of an *address*. Known as BTCHash256() in CoreBitcoin, Hash() in BitcoinQT. It is also available in scripts as OP_HASH256.


### Hash160

SHA-256 hashed with RIPEMD-160. It is used to produce an *address* because it makes a smaller hash (20 bytes vs 32 bytes) than SHA-256, but still uses SHA-256 internally for security. BTCHash160() in CoreBitcoin, Hash160() in BitcoinQT. It is also available in scripts as OP_HASH160.


### To hash

To compute a hash function of some data. If hash function is not mentioned explicitly, it is the one defined by the context. For instance, "to hash a transaction" means to compute *Hash256* of binary representation of a transaction.


### Hashrate

A measure of mining hardware performance expressed in hashes per second (GH/s). As of July 27, 2014 the hash rate of all Bitcoin mining nodes combined is around 135 799 000 GH/s. For comparison, AMD Radeon graphics cards produce from 0.2 to 0.8 GH/s depending on model.


### Hash Type (hashtype)

A single byte appended to a transaction *signature* in the *transaction input* which describes how the transaction should be hashed in order to verify that signature. There are three types affecting outputs: ALL (default), SINGLE, NONE and one optional modifier ANYONECANPAY affecting the inputs (can be combined with either of the first three). ALL requires all outputs to be hashed (thus, all outputs are signed). SINGLE clears all output scripts but the one with the same index as the input in question. NONE clears all outputs thus allowing changing them at will. ANYONECANPAY removes all inputs except the current one (allows anyone to contribute independently). The actual behavior is more subtle than this overview, you should check the actual source code for more comments.


### Height

See *Block Height*.


### Input

See *Transaction Input*.


### Key

Could mean an ECDSA public or private key, or AES symmetric encryption key. AES is not used in the protocol itself (only to encrypt the ECDSA keys and other sensitive data), so usually the word *key* means an ECDSA key. When talking about *keys*, people usually mean private keys as public key can always be derived from a private one. See also *Private Key* and *Public Key*.


### Key Pool

Some wallet applications that create new *private keys* randomly keep a pool of unused pre-generated keys (BitcoinQT keeps 100 keys by default). When a new key is needed for *change* address or a new payment request, the application provides the oldest key from the pool and replaces it with a fresh one. The purpose of the pool is to ensure that recently used keys are always already backed up on external storage. Without a key pool you could create a new key, receive a payment on its address and then have your hard disk died before backing up this key. A key pool guarantees that this key was already backed up several days before being used. *Deterministic wallets* do not use a key pool because they need to back up a single secret key.


### Lightweight client

Comparing to a *full node*, lightweight node does not store the whole blockchain and thus cannot fully verify any transaction. There are two kinds of lightweight nodes: those fully trusting an external service to determine wallet balance and validity of transactions (e.g. *blockchain.info*) and the apps implementing *Simplified Payment Verification* (SPV). SPV clients do not need to trust any particular service, but are more vulnerable to a *51% attack* than full nodes. See *Simplified Payment Verification* for more info.


### Lock Time (locktime)

A 32-bit field in a *transaction* that means either a block *height* at which the transaction becomes valid, or a UNIX timestamp. Zero means transaction is valid in any block. A number less than 500000000 is interpreted as a block number (the limit will be hit after year 11000), otherwise a timestamp.


### Mainnet

Main Bitcoin network and its blockchain. The term is mostly used in comparison to *testnet*.


### Main Chain

A part of the blockchain which a node considers the most difficult (see *difficulty*). All nodes store all valid blocks, including *orphans* and recompute the total difficulty when receiving another block. If the newly arrived block or blocks do not extend existing main chain, but create another one from some previous block, it is called *reorganization*.


### Merkle Tree

Merkle tree is an abstract data structure that organizes a list of data items in a tree of their hashes (like in Git, Mercurial or ZFS). In Bitcoin the merkle tree is used only to organize transactions within a block (the block header contains only one hash of a tree) so that full nodes may prune fully spent transactions to save disk space. *SPV* clients store only block headers and validate transactions if they are provided with a list of all intermediate hashes.


### Mempool

A technical term for a collection of unconfirmed transactions stored by a node until they either expire or get included in the main chain. When *reorganization* happens, transactions from orphaned blocks either become invalid (if already included in the *main chain*) or moved to a pool of unconfirmed transactions. By default, *bitcoind* nodes throw away unconfirmed transactions after 24 hours.


### Mining

A process of finding valid *hashes* of a block header by iterating millions of variants of block headers (using *nonce* and *extra nonce*) in order to find a hash lower than the *target* (see also *difficulty*). The process needs to determine a single global history of all transactions (grouped in blocks). Mining consumes time and electricity and nowadays the difficulty is so big, that energy-wise it's not even profitable to mine using video graphics cards. Mining is paid for by *transaction fees* and by block *rewards* (newly generated coins, hence the term "mining").


### Mining Pool

A service that allows separate owners of mining hardware to split the reward proportionally to submitted work. Since probability of finding a valid block hash is proportional to miner's *hashrate*, small individual miners may work for months before finding a big per-block reward. Mining pools allow more steady stream of smaller income. Pool owner determines the block contents and distributes ranges of *nonce* values between its workers. Normally, mining pools are centralized. P2Pool is a fully decentralized pool.


### Miner

A person, a software or a hardware that performs *mining*.


### Mixing

A process of exchanging coins with other persons in order to increase privacy of one's history. Sometimes it is associated with money laundering, but strictly speaking it is orthogonal to laundering. In traditional banking, a bank protects customer's privacy by hiding transactions from all 3rd parties. In Bitcoin any merchant may do a statistical analysis of one's entire payment history and determine, for instance, how many bitcoins one owns. While it's still possible to implement KYC (Know You Customer) rules on a level of every merchant, mixing allows to to separate information about one's history between the merchants. 

Most important use cases for mixing are: 1) receiving a salary as a single big monthly payment and then spending it in small transactions ("cafe sees thousands of dollars when you pay just $4"); 2) making a single payment and revealing connection of many small private spendings ("car dealer sees how much you are addicted to coffee"). In both cases your employer, a cafe and a car dealer may comply with KYC/AML laws and report your identity and transferred amounts, but neither of them need to know about each other. Mixing bitcoins after receiving a salary and mixing them before making a big payment solves this privacy problem.


### M-of-N Multi-signature Transaction

A transaction that can be spent using M signatures when N public keys are required (M is less or equal to N). Multi-signature transactions that only contain one *OP_CHECKMULTISIG* opcode and N is 3, 2 or 1 are considered *standard*.


### Node

Node, or client, is a computer on the network that speaks Bitcoin message protocol (exchanging transactions and blocks). There are *full nodes* that are capable of validating the entire blockchain and *lightweight nodes*, with reduced functionality. Wallet applications that speak to a server are not considered nodes.


### Nonce

Stands for "number used once". A 32-bit number in a *block header* which is iterated during a search for proof-of-work. Each time the nonce is changed, the *hash* of the block header is recalculated. If nonce overflows before valid proof-of-work is found, an *extra nonce* is incremented and placed in the *coinbase* script. Alternatively, one may change a merkle tree of transactions or a timestamp.
 

### Non-standard Transaction

Any valid transaction that is not *standard*. Non-standard transactions are not relayed or mined by default *BitcoinQT* nodes (but are relayed and mined on *testnet*). However, if anyone puts such transaction in a block, it will be accepted by all nodes. In practice it means that unusual transactions will take more time to get included in the blockchain. If some kind of non-standard transaction becomes useful and popular, it may get named standard and adopted by users (like it ).  See also *Standard Transaction*.


### Opcode

8-bit code of a *script* operation. Codes from 0x01 to 0x4B (decimal 75) are interpreted as a length of data to be pushed on the stack of the interpreter (data bytes follow the opcode). Other codes are either do something interesting, or disabled and cause transaction verification to fail, or do nothing (reserved for future use). See also *Script*.


### Orphan, Orphaned Block

A valid block that is no longer a part of a *main chain*. Usually happens when two or more blocks of the same *height* are produced at the same time. When one of them becomes a part of the main chain, others are considered "orphaned". Orphans also may happen when the blockchain is *forked* due to an attack (see *51% attack*) or a bug. Then a chain of several blocks may become abandoned. Usually a transaction is included in all blocks of the same height, so its *confirmation* is not delayed and there is no *double spend*. See also *Fork*. 


### Output

See *Transaction Output*.


### P2SH

See *Pay-to-Script Hash*.


### Pay-to-Script Hash

A type of the *script* and *address* that allows sending bitcoins to arbitrary complex scripts using a compact hash of that script. This allows payer to pay much smaller *transaction fees* and not wait very long for a *non-standard* transaction to get included in the blockchain. Then the actual script matching the hash must be provided by the payee when redeeming the funds. P2SH addresses are encoded in *Base58Check* just like regular public keys and start with number "3".


### Paper Wallet

A form of *cold storage* where a *private key* for Bitcoin *address* is printed on a piece of paper (with or without encryption) and then all traces of the key are removed from the computer where it was generated. To redeem bitcoins, a key must be imported in the wallet application so it can sign a transaction. See also *Casascius Coins*.


### Proof-of-Work (PoW)

A number that is provably hard to compute. That is, it takes measurable amount of time and/or computational power (energy) to produce. In Bitcoin it is a *hash* of a *block header*. A block is considered valid only if its hash is lower than the current *target* (roughly, starts with a certain amount of zero bits). Each block refers to a previous  block thus accumulating previous proof-of-work and forming a *blockchain*.

Proof-of-work is not the only requirement, but an important one to make sure that it is economically infeasible to produce an alternative history of transactions with the same accumulated work. Each client can independently consider the most difficult chain of valid blocks as the "true" history of transactions, without need to trust any source that provides the blocks.

Note that owning a very large amount of computational power does not override other rules enforced by every client. Ill-formed blocks or blocks containing invalid transactions are rejected no matter how difficult they were to produce.


### Private Key (Privkey)

A 256-bit number used in *ECDSA* algorithm to create transaction *signatures* in order to prove ownership of certain amount of bitcoins. Can also be used in arbitrary *elliptic curve arithmetic* operations. Private keys are stored within *wallet* applications and are usually encrypted with a pass phrase. Private keys may be completely random (see *Key Pool*) or generated from a single secret number ("seed"). See also *Deterministic Wallet*.


### Public Key (Pubkey)

A 2D point on an elliptic curve [secp256k1](https://en.bitcoin.it/wiki/Secp256k1) that is produced by multiplying a predefined "generator" point by a *private key*. Usually it is represented by a pair of 256-bit numbers ("uncompressed public key"), but can also be compressed to just one 256-bit number (at the slight expense of CPU time to decode an uncompressed number). A special hash of a public key is called *address*. Typical Bitcoin transactions contain public keys or addresses in the output scripts and *signatures* in the input scripts.


### Reference Implementation

*BitcoinQT* (or *bitcoind*) is the most used *full node* implementation, so it is considered a reference for other implementations. If an alternative implementation is not compatible with BitcoinQT it may be *forked*, that is it will not see the same *main chain* as the rest of the network running *BitcoinQT*.


### Relaying Transactions

Connected Bitcoin *nodes* relay new transactions between each other on best effort basis in order to send them to the *mining* nodes. Some transactions may not be relayed by all nodes. E.g. *non-standard* transactions, or transactions without a minimum *fee*. Bitcoin message protocol is not the only way to send the transaction. One may also send it directly to a miner, or mine it yourself, or send it directly to the payee and make them to relay or mine it.


### Reorg, Reorganization

An event in the *node* when one or more blocks in the *main chain* become *orphaned*. Usually, newly received blocks are extending existing main chain. Sometimes (4-6 times a week) a couple of blocks of the same *height* are produced almost simultaneously and for a short period of time some nodes may see one block as a tip of the main chain which will be eventually replaced by a more difficult block(s). Each transaction in the orphaned blocks either becomes invalid (if already included in the main chain block) or becomes *unconfirmed* and moved to the *mempool*. In case of a major bug or a *51% attack*, reorganization may involve reorganizing more than one block.


### Reward

Amount of newly generated bitcoins that a *miner* may claim in a new block. The first transaction in the block allows miner to claim currently allowed reward as well as all *transaction fees* from all transactions in the block. Reward is *halved* every 210 000 blocks, approximately every 4 years. As of July 27, 2014 the reward is 25 BTC (the first halving occurred in December 2012). For security reasons, rewards cannot be *spent* before 100 blocks built on top of the current block.


### Satoshi

The first name of the Bitcoin's creator *Satoshi Nakamoto* and also the name of the smallest unit used in transactions. 1 bitcoin (BTC) is equal to 100 million satoshis.


### Satoshi Nakamoto

A pseudonym of an author of initial Bitcoin implementation. There are multitude of speculations on who and how many people worked on Bitcoin, of which nationality or age, but no one has any evidence to say anything definitive on that matter.


### Script

A compact turing-incomplete programming language used in transaction *inputs* and *outputs*. Scripts are interpreted by a Forth-like stack machine: each operation manipulates data on the stack. Most scripts follow the standard pattern and verify the digital *signature* provided in the transaction *input* against a *public key* provided in the previous transaction's *output*. Both signatures and public keys are provided using scripts. Scripts may contain complex conditions, but can never change amounts being transferred. Amount is stored in a separate field in a *transaction output*.


### scriptSig

Original name in *bitcoind* for a transaction *input* script. Typically, input scripts contain *signatures* to prove ownership of bitcoins sent by a previous transaction.


### scriptPubKey

Original name in *bitcoind* for a transaction *output* script. Typically, output scripts contain *public keys* (or their hashes; see *Address*) that allow only owner of a corresponding *private key* to redeem the bitcoins in the output.


### Sequence

A 32-bit unsigned integer in a transaction input used to replace older version of a transaction by a newer one. Only used when *locktime* is not zero. Transaction is not considered valid until the sequence number is 0xFFFFFFFF. By default, the sequence is 0xFFFFFFFF.


### Signature

A sequence of bytes that proves that a piece of data is acknowledged by a person holding a certain *public key*. Bitcoin uses *ECDSA* for signing transactions. Amounts of bitcoins are sent through a chain of transactions: from one to another. Every transaction must provide a signature matching a public key defined in the previous transaction. This way only a proper owner a secret *private key* associated with a given public key can spend bitcoins further.


### Simplified Payment Verification (SPV)

A scheme to validate transactions without storing the whole blockchain (only block headers) and without trusting any external service. Every transaction must be present with all its parent and sibling hashes in a *merkle tree* up to the root. SPV client trusts the most *difficult* chain of block headers and can validate if the transaction indeed belongs to a certain block header. Since SPV does not validate all transactions, a *51% attack* may not only cause a *double spend* (like with *full nodes*), but also make a completely invalid payment with bitcoins created from nowhere. However, this kind of attack is very costly and probably more expensive than a product in question. *Bitcoinj* library implements SPV functionality.


### Secret key

Either the *Private Key* or an encryption key used in encrypted *wallets*. Bitcoin protocol does not use encryption anywhere, so *secret key* typically means a *private key* used for signing transactions.


### Soft Fork

Sometimes the *soft fork* refers to an important change of software behavior that is not a *hard fork* (e.g. changing *mining fee* policy). See also *Hard Fork* and *Fork*.


### Spam

Incorrect peer-to-peer messages (like sending invalid transactions) may be considered a denial of service attack (see *DoS*). Valid transactions sending very tiny amounts and/or having low *mining fees* are called *Dust* by some people. The protocol itself does not define which transactions are not worth relaying or mining, it's a decision of every individual node. Any valid transaction in the blockchain must be accepted by the node if it wishes to accept the remaining blocks, so transaction censorship only means increased confirmation delays. Individual payees may also blacklist certain addresses (refuse to accept payments from some addresses), but that's too easy to work around using *mixing*.


### Spent Output

A transaction *output* can be spent only once: when another valid transaction makes a reference to this output from its own input. When another transaction attempts to spend the same output, it will be rejected by the nodes already seeing the first transaction. Blockchain as a *proof-of-work* scheme allows every node to agree on which transaction was indeed the first one. The whole transaction is considered spent when all its outputs are spent.


### Split

A split of a blockchain. See *Fork*.


### SPV

See *Simplified Payment Verification*.


### Standard Transaction

Some transactions are considered *standard*, meaning they are relayed and mined by most *nodes*. More complex transactions could be buggy or cause DoS attacks on the network, so they are considered *non-standard* and not relayed or mined by most nodes. Both standard and non-standard transactions are valid and once included in the blockchain, will be recognized by all nodes. Standard transactions are: 1) sending to a *public key*, 2) sending to an *address*, 3) sending to a *P2SH* address, 4) sending to *M-of-N multi-signature transaction* where N is 3 or less.


### Target

A 256-bit number that puts an upper limit for a block header hash to be valid. The lower the target is, the higher the *difficulty* to find a valid hash. The maximum (easiest) target is 0x00000000FFFF0000000000000000000000000000000000000000000000000000. The difficulty and the target are adjusted every 2016 blocks (approx. 2 weeks) to keep interval between the blocks close to 10 minutes.


### Testnet

A set of parameters used for testing a Bitcoin network. Testnet is like *mainnet*, but has a different genesis block (it was reset several times, the latest testnet is *testnet3*). Testnet uses slightly different *address* format to avoid confusion with main Bitcoin addresses and all nodes are relaying and mining non-standard transactions.


### Testnet3

The latest version of *testnet* with another genesis block.
 

### Timestamp

UNIX timestamp is a standard representation of time as a number of seconds since January 1st 1970 GMT. Usually stored in a 32-bit signed integer.


### Transaction

A chunk of binary data that describes how bitcoins are moved from one owner to another. Transactions are stored in the *blockchain*. Every transaction (except for *coinbase* transactions) has a reference to one or more previous transactions (*inputs*) and one or more rules on how to spend these bitcoins further (*outputs*). See *Transaction Input* and *Transaction Output* for more info.


### Transaction Fee

Also known as "miners' fee", an amount that an author of transaction pays to a miner who will include the transaction in a block. The fee is expressed as difference between the sum of all *input* amounts and a sum of all *output* amounts. Unlike traditional payment systems, miners do not explicitly require fees and most miners allow free transactions. All miners are competing between each other for the fees and all transactions are competing for a place in a block. There are soft rules encoded in most clients that define minimum fees per kilobyte to relay or mine a transaction (mostly to prevent *DoS* and *spam*). Typically, the fee affects the priority of a transaction. As of July 27, 2014 average fee per block is below 0.1 BTC. See also *Reward*.


### Transaction Input

A part of a transaction that contains a reference to a previous transaction's *output* and a *script* that can prove ownership of that output. The script usually contains a *signature* and thus called *scriptSig*. Inputs spend previous outputs completely. So if one needs to pay only a portion of some previous output, the transaction should include extra *change* output that sends the remaining portion back to its owner (on the same or different address). *Coinbase* transactions contain only one input with a zeroed reference to a previous transaction and an arbitrary data in place of script.


### Transaction Output

An output contains an amount to be sent and a *script* that allows further spending. The script typically contains a *public key* (or an *address*, a hash of a public key) and a signature verification *opcode*. Only an owner of a corresponding *private key* is able to create another transaction that sends that amount further to someone else. In every transaction, the sum of output amounts must be equal or less than a sum of all input amounts. See also *Change*.


### Tx

See *Transaction*.


### Txin

See *Transaction Input*.


### Txout

See *Transaction Output*. 


### Unconfirmed Transaction

Transaction that is not included in any block. Also known as "0-confirmation" transaction. Unconfirmed transactions are *relayed* by the nodes and stay in their *mempools*. Unconfirmed transaction stays in the pool until the node decides to throw it away, finds it in the blockchain, or includes it in the blockchain itself (if it's a miner). See also *Confirmation Number*.


### UTXO Set

A collection of *Unspent Transaction Outputs*. Typically used in discussions on optimizing an ever-growing index of *transaction outputs* that are not yet *spent*. The index is important to efficiently validate newly created transactions. Even if the rate of the new transactions remains constant, the time required to locate and verify unspent outputs grows. 

Possible technical solutions include more efficient indexing algorithms and a more performant hardware. *BitcoinQT*, for example, keeps only an index of outputs matching user's keys and scans the entire blockchain when validating other transactions. A developer of one web wallet service mentioned that they maintain the entire index of UTXO and its size was around 100 Gb when the blockchain itself was only 8 Gb.

Some people seek social methods to solve the problem. For instance, by refusing to *relay* or *mine* transactions that are considered *dust* (containing outputs smaller than a *transaction fee* required to mine/relay them).


### VarInt

This term may cause confusion as it means different formats in different Bitcoin implementations. See *CompactSize* for details.


### Wallet

An application or a service that helps keeping private keys for signing transactions. Wallet does not keep bitcoins themselves (they are recorded in *blockchain*). "Storing bitcoins" usually means storing the keys. 


### Web Wallet

A web service providing wallet functionality: ability to store, send and receive bitcoins. User has to trust counter-party to keep their bitcoins securely and ready to redeem at any time. It is very easy to build your own web wallet, so most of them were prone to hacks or outright fraud. The most secure and respected web wallet is *Blockchain.info*. Online exchanges also provide wallet functionality, so they can also be considered web wallets. It is not recommended to store large amounts of bitcoins in a web wallet.


### XBT

Informal currency code for 1 Bitcoin (defined as 100 000 000 *Satoshis*). Some people proposed using it for 0.01 Bitcoin to avoid confusion with *BTC*. There were rumors that Bloomberg tests XBT as a ticker for 1 Bitcoin, but currently there is only ticker XBTFUND for SecondMarket's Bitcoin Investment Trust. See also *BTC*.


### 0-Confirmation (Zero-Confirmation)

See *Unconfirmed Transaction* and *Confirmation Number*.


### 51% Attack

Also known as >50% attack or a *double spend* attack. An attacker can make a payment, wait till the merchant accepts some number of *confirmations* and provides the service, then starts mining a parallel chain of blocks starting with a block before the transaction. This parallel blockchain then includes another transaction that spends the same *outputs* on some other address. When the parallel chain becomes more *difficult*, it is considered a *main chain* by all nodes and the original transaction becomes invalid. Having more than a half of total *hashrate* guarantees possibility to overtake chain of any length, hence the name of an attack (strictly speaking, it is "more than 50%", not 51%). Also, even 40% of hashrate allows making a double spend, but the chances are less than 100% and are diminishing exponentially with the number of confirmations that the merchant requires. 

This attack is considered theoretical as owning more than 50% of hashrate might be much more expensive than any gain from a *double spend*. Another variant of an attack is to disrupt the network by mining empty blocks, censoring all transactions. An attack can be mitigated by blacklisting blocks that most of "honest" miners consider abnormal. Under normal conditions, miners and mining pools do not censor blocks and transactions as it may diminish trust in Bitcoin and thus their own investments. 51% attack is also mitigated by using *checkpoints* that prevent *reorganization* past the certain block.



About
-----

Glossary is made by Oleg Andreev ([oleganza@gmail.com](mailto:oleganza@gmail.com)). Twitter: [@oleganza](http://twitter.com/oleganza).

Send your thanks here: 1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG.

This glossary is released under [WTFPL](http://www.wtfpl.net). Do what you want with it, but I would appreciate if you give full credit in case you republish it.

Please report any mistakes or create pull requests on Github. Contributors will be listed here. Thanks!

