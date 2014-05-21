//
//  TaxiAnnotation.h
//  TaiwanTaxi
//
//  Created by jason on 9/12/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TaxiAnnotation : NSObject <MKAnnotation>
{
    
}

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * dateString;
@property (strong, nonatomic) NSDate   * date;
@property (strong, nonatomic) NSNumber * lat;
@property (strong, nonatomic) NSNumber * lng;

@end
