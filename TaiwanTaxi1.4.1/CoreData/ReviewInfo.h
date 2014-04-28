//
//  ReviewInfo.h
//  TaiwanTaxi
//
//  Created by jason on 8/7/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiOrder;

@interface ReviewInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * submitStatus;
@property (nonatomic, retain) TaxiOrder *taxiOrder;

@end
