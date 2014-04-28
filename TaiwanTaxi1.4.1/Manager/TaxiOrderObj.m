//
//  TaxiOrder.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//


NSString * const TaxiOrderPayByCash = @"0";
NSString * const TaxiOrderPayByCreditCard = @"1";

NSString * const TaxiOrderNow = @"0";
NSString * const TaxiOrderFuture = @"1";


#import "TaxiOrderObj.h"

@implementation TaxiOrderObj

@synthesize orderID;
@synthesize customerTel;
@synthesize customerName;
@synthesize customerTitle;
@synthesize orderType;
@synthesize orderTime;
@synthesize pickupAddress;
@synthesize plainAddress;
@synthesize pickupLat;
@synthesize pickupLon;
@synthesize nearbyLandmark;
@synthesize orderMemo;
@synthesize paidType;
@synthesize specialRequirement;
@synthesize validateResultMessage;

@synthesize addrRegion;
@synthesize addrZone;
@synthesize addrRoad;
@synthesize addrSection;
@synthesize addrAlley;
@synthesize addrLane;
@synthesize addrNumber;

@synthesize hasLuggage;
@synthesize hasPet;
@synthesize hasWheelChair;
@synthesize isDrunk;

- (id)init
{
    self = [super init];
    if (self) {
        orderID = @"";
        customerTel = @"";
        customerName = @"";
        customerTitle = @"";
        orderType = @"";
        pickupAddress = @"";
        plainAddress = @"";
        nearbyLandmark = @"";
        orderMemo = @"";
        paidType = @"";
        specialRequirement = @"";
        
        addrRegion = @"";
        addrZone = @"";
        addrRoad = @"";
        addrSection = @"";
        addrAlley = @"";
        addrLane = @"";
        addrNumber = @"";
        
        hasLuggage = NO;
        hasPet = NO;
        hasWheelChair = NO;
        isDrunk = NO;
    }
    return self;
}

- (void)dealloc
{
    [orderID release];
    [customerTel release];
    [customerName release];
    [customerTitle release];
    [orderType release];
    [orderTime release];
    [pickupAddress release];
    [plainAddress release];
    [pickupLat release];
    [pickupLon release];
    [nearbyLandmark release];
    [orderMemo release];
    [paidType release];
    [specialRequirement release];
    [validateResultMessage release];
    
    [addrRegion release];
    [addrZone release];
    [addrRoad release];
    [addrSection release];
    [addrAlley release];
    [addrLane release];
    [addrNumber release];
    
    [super dealloc];
}

- (BOOL)validateOrderParameters
{
    BOOL allGood = YES;
    NSMutableString *msg = [NSMutableString string];
    
    if(!orderID.length)
    {
        allGood = NO;
        [msg appendString:@"OrderID\n"];
    }
    
    if(!customerTel.length)
    {
        allGood = NO;
        [msg appendString:@"乘客電話\n"];
    }
    
    if(!customerName.length)
    {
        allGood = NO;
        [msg appendString:@"乘客姓名\n"];
    }
    
    if(!customerTitle.length)
    {
        allGood = NO;
        [msg appendString:@"乘客稱謂\n"];
    }
    
    if(!orderType.length)
    {
        allGood = NO;
        [msg appendString:@"訂車種類\n"];
    }
    
    if(!orderTime)
    {
        allGood = NO;
        [msg appendString:@"訂車時間\n"];
    }
    
    if(!pickupAddress.length)
    {
        allGood = NO;
        [msg appendString:@"訂車地址\n"];
    }
    
    if(!pickupLat)
    {
        allGood = NO;
        [msg appendString:@"訂車地址緯度\n"];
    }
    
    if(!pickupLon)
    {
        allGood = NO;
        [msg appendString:@"訂車地址經度\n"];
    }
    
    if(allGood == NO && msg.length)
    {
        [msg insertString:@"缺少以下訂車資訊:\n" atIndex:0];
        self.validateResultMessage = msg;
    }
    
    return allGood;
}

- (NSString *)generateFormattedAddress
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"%@&", addrRegion];
    [str appendFormat:@"%@&", addrZone];
    [str appendFormat:@"%@&", addrRoad];
    
    if(addrSection.length)
        [str appendFormat:@"%@段&", addrSection];
    else
        [str appendFormat:@"%@&", addrSection];
    
    if(addrAlley.length)
        [str appendFormat:@"%@巷&", addrAlley];
    else
        [str appendFormat:@"%@&", addrAlley];
    
    if(addrLane.length)
        [str appendFormat:@"%@弄&", addrLane];
    else
        [str appendFormat:@"%@&", addrLane];
    
    if(addrNumber.length)
        [str appendFormat:@"%@號&", addrNumber];
    else
        [str appendFormat:@"%@", addrNumber];
    
    return str;
}

- (NSString *)generatePlainAddress
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"%@", addrRegion];
    [str appendFormat:@"%@", addrZone];
    [str appendFormat:@"%@", addrRoad];
    
    if(addrSection.length)
        [str appendFormat:@"%@段", addrSection];
    else
        [str appendFormat:@"%@", addrSection];
    
    if(addrAlley.length)
        [str appendFormat:@"%@巷", addrAlley];
    else
        [str appendFormat:@"%@", addrAlley];
    
    if(addrLane.length)
        [str appendFormat:@"%@弄", addrLane];
    else
        [str appendFormat:@"%@", addrLane];
    
    if(addrNumber.length)
        [str appendFormat:@"%@號", addrNumber];
    else
        [str appendFormat:@"%@", addrNumber];
    
    return str;
}

- (NSString *)generateSpecialRequirement
{
    NSMutableString *str = [NSMutableString string];
    
    if(hasLuggage)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(hasPet)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(hasWheelChair)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    if(isDrunk)
        [str appendString:@"1"];
    else
        [str appendString:@"0"];
    
    [str appendString:@"0000"];
    
    return str;
}

@end
