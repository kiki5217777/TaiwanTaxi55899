//
//  OrderManager.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "OrderManager.h"
#import "AppDelegate.h"

#import "NSString+helper.h"

static OrderManager *singletonManager = nil;


@implementation OrderManager

#pragma mark - define

#pragma mark - synthesize

@synthesize context;

- (NSManagedObjectContext *)context
{
    if(context == nil)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        context = [delegate.managedObjectContext retain];
    }
    return context;
}

#pragma mark - dealloc

- (void)dealloc
{
    [context release];
    [super dealloc];
}

#pragma mark - order related methods

- (TaxiOrder *)getOrderIfExistWithOrderID:(NSString *)orderID
{
    if(orderID.length == 0)
        return nil;
    
    TaxiOrder *order = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"TaxiOrder" 
                                 inManagedObjectContext:self.context];
	request.predicate = [NSPredicate predicateWithFormat:@"orderID = %@", orderID];
    request.includesPendingChanges = YES;
	
	NSError *error = nil;
	order = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
    
    if(error)
        return nil;
	
	return order;
}

- (TaxiOrder *)createTaxiOrderWithOrderID:(NSString *)orderID
{
    TaxiOrder *o = [NSEntityDescription insertNewObjectForEntityForName:@"TaxiOrder" 
                                                 inManagedObjectContext:self.context];
    o.orderID = orderID;
    o.createdDate = [NSDate date];
    o.orderStatus = [NSNumber numberWithInt:OrderStatusDefault];
    o.isGeocoded = [NSNumber numberWithBool:NO];
    o.callType = [NSNumber numberWithInt:OrderTypeNow];
    o.bookTime = [NSDate date];
    o.returnCode = @"";
    o.exception = @"";
    o.jobID = @"";
    o.effect = [NSNumber numberWithInt:OrderEffectNoTaxiAvailable];
    o.carNumber = @"";
    o.eta = @"";
    
    OrderInfo *orderInfo = [NSEntityDescription insertNewObjectForEntityForName:@"OrderInfo" 
                                                         inManagedObjectContext:self.context];
    orderInfo.paidType = [NSNumber numberWithInt:OrderPaymentTypeCash];
    orderInfo.hasLuggage = [NSNumber numberWithBool:NO];
    orderInfo.hasPet = [NSNumber numberWithBool:NO];
    orderInfo.hasWheelChair = [NSNumber numberWithBool:NO];
    orderInfo.isDrunk = [NSNumber numberWithBool:NO];
    orderInfo.memo = @"";
    orderInfo.specOrder = @"00000000";
    
    o.orderInfo = orderInfo;
    
    PickupInfo *pickupInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PickupInfo" 
                                                           inManagedObjectContext:self.context];
    pickupInfo.formattedAddress = @"";
    pickupInfo.fullAddress = @"";
    pickupInfo.region = @"";
    pickupInfo.district = @"";
    pickupInfo.road = @"";
    pickupInfo.section = @"";
    pickupInfo.alley = @"";
    pickupInfo.lane = @"";
    pickupInfo.number = @"";
    pickupInfo.lat = [NSNumber numberWithDouble:0.0];
    pickupInfo.lon = [NSNumber numberWithDouble:0.0];
    pickupInfo.landmark = @"";
    
    o.pickupInfo = pickupInfo;
    
    CustomerInfo *customerInfo = [NSEntityDescription insertNewObjectForEntityForName:@"CustomerInfo" 
                                                               inManagedObjectContext:self.context];
    customerInfo.name = @"";
    customerInfo.title = @"";
    customerInfo.tel = @"";
    
    o.customerInfo = customerInfo;
    
    o.reviewInfo = [self createReviewInfo];
    
    return o;
}

- (TaxiOrder *)getOrCreateTaxiOrderWithOrderID:(NSString *)orderID
{
    TaxiOrder *order = [self getOrderIfExistWithOrderID:orderID];
    
    if(order == nil) {
        order = [self createTaxiOrderWithOrderID:orderID];
    }
    
    return order;
}

- (void)removeOrderWithOrderID:(NSString *)orderID
{
    TaxiOrder *order = [self getOrderIfExistWithOrderID:orderID];
    
    if(order)
        [self.context deleteObject:order];
}

- (NSError *)save
{
    NSError *error = nil;
    [self.context save:&error];
    
    return error;
}

- (NSString *)generateOrderID
{
    return [NSString generateUUIDShort];
}

- (ReviewInfo *)createReviewInfo
{
    ReviewInfo *reviewInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ReviewInfo"
                                                           inManagedObjectContext:self.context];
    reviewInfo.rating = [NSNumber numberWithInt:5];
    reviewInfo.note = @"";
    reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusDefault];
    
    return reviewInfo;
}

- (Favorite *)createFavorite
{
    Favorite *f = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" 
                                                inManagedObjectContext:self.context];
    f.addedDate = [NSDate date];
    return f;
}

//edited by kiki Huang 2014.02.06
- (FaceInfo *)createFaceInfo {
    FaceInfo *f = [NSEntityDescription insertNewObjectForEntityForName:@"FaceInfo"
                                                inManagedObjectContext:self.context];
    return f;
}

- (TaxiOrder *)getLastTaxiOrderIfExists
{
    TaxiOrder *order = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"TaxiOrder"
                                 inManagedObjectContext:self.context];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]];
    request.includesPendingChanges = YES;
    request.fetchLimit = 1;
	
	NSError *error = nil;
	order = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
    
    if(error)
        return nil;
	
	return order;
}

#pragma mark - helper

// this is the format for address required by the API service
- (NSString *)createFormattedAddressString:(TaxiOrder *)order
{
    NSMutableString *str = [NSMutableString string];
    PickupInfo *info = order.pickupInfo;
    
    [str appendFormat:@"%@&", info.region];
    [str appendFormat:@"%@&", info.district];
    [str appendFormat:@"%@&", info.road];
    
    if(info.section.length)
        [str appendFormat:@"%@段&", info.section];
    else
        [str appendFormat:@"%@&", info.section];
    
    if(info.alley.length)
        [str appendFormat:@"%@巷&", info.alley];
    else
        [str appendFormat:@"%@&", info.alley];
    
    if(info.lane.length)
        [str appendFormat:@"%@弄&", info.lane];
    else
        [str appendFormat:@"%@&", info.lane];
    
    if(info.number.length)
        [str appendFormat:@"%@號", info.number];
    else
        [str appendFormat:@"%@", info.number];
    
    return str;
}

// just the full address string, to be used for things like google map api
- (NSString *)createFullAddressString:(id)obj
{
    NSMutableString *str = [NSMutableString string];
    
    if([obj isKindOfClass:[TaxiOrder class]] == YES)
    {
        TaxiOrder *order = (TaxiOrder *)obj;
        PickupInfo *info = order.pickupInfo;
        
        [str appendFormat:@"%@", info.region];
        if(info.district.length)
            [str appendFormat:@"%@", info.district];
        [str appendFormat:@"%@", info.road];
        
        if(info.section.length)
            [str appendFormat:@"%@段", info.section];
        else
            [str appendFormat:@"%@", info.section];
        
        if(info.alley.length)
            [str appendFormat:@"%@巷", info.alley];
        else
            [str appendFormat:@"%@", info.alley];
        
        if(info.lane.length)
            [str appendFormat:@"%@弄", info.lane];
        else
            [str appendFormat:@"%@", info.lane];
        
        if(info.number.length)
            [str appendFormat:@"%@號", info.number];
        else
            [str appendFormat:@"%@", info.number];
        
        
    }
    else if([obj isKindOfClass:[Favorite class]] == YES)
    {
        Favorite *info = (Favorite *)obj;
        
        [str appendFormat:@"%@", info.region];
        [str appendFormat:@"%@", info.district];
        [str appendFormat:@"%@", info.road];
        
        if(info.section.length)
            [str appendFormat:@"%@段", info.section];
        else
            [str appendFormat:@"%@", info.section];
        
        if(info.alley.length)
            [str appendFormat:@"%@巷", info.alley];
        else
            [str appendFormat:@"%@", info.alley];
        
        if(info.lane.length)
            [str appendFormat:@"%@弄", info.lane];
        else
            [str appendFormat:@"%@", info.lane];
        
        if(info.number.length)
            [str appendFormat:@"%@號", info.number];
        else
            [str appendFormat:@"%@", info.number];
    }
    
    return str;
}

- (NSString *)createSpecOrderString:(TaxiOrder *)order
{
    //SpecOrder  特殊需求固定為已 0 與 1 組成的八碼字串：0 開行李箱，1 攜帶寵物，2 攜帶輪椅，6 使用乘車卷，7 酒後代駕，其餘為 0。
    
    NSMutableString *str = [NSMutableString string];
    OrderInfo *info = order.orderInfo;
    
    if(info.hasLuggage.boolValue)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(info.hasPet.boolValue)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(info.hasWheelChair.boolValue)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    [str appendString:@"000"];
    
    if(info.hasVoucher.boolValue)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(info.isDrunk.boolValue)
        [str appendString:@"0"]; // support for designated driver is not supported for now
    else
        [str appendString:@"0"];
    
    return str;
}


#pragma mark - singleton implementation code

+ (OrderManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static OrderManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}

@end
