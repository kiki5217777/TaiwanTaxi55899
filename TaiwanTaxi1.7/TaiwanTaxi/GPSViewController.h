//
//  GPSViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "BaseViewController.h"

@interface GPSViewController : BaseViewController <MKMapViewDelegate,CLLocationManagerDelegate>
{
    
}

@property (retain, nonatomic) IBOutlet UIButton *editAddressButton;
@property (retain, nonatomic) IBOutlet MKMapView *myMapView;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;

@property (retain, nonatomic) CLLocationManager *locManager;
@property (retain, nonatomic) CLGeocoder *geoCoder;

@property (retain, nonatomic) NSString      * region;
@property (retain, nonatomic) NSString      * district;
@property (retain, nonatomic) NSString      * road;
@property (retain, nonatomic) NSString      * number;
@property (retain, nonatomic) CLLocation    * location;
@property (assign) int                      retryCount;
@property (retain, nonatomic) IBOutlet UIImageView *pin;

- (IBAction)editAddressButtonPressed:(id)sender;
- (IBAction)orderTaxiButtonPressed:(id)sender;

@end
