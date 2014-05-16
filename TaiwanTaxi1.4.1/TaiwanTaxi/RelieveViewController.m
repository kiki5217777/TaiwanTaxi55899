//
//  RelieveViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RelieveViewController.h"
#import "AppDelegate.h"
#import "MKMapView+ZoomLevel.h"
#import "TaxiAnnotation.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "PersonAnnotationView.h"

@interface RelieveViewController()
@property (nonatomic, retain) TaxiAnnotation *taxiAnnotation;
@end


@implementation RelieveViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define LAST_SAVED_PATH                 @"lastPath"
#define ALERT_CANCEL_ORDER              10
#define ALERT_START_TRACKING            20
#define TAXI_ANNOTATION_DURATION        20.0

#pragma mark - synthesize

@synthesize contactBtn;
@synthesize segment1;
@synthesize segment2;
@synthesize myMapView;
@synthesize recordsBtn;
@synthesize currentState;

@synthesize mPath;
@synthesize pathView;
@synthesize startPoint;
@synthesize endPoint;
@synthesize dateFormatter;
@synthesize taxiAnnotation;

#pragma mark - dealloc

- (void)dealloc
{
    [recordsBtn release];
    [contactBtn release];
    [segment2 release];
    [segment1 release];
    myMapView.delegate = nil;
    [myMapView release];
    [taxiAnnotation release];
    
    [mPath release];
    [pathView release];
    [startPoint release];
    [endPoint release];
    [dateFormatter release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_bonusBtn release];
    [_contentView release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        firstIn = true;
        inRelieve = false;
        inBackground = false;
        homePresent = false;
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // -------------------- view --------------------
    isCallTaxiLocationTimer = NO;
    if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        self.bonusBtn.hidden = YES;
        
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.y = self.bonusBtn.frame.origin.y;
        contentFrame.size.height += self.bonusBtn.frame.size.height;
        self.contentView.frame = contentFrame;
    }
    
    // -------------------- notification --------------------
    
    [self.notifCenter addObserver:self
                         selector:@selector(handleLocationUpdate:)
                             name:UPDATE_LOCATION_NOTIF
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(handleLocationNotAvail:)
                             name:LOCATION_TRACKING_NOT_AVAIL_NOTIF
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(handleLocationUpdateError:)
                             name:ERROR_UPDATE_LOCATION_NOTIF
                           object:nil];
    
    // -------------------- misc --------------------
    
    zoomInOnUser = NO;
    
    currentState = ControllerStateNotTracking;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    
//    [self loadLastSavedPath]; modified on 2014.01.05 
}

- (void)viewDidUnload
{
    [self setRecordsBtn:nil];
    [self setContactBtn:nil];
    [self setSegment2:nil];
    [self setSegment1:nil];
    [self setMyMapView:nil];
    [self setTaxiAnnotation:nil];
    
    [self setMPath:nil];
    [self setPathView:nil];
    [self setStartPoint:nil];
    [self setEndPoint:nil];
    [self setDateFormatter:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setBonusBtn:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.myMapView.showsUserLocation = YES;
   
    [self.notifCenter addObserver:self
					     selector:@selector(pressMember)
                             name:CHANGE_TAB_NOTIFICATION //CHANGE_TAB_NOTIFICATION
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(leaveMember)
                             name:SHOW_HOME_PAGE_NOTIFICATION
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(homePresentPress)
                             name:RELIEVE_HOME_PRESENT
                           object:nil];
    
    [self.notifCenter addObserver:self selector:@selector(removeTaxiAnnotationWithNotification:) name:ORDER_CANCELLED_NOTIFICATION object:nil];
    
    
    
    if (inBackground) {
        inRelieve = true;
    }
    
    if (firstIn || inRelieve) {
        if (firstIn) {
            firstIn = false;
            inRelieve = true;
            [self taxiCurrentLoaction];
            return;
        }
        if (!homePresent) {
            [self taxiCurrentLoaction];
        }else
            homePresent = false;
        
    }
    
    
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:YES];
//    
//}

- (void)viewWillDisappear:(BOOL)animated
{

    if(currentState == ControllerStateNotTracking)
        self.myMapView.showsUserLocation = NO;
    [self.notifCenter removeObserver:self name:CHANGE_TAB_NOTIFICATION object:nil];
    [self.notifCenter removeObserver:self name:SHOW_HOME_PAGE_NOTIFICATION object:nil];
    [self.notifCenter removeObserver:self name:RELIEVE_HOME_PRESENT object:nil];
    [self.notifCenter removeObserver:self name:ORDER_CANCELLED_NOTIFICATION object:nil];
    
    if (inBackground) {
        inRelieve = false;
    }
    [super viewWillDisappear:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark- Notification trigger 
- (void)pressMember {
    if (!homePresent) {
        if (inRelieve) {
            [self taxiCurrentLoaction];
            inBackground = false;
        }
    }else
        homePresent = false;
    
}

- (void) leaveMember {
    inBackground = true;
}

- (void) homePresentPress {
    homePresent = true;
}
-(void) removeTaxiAnnotationWithNotification:(NSNotification *)notification{
    if (!isCallTaxiLocationTimer){
        if ([taxiLoctionTimer isValid])
            [taxiLoctionTimer invalidate];
    }else
        NSLog(@"timer has fired");
    
    if ([[self.myMapView annotations] count]) {
        
        for (id <MKAnnotation> ann in [self.myMapView annotations]) {
            if ([ann isKindOfClass:[TaxiAnnotation class]]) {
                [self.myMapView removeAnnotation:self.taxiAnnotation];
                break;
            }
        }
    }
}
-(void) removeTaxiAnnotation{
    
    if ([[self.myMapView annotations] count]) {
        
        for (id <MKAnnotation> ann in [self.myMapView annotations]) {
            if ([ann isKindOfClass:[TaxiAnnotation class]]) {
                [self.myMapView removeAnnotation:self.taxiAnnotation];
                break;
            }
        }
    }
}
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *location = userLocation.location;
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    if(zoomInOnUser == NO && location && CLLocationCoordinate2DIsValid(coordinate))
    {
        zoomInOnUser = YES;
        
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
        [self.myMapView setRegion:region animated:YES];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if(self.pathView == nil)
    {
        self.pathView = [[[PathView alloc] initWithOverlay:overlay] autorelease];
    }
    
    return self.pathView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        // try to dequeue an existing pin view first
        static NSString* ItemAnnotationIdentifier = @"PersonAnnotationView";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.myMapView dequeueReusableAnnotationViewWithIdentifier:ItemAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]initWithAnnotation:annotation
                                                                                 reuseIdentifier:ItemAnnotationIdentifier] autorelease];
            customPinView.image = [UIImage imageNamed:@"me"];
            
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = NO;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
	
	if ([annotation isKindOfClass:[MyAnnotation class]])
	{
		// try to dequeue an existing pin view first
        static NSString* ItemAnnotationIdentifier = @"itemAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.myMapView dequeueReusableAnnotationViewWithIdentifier:ItemAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]initWithAnnotation:annotation
                                                                                 reuseIdentifier:ItemAnnotationIdentifier] autorelease];
            if(annotation == self.startPoint)
                customPinView.pinColor = MKPinAnnotationColorGreen;
            else
                customPinView.pinColor = MKPinAnnotationColorRed;
            
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
	}
    
    if ([annotation isKindOfClass:[TaxiAnnotation class]])
    {
        static NSString* SFAnnotationIdentifier = @"TaxiAnnotationIdentifier";
        MKPinAnnotationView* pinView =
        (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:SFAnnotationIdentifier] autorelease];
            annotationView.canShowCallout = YES;
            
//            UIImage *flagImage = [UIImage imageNamed:@"taxi.png"];
//            
//            CGRect resizeRect;
//            
//            resizeRect.size = flagImage.size;
//            CGSize maxSize = CGRectInset(self.view.bounds, 10.0f,10.0f).size;
//            maxSize.height -= self.navigationController.navigationBar.frame.size.height + 40.0f;
//            if (resizeRect.size.width > maxSize.width)
//                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
//            if (resizeRect.size.height > maxSize.height)
//                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
//            
//            resizeRect.origin = (CGPoint){0.0f, 0.0f};
//            UIGraphicsBeginImageContext(resizeRect.size);
//            [flagImage drawInRect:resizeRect];
//            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            annotationView.image = resizedImage;
            annotationView.image = [UIImage imageNamed:@"taxi_large"];
            annotationView.opaque = NO;
            
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taxi.png"]];
            annotationView.leftCalloutAccessoryView = sfIconView;
            [sfIconView release];
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
	
	return nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_CANCEL_ORDER)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            if(self.manager.currentOrderID.length)
            {
                [SVProgressHUD showWithStatus:@"取消叫車中..." maskType:SVProgressHUDMaskTypeClear];
                
//                [self.manager cancelTaxiOrder:self.manager.currentOrderID];
                [self.manager cancelTaxiOrderWithBlock:self.manager.currentOrderID success:^{
                    
                    [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                    
                    [self.manager updateProcessOrderWithKey:self.manager.currentOrderKey result:ORDER_STATUS_FAILURE_CANCEL_AFTER_DISPATCH cancelOn:[NSDate date]];
    
              } failure:^{
                    [SVProgressHUD dismiss];
                  [self.manager showOrderCancelErrorAlert];
                    NSLog(@"cancel order error ");
                }];
                
                
            }
        }
    }
    else if (alertView.tag == ALERT_START_TRACKING)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self startTracking];
            
            [self.segment2 setTitle:@"停止記錄" forSegmentAtIndex:1];
            [self.segment2 setEnabled:NO forSegmentAtIndex:0];
            [self.segment2 setEnabled:NO forSegmentAtIndex:2];
        }
    }
}

#pragma mark - notification handling

- (void)handleLocationUpdate:(NSNotification *)notification
{
    CLLocation *newLocation = [notification.userInfo objectForKey:@"newLocation"];
    
    if (self.mPath == nil)
    {
        // This is the first time we're getting a location update,
        // so create the MovementPath and add it to the map.
        //
        self.mPath = [[[MovementPath alloc] initWithCenterCoordinate:newLocation.coordinate] autorelease];
        [self.myMapView addOverlay:self.mPath];
        
        // On the first location update only, zoom map to user location
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
        [self.myMapView setRegion:region animated:YES];
        
        [self configStartPointWithLat:newLocation.coordinate.latitude
                                  lon:newLocation.coordinate.longitude
                                 date:newLocation.timestamp];
        
        [self.myMapView addAnnotation:self.startPoint];
        
        [self configEndPointWithLat:newLocation.coordinate.latitude
                                lon:newLocation.coordinate.longitude
                               date:newLocation.timestamp];
        
        [SVProgressHUD dismiss];
    }
    else
    {
        // This is a subsequent location update.
        // If the crumbs MKOverlay model object determines that the current location has moved
        // far enough from the previous location, use the returned updateRect to redraw just
        // the changed area.
        //
        MKMapRect updateRect = [self.mPath addCoordinate:newLocation.coordinate];
        
        if (!MKMapRectIsNull(updateRect))
        {
            // There is a non null update rect.
            // Compute the currently visible map zoom scale
            MKZoomScale currentZoomScale = (CGFloat)(self.myMapView.bounds.size.width / self.myMapView.visibleMapRect.size.width);
            // Find out the line width at this zoom scale and outset the updateRect by that amount
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            // Ask the overlay view to update just the changed area.
            [self.pathView setNeedsDisplayInMapRect:updateRect];
        }
        
        [self configEndPointWithLat:newLocation.coordinate.latitude
                                lon:newLocation.coordinate.longitude
                               date:newLocation.timestamp];
        
        // check to see if tracking duration limit has passed
        NSTimeInterval duration = [self.endPoint.date timeIntervalSinceDate:self.startPoint.date];
        if(duration > TAXI_ORDER_VALID_DURATION)
        {
            if(currentState == ControllerStateIsTracking)
            {
                [self stopTracking];
                [self.segment2 setTitle:@"開始記錄" forSegmentAtIndex:1];
                [self.segment2 setEnabled:YES forSegmentAtIndex:0];
                [self.segment2 setEnabled:YES forSegmentAtIndex:2];
            }
        }
    }
}

- (void)handleLocationNotAvail:(NSNotification *)notification
{
    [SVProgressHUD showErrorWithStatus:@"無法定位"];
}

- (void)handleLocationUpdateError:(NSNotification *)notification
{
    [SVProgressHUD showErrorWithStatus:@"無法開啟定位系統"];
}

#pragma mark - user interaction

- (IBAction)bonusBannerPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"準備中"];
    [self.manager generateBonusLink:^(NSString *urlLink, NSString *msg, NSError *error) {
        
        button.enabled = YES;
        
        if(urlLink.length)
        {
            SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:urlLink]];
            swc.availableActions = SVWebViewControllerAvailableActionsNone;
            swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
            swc.toolbar.barStyle = UIBarStyleBlackOpaque;
            swc.webViewController.navigationItem.title = @"紅利大積點";
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.window.rootViewController presentViewController:swc
                                                             animated:YES
                                                           completion:^{
                                                               
                                                               int64_t delayInSeconds = 2.0;
                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                   [SVProgressHUD showSuccessWithStatus:msg];
                                                               });
 
                                                           }];
            [swc release];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:msg];
        }
        
    }];
}

- (IBAction)routerRecords:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_RIDE_HISTORY_VIEW
                                    object:self];
}

- (IBAction)contactUs:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_CONTACT_VIEW
                                    object:self];
}

- (IBAction)segment1ValueChanged:(id)sender
{
    UISegmentedControl *s = (UISegmentedControl *)sender;
    
    // 車輛位置, 安心簡訊, 取消叫車 
    if(s.selectedSegmentIndex == 0)
    {
        [self taxiCurrentLoaction];
    }
    else if(s.selectedSegmentIndex == 1)
    {
        if(self.manager.currentOrderID.length == 0)
        {
            [self removeTaxiAnnotation];
            [SVProgressHUD showErrorWithStatus:@"目前沒有叫車喔"];
            return;
        }
        
        Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        
        if (messageClass != nil)
        {
            // Check whether the current device is configured for sending SMS messages
            if ([messageClass canSendText])
            {
                [self displaySMSComposerSheet];
            }
            else
            {
                DDLogCError(@"Device not configured to send SMS.");
            }
        }
        else
        {
            DDLogCError(@"Device not configured to send SMS.");
        }
    }
    else if(s.selectedSegmentIndex == 2)
    {
        if(self.manager.currentOrderID.length)
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"叫車服務"
                                                             message:@"確定要取消訂車?"
                                                            delegate:self
                                                   cancelButtonTitle:@"不是"
                                                   otherButtonTitles:@"是", nil] autorelease];
            
            alert.tag = ALERT_CANCEL_ORDER;
            [alert show];
        }
        else
        {
            [self removeTaxiAnnotation];
            [SVProgressHUD showErrorWithStatus:@"目前沒有叫車喔"];
        }
    }
    
    s.selectedSegmentIndex = UISegmentedControlNoSegment;
}

//modified by kiki Huang 2014.01.05
-(void)taxiCurrentLoaction{
    if(self.manager.currentOrderID.length == 0)
    {
        [self removeTaxiAnnotation];
        [SVProgressHUD showErrorWithStatus:@"目前沒有叫車喔"];
        return;
    }
    [self resetTaxiLocation];
}

-(void)resetTaxiLocation{
    
    isCallTaxiLocationTimer = NO;
    
    if(self.manager.currentOrderID.length == 0)
    {
        return;
    }
    
    if (ABS([self.manager.currentOrderDate timeIntervalSinceNow])>0) {
        NSString *orderId = self.manager.currentOrderID;
        [self.manager getTaxiPositionForTaxiOrder:orderId success:^(double lat, double lon) {
            
            if(self.taxiAnnotation == nil)
            {
                TaxiAnnotation *annotation = [[TaxiAnnotation alloc] init];
                self.taxiAnnotation = annotation;
                [annotation release];
            }
            
            self.taxiAnnotation.lat = [NSNumber numberWithDouble:lat];
            self.taxiAnnotation.lng = [NSNumber numberWithDouble:lon];
            
            self.taxiAnnotation.name = self.manager.currentOrderCarNumber;
            
            [self.myMapView removeAnnotation:self.taxiAnnotation];
            [self.myMapView addAnnotation:self.taxiAnnotation];
            
            CLLocationCoordinate2D taxiCoordinate = self.taxiAnnotation.coordinate;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(taxiCoordinate, 2000, 2000);
            [self.myMapView setRegion:region animated:YES];
            
            taxiLoctionTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(resetTaxiLocation) userInfo:nil repeats:NO];
            isCallTaxiLocationTimer = YES;
            /*
            [self performSelector:@selector(resetTaxiLocation)
                       withObject:nil
                       afterDelay:60.0];*/
            
            //        int64_t delayInSeconds = TAXI_ANNOTATION_DURATION;
            //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            //        NSLog(@"time %llu",popTime);
            //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //
            //            if(self.myMapView && self.taxiAnnotation)
            //                [self.myMapView removeAnnotation:self.taxiAnnotation];
            //        });
            
        } failure:^(NSString *errorMessage, NSError *error) {
            [SVProgressHUD showErrorWithStatus:errorMessage];
            [self performSelector:@selector(resetTaxiLocation)
                       withObject:nil
                       afterDelay:60.0];
        }];
    }
    
}

- (IBAction)segment2ValueChanged:(id)sender
{
    UISegmentedControl *s = (UISegmentedControl *)sender;
    
    // 軌跡記錄, 開始記錄, 清除記錄
    if(s.selectedSegmentIndex == 0)
    {
        [self loadLastSavedPath];
    }
    else if(s.selectedSegmentIndex == 1)
    {
        if(currentState == ControllerStateNotTracking)
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"軌跡記錄"
                                                             message:@"1.請開啟手機GPS功能設定\n2.手機將記錄20分鐘內之行車軌跡\n3.軌跡記錄時，請儘量不要離開此畫面"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"確定", nil] autorelease];
            alert.tag = ALERT_START_TRACKING;
            [alert show];
        }
        else if(currentState == ControllerStateIsTracking)
        {
            [self stopTracking];
            
            [s setTitle:@"開始記錄" forSegmentAtIndex:1];
            [s setEnabled:YES forSegmentAtIndex:0];
            [s setEnabled:YES forSegmentAtIndex:2];
        }
    }
    else if(s.selectedSegmentIndex == 2)
    {
        [self clearCurrentPath];
    }
    
    s.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (void)startTracking
{
    [SVProgressHUD showWithStatus:@"定位中..."];
    [self clearCurrentPath];
    [self.manager startTracking];
    
    currentState = ControllerStateIsTracking;
}

- (void)stopTracking
{
    [SVProgressHUD dismiss]; // just in case
    [self.manager stopTracking];
    [self.myMapView addAnnotation:self.endPoint];
    [self saveCurrentPath];
    
    currentState = ControllerStateNotTracking;
}

#pragma mark - misc

- (void)configStartPointWithLat:(double)lat
                            lon:(double)lon
                           date:(NSDate *)date
{
    MyAnnotation *anno = [[MyAnnotation alloc] init];
    anno.name = @"起點";
    anno.date = date;
    anno.dateString = [self.dateFormatter stringFromDate:anno.date];
    anno.lat = [NSNumber numberWithDouble:lat];
    anno.lng = [NSNumber numberWithDouble:lon];
    
    self.startPoint = anno;
    [anno release];
}

- (void)configEndPointWithLat:(double)lat
                          lon:(double)lon
                         date:(NSDate *)date
{
    MyAnnotation *anno = [[MyAnnotation alloc] init];
    anno.name = @"終點";
    anno.date = date;
    anno.dateString = [self.dateFormatter stringFromDate:anno.date];
    anno.lat = [NSNumber numberWithDouble:lat];
    anno.lng = [NSNumber numberWithDouble:lon];
    
    self.endPoint = anno;
    [anno release];
}

- (void)clearCurrentPath
{
    if(self.mPath)
        [self.myMapView removeOverlay:self.mPath];
    
    self.mPath = nil;
    self.pathView = nil;
    
    if(self.startPoint)
    {
        [self.myMapView removeAnnotation:self.startPoint];
        self.startPoint = nil;
    }
    
    if(self.endPoint)
    {
        [self.myMapView removeAnnotation:self.endPoint];
        self.endPoint = nil;
    }
}

- (void)saveCurrentPath
{
    NSMutableDictionary *toSave = [NSMutableDictionary dictionary];
    if(self.mPath)[toSave setObject:[NSKeyedArchiver archivedDataWithRootObject:self.mPath] forKey:@"trackData"];
    if(self.startPoint.lat)[toSave setObject:self.startPoint.lat forKey:@"startLat"];
    if(self.startPoint.lng)[toSave setObject:self.startPoint.lng forKey:@"startLon"];
    if(self.startPoint.date)[toSave setObject:self.startPoint.date forKey:@"startDate"];
    if(self.endPoint.lat)[toSave setObject:self.endPoint.lat forKey:@"endLat"];
    if(self.endPoint.lng)[toSave setObject:self.endPoint.lng forKey:@"endLon"];
    if(self.endPoint.date)[toSave setObject:self.endPoint.date forKey:@"endDate"];
    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [docsPath stringByAppendingPathComponent:LAST_SAVED_PATH];
    
    if([toSave writeToFile:filename atomically:YES] == YES)
    {
        [SVProgressHUD showSuccessWithStatus:@"儲存成功"];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"儲存失敗"];
    }
}

- (void)loadLastSavedPath
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [docsPath stringByAppendingPathComponent:LAST_SAVED_PATH];
    
    NSDictionary *saved = [NSDictionary dictionaryWithContentsOfFile:filename];
    
    if(saved)
    {
        NSData *trackData = [saved objectForKey:@"trackData"];
        NSNumber *startLat = [saved objectForKey:@"startLat"];
        NSNumber *startLon = [saved objectForKey:@"startLon"];
        NSDate   *startDate = [saved objectForKey:@"startDate"];
        NSNumber *endLat = [saved objectForKey:@"endLat"];
        NSNumber *endLon = [saved objectForKey:@"endLon"];
        NSDate   *endDate = [saved objectForKey:@"endDate"];
        
        MovementPath *aPath = [NSKeyedUnarchiver unarchiveObjectWithData:trackData];
        
        if(aPath == nil)
            return;
        
        [self clearCurrentPath];
        
        [self loadPath:aPath];
        
        [self configStartPointWithLat:startLat.doubleValue
                                  lon:startLon.doubleValue
                                 date:startDate];
        
        [self configEndPointWithLat:endLat.doubleValue
                                lon:endLon.doubleValue
                               date:endDate];
        
        [self.myMapView addAnnotation:self.startPoint];
        [self.myMapView addAnnotation:self.endPoint];
        
        
        [self.myMapView zoomMapViewToFitPoints:mPath.points
                                   pointsCount:mPath.pointCount
                                      animated:YES];
    }
}

- (void)loadPath:(MovementPath *)aPath
{
    self.mPath = aPath;
    [self.myMapView addOverlay:self.mPath];
}

// Displays an SMS composition interface inside the application.
-(void)displaySMSComposerSheet
{
    if([MFMessageComposeViewController canSendText] == NO)
    {
        [SVProgressHUD showErrorWithStatus:@"您的手機並不支援簡訊功能"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"開啟簡訊功能中..."];
    
    [self executeBlock:^{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        NSString *carNumber = self.manager.currentOrderCarNumber;
        if(carNumber.length == 0)
            carNumber = @"(目前沒有)";
        if(self.manager.currentAppMode == AppModeTWTaxi)
            picker.body = [NSString stringWithFormat:@"55688台灣大車隊安心簡訊~您的親友目前搭乘本公司車輛編號：%@；我們將護送乘客平安抵達目的地。安全 舒適 台灣大車隊", carNumber];
        else
            picker.body = [NSString stringWithFormat:@"55899城市衛星安心簡訊~您的親友目前搭乘本公司車輛編號：%@；我們將護送乘客平安抵達目的地。安全 舒適 城市衛星", carNumber];
        
        [appDelegate presentModalViewController:picker animated:YES];
        [picker release];
        [SVProgressHUD dismiss];
    } withDelay:0.1];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate dismissModalViewControllerAnimated:YES];
    
    if(result == MessageComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"傳送成功"];
    
    if(result == MessageComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:@"傳送失敗"];
}

@end
