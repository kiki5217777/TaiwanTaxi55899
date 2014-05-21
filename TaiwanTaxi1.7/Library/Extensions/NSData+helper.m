//
//  NSData+helper.m
//  TaiwanTaxi
//
//  Created by jason on 8/14/12.
//
//

#import "NSData+helper.h"

@implementation NSData (helper)

- (NSString *)hexString {
	NSMutableString *str = [NSMutableString stringWithCapacity:64];
	int length = [self length];
	char *bytes = malloc(sizeof(char) * length);
	
	[self getBytes:bytes length:length];
	
	int i = 0;
	
	for (; i < length; i++) {
		[str appendFormat:@"%02.2hhx", bytes[i]];
	}
	free(bytes);
	
	return str;
}

@end
