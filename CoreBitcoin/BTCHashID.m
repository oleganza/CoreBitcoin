// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import "BTCHashID.h"
#import "BTCData.h"

NSData* BTCHashFromID(NSString* identifier)
{
    return BTCReversedData(BTCDataWithHexString(identifier));
}

NSString* BTCIDFromHash(NSData* hash)
{
    return BTCHexStringFromData(BTCReversedData(hash));
}
