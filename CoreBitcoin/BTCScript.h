// Oleg Andreev <oleganza@gmail.com>

#import <Foundation/Foundation.h>

@interface BTCScript : NSObject

- (id) initWithData:(NSData*)data;

// Initializes script with space-separated hex-encoded commands and data.
- (id) initWithString:(NSString*)string;

// Binary representation
- (NSData*) data;

// Space-separated hex-encoded commands and data.
- (NSString*) string;

@end
