//
//  TaxiOrder.h
//  TaiwanTaxi
//
//  Created by jason on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CustomerInfo, OrderInfo, PickupInfo, ReviewInfo;

@interface TaxiOrder : NSManagedObject

@property (nonatomic, retain) NSDate * bookTime;
@property (nonatomic, retain) NSNumber * callType;
@property (nonatomic, retain) NSString * carNumber;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * effect;
@property (nonatomic, retain) NSString * eta;
@property (nonatomic, retain) NSString * exception;
@property (nonatomic, retain) NSNumber * isGeocoded;
@property (nonatomic, retain) NSString * jobID;
@property (nonatomic, retain) NSString * orderID;
@property (nonatomic, retain) NSNumber * orderStatus;
@property (nonatomic, retain) NSString * returnCode;
@property (nonatomic, retain) CustomerInfo *customerInfo;
@property (nonatomic, retain) OrderInfo *orderInfo;
@property (nonatomic, retain) PickupInfo *pickupInfo;
@property (nonatomic, retain) ReviewInfo *reviewInfo;
@property (nonatomic, retain) NSNumber * markDelete;

@end
