//
//  Favorite.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 8/1/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSDate * bookTime;
@property (nonatomic, retain) NSNumber * callType;
@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) NSString * alley;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSString * landmark;
@property (nonatomic, retain) NSString * lane;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * road;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * hasLuggage;
@property (nonatomic, retain) NSNumber * hasPet;
@property (nonatomic, retain) NSNumber * hasWheelChair;
@property (nonatomic, retain) NSNumber * hasVoucher;
@property (nonatomic, retain) NSNumber * isDrunk;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSNumber * paidType;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * displayOrder;

@end
