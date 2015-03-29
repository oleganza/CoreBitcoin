// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"

// Interface to BIP70 payment protocol.
// Spec: https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
//
// * BTCPaymentProtocol implements high-level request and response API.
// * BTCPaymentRequest object that represents "PaymentRequest" as described in BIP70.
// * BTCPaymentDetails object that represents "PaymentDetails" as described in BIP70.
// * BTCPayment object that represents "Payment" as described in BIP70.
// * BTCPaymentACK object that represents "PaymentACK" as described in BIP70.

extern NSInteger const BTCPaymentRequestVersion1;

extern NSString* const BTCPaymentRequestPKITypeNone;
extern NSString* const BTCPaymentRequestPKITypeX509SHA1;
extern NSString* const BTCPaymentRequestPKITypeX509SHA256;

// Special value indicating that amount on the output is not specified.
extern BTCAmount const BTCUnspecifiedPaymentAmount;

// Status allows to correctly display information about security of the request to the user.
typedef NS_ENUM(NSInteger, BTCPaymentRequestStatus) {
    // Payment request is valid and the user can trust it.
    BTCPaymentRequestStatusValid                 = 0, // signed with a valid and known certificate.

    // These allow Payment Request to be accepted with a warning to the user.
    BTCPaymentRequestStatusUnsigned              = 101, // PKI type is "none"
    BTCPaymentRequestStatusUnknown               = 102, // PKI type is unknown (for forward compatibility may allow sending or warn to upgrade).

    // These generally mean we should decline the Payment Request.
    BTCPaymentRequestStatusExpired               = 201,
    BTCPaymentRequestStatusInvalidSignature      = 202,
    BTCPaymentRequestStatusMissingCertificate    = 203,
    BTCPaymentRequestStatusUntrustedCertificate  = 204,
};

@class BTCNetwork;
@class BTCPayment;
@class BTCPaymentACK;
@class BTCPaymentRequest;
@class BTCPaymentDetails;
@class BTCTransaction;

@interface BTCPaymentProtocol : NSObject

// Convenience API

// Loads a BTCPaymentRequest object from a given URL.
+ (void) loadPaymentRequestFromURL:(NSURL*)paymentRequestURL completionHandler:(void(^)(BTCPaymentRequest* pr, NSError* error))completionHandler;

// Posts completed payment object to a given payment URL (provided in BTCPaymentDetails) and
// returns a PaymentACK object.
+ (void) postPayment:(BTCPayment*)payment URL:(NSURL*)paymentURL completionHandler:(void(^)(BTCPaymentACK* ack, NSError* error))completionHandler;


// Low-level API
// (use these if you have your own connection queue).

+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL; // default timeout is 10 sec
+ (NSURLRequest*) requestForPaymentRequestWithURL:(NSURL*)paymentRequestURL timeout:(NSTimeInterval)timeout;
+ (BTCPaymentRequest*) paymentRequestFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut;

+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL; // default timeout is 10 sec
+ (NSURLRequest*) requestForPayment:(BTCPayment*)payment url:(NSURL*)paymentURL timeout:(NSTimeInterval)timeout;
+ (BTCPaymentACK*) paymentACKFromData:(NSData*)data response:(NSURLResponse*)response error:(NSError**)errorOut;

@end

// Payment requests are split into two messages to support future extensibility.
// The bulk of the information is contained in the PaymentDetails message.
// It is wrapped inside a PaymentRequest message, which contains meta-information
// about the merchant and a digital signature.
@interface BTCPaymentRequest : NSObject

// Version of the payment request and payment details.
// Default is BTCPaymentRequestVersion1.
@property(nonatomic, readonly) NSInteger version;

// Public-key infrastructure (PKI) system being used to identify the merchant.
// All implementation should support "none", "x509+sha256" and "x509+sha1".
// See BTCPaymentRequestPKIType* constants.
@property(nonatomic, readonly) NSString* pkiType;

// PKI-system data that identifies the merchant and can be used to create a digital signature.
// In the case of X.509 certificates, pki_data contains one or more X.509 certificates.
// Depends on pkiType. Optional.
@property(nonatomic, readonly) NSData* pkiData;

// A BTCPaymentDetails object.
@property(nonatomic, readonly) BTCPaymentDetails* details;

// Digital signature over a hash of the protocol buffer serialized variation of
// the PaymentRequest message, with all serialized fields serialized in numerical order
// (all current protocol buffer implementations serialize fields in numerical order) and
// signed using the private key that corresponds to the public key in pki_data.
// Optional fields that are not set are not serialized (however, setting a field to its default value will cause it to be serialized and will affect the signature).
// Before serialization, the signature field must be set to an empty value so that
// the field is included in the signed PaymentRequest hash but contains no data.
@property(nonatomic, readonly) NSData* signature;

// Array of DER encoded certificates or nil if pkiType does offer certificates.
// This list is extracted from raw `pkiData`.
// If set, certificates are cerialized in X509Certificates object and set to pkiData.
@property(nonatomic, readonly) NSArray* certificates;

// Returns YES if payment request is correctly signed by a trusted certificate if needed
// and expiration date is valid.
// Accessing this property also updates `status` and `signerName`.
@property(nonatomic, readonly) BOOL isValid;

// Human-readable name of the signer or nil if it's unsigned.
// You should display this to the user as a name of the merchant.
// Accessing this property also updates `status` and `isValid`.
@property(nonatomic, readonly) NSString* signerName;

// Validation status.
// Accessing this property also updates `commonName` and `isValid`.
@property(nonatomic, readonly) BTCPaymentRequestStatus status;

// Binary serialization in protocol buffer format.
@property(nonatomic, readonly) NSData* data;

- (id) initWithData:(NSData*)data;

- (BTCPayment*) paymentWithTransaction:(BTCTransaction*)tx;

- (BTCPayment*) paymentWithTransactions:(NSArray*)txs memo:(NSString*)memo;

@end

@interface BTCPaymentDetails : NSObject

// Mainnet or testnet. Default is mainnet.
@property(nonatomic, readonly) BTCNetwork* network;

// Array of transaction outputs storing `value` in satoshis and `script` where payment should be sent.
// Unspecified amounts are set to BTC_MAX_MONEY so you can know if zero amount was actually specified (e.g. for OP_RETURN or proof-of-burn etc).
@property(nonatomic, readonly) NSArray* /*[BTCTransactionOutput]*/ outputs;

// Date when the PaymentRequest was created.
@property(nonatomic, readonly) NSDate* date;

// Date after which the PaymentRequest should be considered invalid.
@property(nonatomic, readonly) NSDate* expirationDate;

// Plain-text (no formatting) note that should be displayed to the customer, explaining what this PaymentRequest is for.
@property(nonatomic, readonly) NSString* memo;

// Secure location (usually https) where a Payment message (see below) may be sent to obtain a PaymentACK.
// The payment_url specified in the PaymentDetails should remain valid at least until the PaymentDetails expires
// (or as long as possible if the PaymentDetails does not expire).
// Note that this is irrespective of any state change in the underlying payment request;
// for example cancellation of an order should not invalidate the payment_url,
// as it is important that the merchant's server can record mis-payments in order to refund the payment.
@property(nonatomic, readonly) NSURL* paymentURL;

// Arbitrary data that may be used by the merchant to identify the PaymentRequest.
// May be omitted if the merchant does not need to associate Payments with PaymentRequest or
// if they associate each PaymentRequest with a separate payment address.
@property(nonatomic, readonly) NSData* merchantData;

// Binary serialization in protocol buffer format.
@property(nonatomic, readonly) NSData* data;

- (id) initWithData:(NSData*)data;

@end

// Payment messages are sent after the customer has authorized payment.
@interface BTCPayment : NSObject

// Should be copied from PaymentDetails.merchant_data.
// Merchants may use invoice numbers or any other data they require
// to match Payments to PaymentRequests.
@property(nonatomic, readonly) NSData* merchantData;

// One or more valid, signed Bitcoin transactions that fully pay the PaymentRequest
@property(nonatomic, readonly) NSArray* /*[BTCTransaction]*/ transactions;

// Output scripts and amounts. Amounts are optional and can be zero.
@property(nonatomic, readonly) NSArray* /*[BTCTransactionOutput]*/ refundOutputs;

// Plain-text note from the customer to the merchant.
@property(nonatomic, readonly) NSString* memo;

// Binary serialization in protocol buffer format.
@property(nonatomic, readonly) NSData* data;

- (id) initWithData:(NSData*)data;

@end

// PaymentACK is the final message in the payment protocol;
// it is sent from the merchant's server to the bitcoin wallet in response to a Payment message.
@interface BTCPaymentACK : NSObject

// Copy of the Payment message that triggered this PaymentACK.
// Clients may ignore this if they implement another way of associating Payments with PaymentACKs.
@property(nonatomic, readonly) BTCPayment* payment;

// Note that should be displayed to the customer giving the status of the transaction
// (e.g. "Payment of 1 BTC for eleven tribbles accepted for processing.")
@property(nonatomic, readonly) NSString* memo;

// Binary serialization in protocol buffer format.
@property(nonatomic, readonly) NSData* data;

- (id) initWithData:(NSData*)data;

@end