//
//  NSString+helper.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

- (NSString *)urlEncodedVersion{
	NSArray *escapeChars = [NSArray arrayWithObjects:
							@" ",@";",@"/",@"?",@":",@"@",@"&",@"=",@"+",@"$",@",",
							@"[",@"]",@"#",@"!",@"'",@"(",@")",@"*", nil];
	NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"%20",@"%3B",@"%2F",@"%3F",@"%3A",@"%40",@"%26",@"%3D",
							 @"%2B",@"%24",@"%2C",@"%5B",@"%5D",@"%23",@"%21",@"%27",
							 @"%28",@"%29",@"%2A",nil];
	NSMutableString *tempStr = [[self mutableCopy] autorelease];
	
    for(int i = 0; i < [escapeChars count]; i++) {
		[tempStr replaceOccurrencesOfString:[escapeChars objectAtIndex:i] 
								 withString:[replaceChars objectAtIndex:i] options:NSLiteralSearch 
									  range:NSMakeRange(0,[tempStr length])];
	}
    
	return [[tempStr copy] autorelease];
}

+ (NSString *)generateUUID
{
	NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = (NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
	
	return [result autorelease];
}

+ (NSString *)generateUUIDShort
{
    return [[[self class] generateUUID] substringToIndex:8];
}

+ (NSString *)generateTimeBasedID
{
    NSDate *date = [NSDate date];
    NSString *str = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    NSRange range;
    range.location = str.length - 8;
    range.length = 8;
    NSString *trimmedID = [str substringWithRange:range];
    
    return trimmedID;
}

@end
