//
//  OrderManager.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaxiOrder.h"
#import "OrderInfo.h"
#import "PickupInfo.h"
#import "CustomerInfo.h"
#import "Favorite.h"
#import "ReviewInfo.h"
#import "FaceInfo.h"


typedef enum {
    OrderStatusDefault = 0,
    OrderStatusInitialized,
    OrderStatusWaitingToSubmit,
    OrderStatusSubmitted,
    OrderStatusUserCancelled,
    OrderStatusUserCancelledSuccessful,
    OrderStatusUserCancelledFailure,
    OrderStatusSubmittedSuccessful,
    OrderStatusSubmittedFailure,
    OrderStatusCompleted,
}OrderStatus;

typedef enum {
    OrderPaymentTypeNotSpecified = -1,
    OrderPaymentTypeCash = 0,
    OrderPaymentTypeCreditCard = 1,
    OrderPaymentTypeVoucher = 2,
}OrderPayment;

typedef enum {
    OrderTypeNow = 0,
    OrderTypeReserve,
}OrderType;

typedef enum {
    OrderEffectSuccess = 0,
    OrderEffectNoTaxiAvailable,
}OrderEffect;

typedef enum {
    ReviewStatusDefault = 0,
    ReviewStatusLocal,
    ReviewStatusSubmitted,
    ReviewStatusSubmittedSuccessful,
    ReviewStatusSubmittedFailure,
}ReviewStatus;


@interface OrderManager : NSObject
{
    
}

@property (nonatomic, retain) NSManagedObjectContext *context;

+ (OrderManager *)sharedInstance;

- (TaxiOrder *)getOrderIfExistWithOrderID:(NSString *)orderID;
- (TaxiOrder *)createTaxiOrderWithOrderID:(NSString *)orderID;
- (TaxiOrder *)getOrCreateTaxiOrderWithOrderID:(NSString *)orderID;
- (void)removeOrderWithOrderID:(NSString *)orderID;
- (NSError *)save;
- (NSString *)generateOrderID;

- (ReviewInfo *)createReviewInfo;

- (NSString *)createFormattedAddressString:(TaxiOrder *)order;
- (NSString *)createFullAddressString:(id)obj;
- (NSString *)createSpecOrderString:(TaxiOrder *)order;

- (Favorite *)createFavorite;

- (TaxiOrder *)getLastTaxiOrderIfExists;


//edited by kiki Huang 2014.02.06
- (FaceInfo *)createFaceInfo;

@end
