//
//  TaxiOrder.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const TaxiOrderPayByCash;
extern NSString * const TaxiOrderPayByCreditCard;

extern NSString * const TaxiOrderNow;
extern NSString * const TaxiOrderFuture;


@interface TaxiOrderObj : NSObject
{
    
}

@property (nonatomic, retain) NSString * orderID;
@property (nonatomic, retain) NSString * customerTel;
@property (nonatomic, retain) NSString * customerName;
@property (nonatomic, retain) NSString * customerTitle;
@property (nonatomic, retain) NSString * orderType;
@property (nonatomic, retain) NSDate   * orderTime;
@property (nonatomic, retain) NSString * pickupAddress;
@property (nonatomic, retain) NSString * plainAddress;

@property (nonatomic, retain) NSNumber * pickupLat;
@property (nonatomic, retain) NSNumber * pickupLon;

@property (nonatomic, retain) NSString * nearbyLandmark;
@property (nonatomic, retain) NSString * orderMemo;

@property (nonatomic, retain) NSString * paidType;
@property (nonatomic, retain) NSString * specialRequirement;

@property (nonatomic, retain) NSString * addrRegion;
@property (nonatomic, retain) NSString * addrZone;
@property (nonatomic, retain) NSString * addrRoad;
@property (nonatomic, retain) NSString * addrSection;
@property (nonatomic, retain) NSString * addrAlley;
@property (nonatomic, retain) NSString * addrLane;
@property (nonatomic, retain) NSString * addrNumber;

@property (nonatomic, assign) BOOL hasLuggage;
@property (nonatomic, assign) BOOL hasPet;
@property (nonatomic, assign) BOOL hasWheelChair;
@property (nonatomic, assign) BOOL isDrunk;

@property (nonatomic, retain) NSString * validateResultMessage;

- (BOOL)validateOrderParameters;
- (NSString *)generateFormattedAddress;
- (NSString *)generatePlainAddress;
- (NSString *)generateSpecialRequirement;

@end
