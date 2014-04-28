//
//  GPSViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPSViewController.h"
#import "AddressViewController.h"
#import "UINavigationController+Customize.h"

@interface GPSViewController ()

@end

@implementation GPSViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize myMapView;
@synthesize addressLabel;
@synthesize locManager;
@synthesize geoCoder;

@synthesize region;
@synthesize district;
@synthesize road;
@synthesize number;
@synthesize location;
@synthesize retryCount;

#pragma mark - dealloc

- (void)dealloc 
{
    [myMapView release];
    [addressLabel release];
    locManager.delegate = nil;
    [locManager release];
    [geoCoder release];
    
    [region release];
    [district release];
    [road release];
    [number release];
    [location release];
    
    [_editAddressButton release];
    [_pin release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"GPS訂車";
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    locManager=[[CLLocationManager alloc] init];
    locManager.delegate=self;
    locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locManager startUpdatingLocation];
    
    geoCoder = [[CLGeocoder alloc] init];
    retryCount = 0;
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"我的位置"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(myLocation)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- view related --------------------
    
    if([self isRetina4inch] == YES)
    {
        CGRect editBtnFrame = self.editAddressButton.frame;
        editBtnFrame.origin.y += 88;
        self.editAddressButton.frame = editBtnFrame;
        
        CGRect pinFrame = self.pin.frame;
        pinFrame.origin.y += 44;
        self.pin.frame = pinFrame;
    }
    
    // show warning message
    [self executeBlock:^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"(1) 本地圖獲得Google Maps之合法授權。\n(2) 基本上GPS定位就有潛在誤差。\n(3) 請移動地圖接近所在的位置，再按「下一步」，修正為上車地址。"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        [alertView release];
    } withDelay:1.0];
    
    self.trackedViewName = @"GPS Screen";
}

- (void)viewDidUnload
{
    [self setMyMapView:nil];
    [self setAddressLabel:nil];
    [self setGeoCoder:nil];
    self.locManager.delegate = nil;
    [self setLocManager:nil];
    [self setEditAddressButton:nil];
    [self setPin:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate

// deprecated for iOS 6
- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateLocations:[NSArray arrayWithObject:newLocation]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    MKCoordinateRegion theRegion;
    theRegion.center=newLocation.coordinate;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.005;
    theSpan.longitudeDelta=0.005;
    theRegion.span=theSpan;
    
    [myMapView setRegion:theRegion animated:NO];
    
    self.location = newLocation;
    
    [locManager stopUpdatingLocation];
}

#pragma mark - Mapview delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self performSelector:@selector(getAddress) withObject:nil afterDelay:0.5];
}

#pragma mark - display address

- (void)getAddress
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getAddress) object:nil];
    
    CLLocation *centerlocation=[[[CLLocation alloc] initWithLatitude:self.myMapView.centerCoordinate.latitude
                                                           longitude:self.myMapView.centerCoordinate.longitude] autorelease];
    
    self.location = centerlocation;
    
    BOOL alwaysUseGoogle = YES;
    
    if([self isRunningiOS6] == YES || alwaysUseGoogle)
    {
        NSNumber *lat = [NSNumber numberWithDouble:self.location.coordinate.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:self.location.coordinate.longitude];
        
        [self.manager googleMapReverseGeocodeWithLat:lat lon:lon success:^(NSDictionary *placeInfo) {
            if(self == nil)
                return;
            
            NSArray *components = [placeInfo objectForKey:@"address_components"];
            self.addressLabel.text = [placeInfo objectForKey:@"formatted_address"];
            
            for(NSDictionary *info in components)
            {
                NSString *content = [info objectForKey:@"long_name"];
                NSArray *types = [info objectForKey:@"types"];
                if(types.count)
                {
                    NSString *type = [[info objectForKey:@"types"] objectAtIndex:0];
                    
                    DDLogInfo(@"%@", [NSString stringWithFormat:@"value:%@ type:%@", content, type]);
                    
                    if([type isEqualToString:@"administrative_area_level_1"] == YES
                       || [type isEqualToString:@"administrative_area_level_2"] == YES)
                        self.region = content;
                    
                    if([type isEqualToString:@"locality"] == YES)
                        self.district = content;
                    
                    if([type isEqualToString:@"route"] == YES)
                        self.road = content;
                    
                    if([type isEqualToString:@"street_number"] == YES)
                        self.number = content;
                }
            }
            
        } failure:^(NSString *message, NSError *error) {
            
        }];
    }
    else
    {
        [self.geoCoder reverseGeocodeLocation:self.location completionHandler: ^(NSArray *placemarks, NSError *error) {
            
            // get the first available placemark
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            // print for debugging purposes
            /*
            DDLogInfo(@"country :%@",               placemark.country);
            DDLogInfo(@"administrativeArea :%@",    placemark.administrativeArea);
            DDLogInfo(@"subAdministrativeArea :%@", placemark.subAdministrativeArea);
            DDLogInfo(@"locality :%@",              placemark.locality);
            DDLogInfo(@"subLocality :%@",           placemark.subLocality);
            DDLogInfo(@"thoroughfare :%@",          placemark.thoroughfare);
            DDLogInfo(@"subThoroughfare :%@",       placemark.subThoroughfare);
            DDLogInfo(@"postalCode :%@",            placemark.postalCode);
            DDLogInfo(@"region :%@",                placemark.region);
             */
            
            // set the label text to current location
            NSString *address = [ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) autorelease];
            self.addressLabel.text = address;
            
            // extract components from address
            if(placemark.subAdministrativeArea.length)
                self.region = placemark.subAdministrativeArea;
            else
                self.region = placemark.administrativeArea;
            
            if([placemark.locality isEqualToString:placemark.administrativeArea] == YES)
                self.district = placemark.subLocality;
            else
                self.district = placemark.locality;
            
            self.road = placemark.thoroughfare;
            self.number = placemark.subThoroughfare;
        }];
    }
}

#pragma mark - user interaction

- (IBAction)editAddressButtonPressed:(id)sender 
{
    NSDictionary *dict = [self constructAddressDict];
    
    AddressViewController *avc = [[AddressViewController alloc] init];
    avc.fromGPS = dict;
    avc.title = @"GPS訂車";
    
    [self.navigationController pushViewController:avc animated:YES];
    [avc release];
}

- (IBAction)orderTaxiButtonPressed:(id)sender
{
    NSDictionary *dict = [self constructAddressDict];
    
    AddressViewController *avc = [[AddressViewController alloc] init];
    avc.fromGPS = dict;
    avc.fromGPS_autoSubmit = YES;
    avc.title = @"GPS訂車";
    
    [self.navigationController pushViewController:avc animated:YES];
    [avc release];
}

- (void)myLocation
{
    [locManager startUpdatingLocation];
}

#pragma mark - misc

- (NSDictionary *)constructAddressDict
{
    // to prevent null to be set into dict
    if(self.region == nil)
        self.region = @"";
    
    if(self.district == nil)
        self.district = @"";
    
    if(self.road == nil)
        self.road = @"";
    
    if(self.number == nil)
        self.number = @"";
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.region forKey:@"region"];
    [dict setObject:self.district forKey:@"district"];
    [dict setObject:self.road forKey:@"road"];
    [dict setObject:self.number forKey:@"number"];
    if(self.location)
        [dict setObject:self.location forKey:@"location"];
    
    return dict;
}

@end
