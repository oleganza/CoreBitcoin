#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"

// TODO: support arbitrary keys and values.
// TODO: support handling URL from UIApplicationDelegate.

/*!
 * Class to compose and handle various Bitcoin URLs according to BIP21.
 * See: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
 */
@class BTCAddress;
@interface BTCBitcoinURL : NSObject

/*!
 * Encoded address.
 */
@property(nonatomic) BTCAddress* address;

/*!
 * Amount in satoshis. Default is 0.
 */
@property(nonatomic) BTCAmount amount;

/*!
 * Label. Default is nil.
 */
@property(nonatomic) NSString* label;

/*!
 * Message. Default is nil.
 */
@property(nonatomic) NSString* message;

/*!
 * Payment request URL (r=...). Default is nil.
 */
@property(nonatomic) NSURL* paymentRequestURL;

/*!
 * Complete URL built from the individual properties.
 */
@property(nonatomic, readonly) NSURL* URL;

/*!
 * Returns YES if it has a valid address or paymentRequestURL.
 */
@property(nonatomic, readonly) BOOL isValid;

/*!
 * Makes a URL in form "bitcoin:<address>?amount=1.2345&label=<label>.
 * @param address Address to be rendered in base58 format.
 * @param amount  Amount in satoshis. Note that URI scheme dictates to render this amount as a decimal number in BTC.
 * @param label   Optional label.
 */
+ (NSURL*) URLWithAddress:(BTCAddress*)address amount:(BTCAmount)amount label:(NSString*)label;

/*!
 * Instantiates if URL is a valid bitcoin: URL.
 * To be valid it should either contain a valid address, or payment request URL (r=), or both.
 */
- (id) initWithURL:(NSURL*)url;

/*!
 * Instantiates an empty Bitcoin URL.
 * Fill in address, amount, label and other fields and use `URL` property to get a composed URL.
 */
- (id) init;

@end
