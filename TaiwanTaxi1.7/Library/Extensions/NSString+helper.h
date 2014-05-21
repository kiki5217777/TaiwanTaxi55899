//
//  NSString+helper.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)

- (NSString *)urlEncodedVersion;

+ (NSString *)generateUUID;

+ (NSString *)generateUUIDShort;

+ (NSString *)generateTimeBasedID;

@end
