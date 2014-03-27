//
//  PickupInfo.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiOrder;

@interface PickupInfo : NSManagedObject

@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSString * fullAddress;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSString * road;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * alley;
@property (nonatomic, retain) NSString * lane;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * landmark;
@property (nonatomic, retain) TaxiOrder *taxiOrder;

@end
