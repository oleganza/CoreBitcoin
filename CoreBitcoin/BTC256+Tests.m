// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTC256+Tests.h"
#import "BTC256.h"
#import "BTCData.h"

void BTC256TestChunkSize()
{
    NSCAssert(sizeof(BTC160) == 20, @"160-bit struct should by 160 bit long");
    NSCAssert(sizeof(BTC256) == 32, @"256-bit struct should by 256 bit long");
    NSCAssert(sizeof(BTC512) == 64, @"512-bit struct should by 512 bit long");
}

void BTC256TestNull()
{
    NSCAssert([NSStringFromBTC160(BTC160Null) isEqual:@"82963d5edd842f1e6bd2b6bc2e9a97a40a7d8652"], @"null hash should be correct");
    NSCAssert([NSStringFromBTC256(BTC256Null) isEqual:@"d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e"], @"null hash should be correct");
    NSCAssert([NSStringFromBTC512(BTC512Null) isEqual:@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f0363e01b5d7a53c4a2e5a76d283f3e4a04d28ab54849c6e3e874ca31128bcb759e1"], @"null hash should be correct");
}

void BTC256TestOne()
{
    BTC256 one = BTC256Zero;
    one.words64[0] = 1;
    NSCAssert([NSStringFromBTC256(one) isEqual:@"0100000000000000000000000000000000000000000000000000000000000000"], @"");
}

void BTC256TestEqual()
{
    NSCAssert(BTC256Equal(BTC256Null, BTC256Null), @"equal");
    NSCAssert(BTC256Equal(BTC256Zero, BTC256Zero), @"equal");
    NSCAssert(BTC256Equal(BTC256Max,  BTC256Max),  @"equal");
    
    NSCAssert(!BTC256Equal(BTC256Zero, BTC256Null), @"not equal");
    NSCAssert(!BTC256Equal(BTC256Zero, BTC256Max),  @"not equal");
    NSCAssert(!BTC256Equal(BTC256Max,  BTC256Null), @"not equal");
}

void BTC256TestCompare()
{
    NSCAssert(BTC256Compare(BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
                            BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSOrderedSame, @"ordered same");

    NSCAssert(BTC256Compare(BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f035"),
                            BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSOrderedAscending, @"ordered asc");
    
    NSCAssert(BTC256Compare(BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f037"),
                            BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSOrderedDescending, @"ordered asc");

    NSCAssert(BTC256Compare(BTC256FromNSString(@"61ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
                            BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSOrderedAscending, @"ordered same");

    NSCAssert(BTC256Compare(BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036"),
                            BTC256FromNSString(@"61ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036")) == NSOrderedDescending, @"ordered same");

}

void BTC256TestInverse()
{
    BTC256 chunk = BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036");
    BTC256 chunk2 = BTC256Inverse(chunk);
    
    NSCAssert(!BTC256Equal(chunk, chunk2), @"not equal");
    NSCAssert(BTC256Equal(chunk, BTC256Inverse(chunk2)), @"equal");
    
    NSCAssert(chunk2.words64[0] == ~chunk.words64[0], @"bytes are inversed");
    NSCAssert(chunk2.words64[1] == ~chunk.words64[1], @"bytes are inversed");
    NSCAssert(chunk2.words64[2] == ~chunk.words64[2], @"bytes are inversed");
    NSCAssert(chunk2.words64[3] == ~chunk.words64[3], @"bytes are inversed");
    
    NSCAssert(BTC256Equal(BTC256Zero, BTC256AND(chunk, chunk2)), @"(a & ~a) == 000000...");
    NSCAssert(BTC256Equal(BTC256Max, BTC256OR(chunk, chunk2)), @"(a | ~a) == 111111...");
    NSCAssert(BTC256Equal(BTC256Max, BTC256XOR(chunk, chunk2)), @"(a ^ ~a) == 111111...");
}

void BTC256TestSwap()
{
    BTC256 chunk = BTC256FromNSString(@"62ce64dd92836e6e99d83eee3f623652f6049cf8c22272f295b262861738f036");
    BTC256 chunk2 = BTC256Swap(chunk);
    NSCAssert([BTCReversedData(NSDataFromBTC256(chunk)) isEqual:NSDataFromBTC256(chunk2)], @"swap should reverse all bytes");
    
    NSCAssert(chunk2.words64[0] == OSSwapConstInt64(chunk.words64[3]), @"swap should reverse all bytes");
    NSCAssert(chunk2.words64[1] == OSSwapConstInt64(chunk.words64[2]), @"swap should reverse all bytes");
    NSCAssert(chunk2.words64[2] == OSSwapConstInt64(chunk.words64[1]), @"swap should reverse all bytes");
    NSCAssert(chunk2.words64[3] == OSSwapConstInt64(chunk.words64[0]), @"swap should reverse all bytes");
}

void BTC256TestAND()
{
    NSCAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Max),  BTC256Max),  @"1 & 1 == 1");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Zero), BTC256Zero), @"1 & 0 == 0");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Zero, BTC256Max),  BTC256Zero), @"0 & 1 == 0");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Zero, BTC256Null), BTC256Zero), @"0 & x == 0");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Null, BTC256Zero), BTC256Zero), @"x & 0 == 0");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Max,  BTC256Null), BTC256Null), @"1 & x == x");
    NSCAssert(BTC256Equal(BTC256AND(BTC256Null, BTC256Max),  BTC256Null), @"x & 1 == x");
}

void BTC256TestOR()
{
    NSCAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Max),  BTC256Max),  @"1 | 1 == 1");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Zero), BTC256Max),  @"1 | 0 == 1");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Zero, BTC256Max),  BTC256Max),  @"0 | 1 == 1");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Zero, BTC256Null), BTC256Null), @"0 | x == x");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Null, BTC256Zero), BTC256Null), @"x | 0 == x");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Max,  BTC256Null), BTC256Max),  @"1 | x == 1");
    NSCAssert(BTC256Equal(BTC256OR(BTC256Null, BTC256Max),  BTC256Max),  @"x | 1 == 1");
}

void BTC256TestXOR()
{
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Max),  BTC256Zero),  @"1 ^ 1 == 0");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Zero), BTC256Max),  @"1 ^ 0 == 1");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Zero, BTC256Max),  BTC256Max),  @"0 ^ 1 == 1");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Zero, BTC256Null), BTC256Null), @"0 ^ x == x");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Null, BTC256Zero), BTC256Null), @"x ^ 0 == x");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Max,  BTC256Null), BTC256Inverse(BTC256Null)),  @"1 ^ x == ~x");
    NSCAssert(BTC256Equal(BTC256XOR(BTC256Null, BTC256Max),  BTC256Inverse(BTC256Null)),  @"x ^ 1 == ~x");
}

void BTC256TestConcat()
{
    BTC512 concat = BTC512Concat(BTC256Null, BTC256Max);
    NSCAssert([NSStringFromBTC512(concat) isEqual:@"d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e"
               "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"], @"should concatenate properly");
    
    concat = BTC512Concat(BTC256Max, BTC256Null);
    NSCAssert([NSStringFromBTC512(concat) isEqual:@"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
               "d1007a1fe826e95409e21595845f44c3b9411d5285b6b5982285aabfa5999a5e"], @"should concatenate properly");
    
}

void BTC256TestConvertToData()
{
    // TODO...
}

void BTC256TestConvertToString()
{
    // Too short string should yield null value.
    BTC256 chunk = BTC256FromNSString(@"000095409e215952"
                                       "85b6b5982285aabf"
                                       "a5999a5e845f44c3"
                                       "b9411d5d1007a1");
    NSCAssert(BTC256Equal(chunk, BTC256Null), @"too short string => null");
    
    chunk = BTC256FromNSString(@"000095409e215952"
                                "85b6b5982285aabf"
                                "a5999a5e845f44c3"
                                "b9411d5d1007a1b166");
    NSCAssert(chunk.words64[0] == OSSwapBigToHostConstInt64(0x000095409e215952), @"parse correctly");
    NSCAssert(chunk.words64[1] == OSSwapBigToHostConstInt64(0x85b6b5982285aabf), @"parse correctly");
    NSCAssert(chunk.words64[2] == OSSwapBigToHostConstInt64(0xa5999a5e845f44c3), @"parse correctly");
    NSCAssert(chunk.words64[3] == OSSwapBigToHostConstInt64(0xb9411d5d1007a1b1), @"parse correctly");
    
    NSCAssert([NSStringFromBTC256(chunk) isEqual:@"000095409e215952"
                                                  "85b6b5982285aabf"
                                                  "a5999a5e845f44c3"
                                                  "b9411d5d1007a1b1"], @"should serialize to the same string");
}


void BTC256RunAllTests()
{
    BTC256TestChunkSize();
    BTC256TestNull();
    BTC256TestOne();
    BTC256TestEqual();
    BTC256TestCompare();
    BTC256TestInverse();
    BTC256TestSwap();
    BTC256TestAND();
    BTC256TestOR();
    BTC256TestXOR();
    BTC256TestConcat();
    BTC256TestConvertToData();
    BTC256TestConvertToString();
}

