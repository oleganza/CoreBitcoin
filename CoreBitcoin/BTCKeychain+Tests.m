// Oleg Andreev <oleganza@gmail.com>

#import "BTCKeychain+Tests.h"
#import "BTCData.h"
#import "BTCBase58.h"
#import "BTCKey.h"

@implementation BTCKeychain (Tests)

+ (void) runAllTests
{
    [self testStandardTestVectors];
}

+ (void) testStandardTestVectors
{
    // Test Vector 1
    /*
     
     Master (hex): 000102030405060708090a0b0c0d0e0f
     * [Chain m]
     * ext pub: xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8
     * ext prv: xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
     * [Chain m/0']
     * ext pub: xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw
     * ext prv: xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7
     * [Chain m/0'/1]
     * ext pub: xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
     * ext prv: xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs
     * [Chain m/0'/1/2']
     * ext pub: xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5
     * ext prv: xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM
     * [Chain m/0'/1/2'/2]
     * ext pub: xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV
     * ext prv: xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334
     * [Chain m/0'/1/2'/2/1000000000]
     * ext pub: xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy
     * ext prv: xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76
     */
    {
        NSData* seed = BTCDataWithHexCString("000102030405060708090a0b0c0d0e0f");
        
        BTCKeychain* masterChain = [[BTCKeychain alloc] initWithSeed:seed];
        
        NSAssert(masterChain.parentFingerprint == 0, @"");
        NSAssert(masterChain.depth == 0, @"");
        NSAssert(masterChain.index == 0, @"");
        NSAssert(masterChain.isHardened == NO, @"");
        
        NSAssert([@"xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8" isEqualToString:BTCBase58CheckStringWithData(masterChain.extendedPublicKey)], @"");
        NSAssert([@"xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" isEqualToString:BTCBase58CheckStringWithData(masterChain.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:masterChain];
        
        BTCKeychain* m0prv = [masterChain derivedKeychainAtIndex:0 hardened:YES];
        
        NSAssert(m0prv.parentFingerprint != 0, @"");
        NSAssert(m0prv.depth == 1, @"");
        NSAssert(m0prv.index == 0, @"");
        NSAssert(m0prv.isHardened == YES, @"");

        NSAssert([@"xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw" isEqualToString:BTCBase58CheckStringWithData(m0prv.extendedPublicKey)], @"");
        NSAssert([@"xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7" isEqualToString:BTCBase58CheckStringWithData(m0prv.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0prv];

        BTCKeychain* m0prv1pub = [m0prv derivedKeychainAtIndex:1];
        
        NSAssert(m0prv1pub.parentFingerprint != 0, @"");
        NSAssert(m0prv1pub.depth == 2, @"");
        NSAssert(m0prv1pub.index == 1, @"");
        NSAssert(m0prv1pub.isHardened == NO, @"");

        NSAssert([@"xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub.extendedPublicKey)], @"");
        NSAssert([@"xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0prv1pub];

        BTCKeychain* m0prv1pub2prv = [m0prv1pub derivedKeychainAtIndex:2 hardened:YES];
        NSAssert([@"xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv.extendedPublicKey)], @"");
        NSAssert([@"xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0prv1pub2prv];
        
        BTCKeychain* m0prv1pub2prv2pub = [m0prv1pub2prv derivedKeychainAtIndex:2];
        NSAssert([@"xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv2pub.extendedPublicKey)], @"");
        NSAssert([@"xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv2pub.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0prv1pub2prv2pub];
        
        BTCKeychain* m0prv1pub2prv2pub1Gpub = [m0prv1pub2prv2pub derivedKeychainAtIndex:1000000000];
        NSAssert([@"xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv2pub1Gpub.extendedPublicKey)], @"");
        NSAssert([@"xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76" isEqualToString:BTCBase58CheckStringWithData(m0prv1pub2prv2pub1Gpub.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0prv1pub2prv2pub1Gpub];
    }

    
    // Test Vector 2
    /*
     Master (hex): fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
     * [Chain m]
     * ext pub: xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB
     * ext prv: xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
     * [Chain m/0]
     * ext pub: xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH
     * ext prv: xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt
     * [Chain m/0/2147483647']
     * ext pub: xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a
     * ext prv: xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9
     * [Chain m/0/2147483647'/1]
     * ext pub: xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon
     * ext prv: xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef
     * [Chain m/0/2147483647'/1/2147483646']
     * ext pub: xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL
     * ext prv: xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc
     * [Chain m/0/2147483647'/1/2147483646'/2]
     * ext pub: xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt
     * ext prv: xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j
     */
    {
        NSData* seed = BTCDataWithHexCString("fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542");
        
        BTCKeychain* masterChain = [[BTCKeychain alloc] initWithSeed:seed];
        
        NSAssert([@"xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB" isEqualToString:BTCBase58CheckStringWithData(masterChain.extendedPublicKey)], @"");
        NSAssert([@"xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U" isEqualToString:BTCBase58CheckStringWithData(masterChain.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:masterChain];
        
        BTCKeychain* m0pub = [masterChain derivedKeychainAtIndex:0];
        NSAssert([@"xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH" isEqualToString:BTCBase58CheckStringWithData(m0pub.extendedPublicKey)], @"");
        NSAssert([@"xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt" isEqualToString:BTCBase58CheckStringWithData(m0pub.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0pub];

        BTCKeychain* m0pubFFprv = [m0pub derivedKeychainAtIndex:2147483647 hardened:YES];
        NSAssert([@"xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv.extendedPublicKey)], @"");
        NSAssert([@"xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0pubFFprv];

        BTCKeychain* m0pubFFprv1 = [m0pubFFprv derivedKeychainAtIndex:1];
        NSAssert([@"xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1.extendedPublicKey)], @"");
        NSAssert([@"xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0pubFFprv1];
        
        BTCKeychain* m0pubFFprv1pubFEprv = [m0pubFFprv1 derivedKeychainAtIndex:2147483646 hardened:YES];
        NSAssert([@"xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1pubFEprv.extendedPublicKey)], @"");
        NSAssert([@"xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1pubFEprv.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0pubFFprv1pubFEprv];
        
        BTCKeychain* m0pubFFprv1pubFEprv2 = [m0pubFFprv1pubFEprv derivedKeychainAtIndex:2];
        NSAssert([@"xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1pubFEprv2.extendedPublicKey)], @"");
        NSAssert([@"xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j" isEqualToString:BTCBase58CheckStringWithData(m0pubFFprv1pubFEprv2.extendedPrivateKey)], @"");
        
        [self testDeserializationWithKeychain:m0pubFFprv1pubFEprv2];
        
        
    }

}

+ (void) testDeserializationWithKeychain:(BTCKeychain*)keychain
{
    BTCKeychain* pubchain = [[BTCKeychain alloc] initWithExtendedKey:keychain.extendedPublicKey];
    BTCKeychain* prvchain = [[BTCKeychain alloc] initWithExtendedKey:keychain.extendedPrivateKey];
    
    NSAssert(![pubchain isEqual:keychain], @"Public-only chain is not equal to private chain with the same parameters");
    NSAssert([prvchain isEqual:keychain], @"Private chain is equal to private chain with the same parameters");
    NSAssert([prvchain.extendedPublicKey isEqual:pubchain.extendedPublicKey], @"Private and public chains should have the same extended public keys");
    
    NSAssert([[prvchain keyAtIndex:123] isEqual:[pubchain keyAtIndex:123]], @"both chains should be able to derive the same key");
}

@end
