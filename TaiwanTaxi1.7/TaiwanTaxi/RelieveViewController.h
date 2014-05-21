//
//  RelieveViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "MovementPath.h"
#import "PathView.h"
#import "MyAnnotation.h"

typedef enum{
    ControllerStateNotTracking = 0,
    ControllerStateIsTracking,
}ControllerState;

@interface RelieveViewController : BaseViewController <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL zoomInOnUser;
    BOOL firstIn;
    BOOL inRelieve;
    BOOL inBackground;
    BOOL homePresent;
    BOOL isCallTaxiLocationTimer;
    NSTimer *taxiLoctionTimer;
}

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIButton *recordsBtn;
@property (retain, nonatomic) IBOutlet UIButton *contactBtn;
@property (retain, nonatomic) IBOutlet UIButton *bonusBtn;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segment1;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segment2;
@property (retain, nonatomic) IBOutlet MKMapView *myMapView;

@property (retain, nonatomic) MovementPath      * mPath;
@property (retain, nonatomic) PathView          * pathView;
@property (retain, nonatomic) MyAnnotation      * startPoint;
@property (retain, nonatomic) MyAnnotation      * endPoint;
@property (assign, nonatomic) ControllerState     currentState;
@property (nonatomic, retain) NSDateFormatter   * dateFormatter;

- (IBAction)bonusBannerPressed:(id)sender;
- (IBAction)routerRecords:(id)sender;
- (IBAction)contactUs:(id)sender;
- (IBAction)segment1ValueChanged:(id)sender;
- (IBAction)segment2ValueChanged:(id)sender;

@end
