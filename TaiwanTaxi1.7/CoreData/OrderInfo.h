//
//  OrderInfo.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiOrder;

@interface OrderInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * hasLuggage;
@property (nonatomic, retain) NSNumber * hasPet;
@property (nonatomic, retain) NSNumber * hasWheelChair;
@property (nonatomic, retain) NSNumber * hasVoucher;
@property (nonatomic, retain) NSNumber * isDrunk;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * specOrder;
@property (nonatomic, retain) NSNumber * paidType;
@property (nonatomic, retain) TaxiOrder *taxiOrder;

@end
