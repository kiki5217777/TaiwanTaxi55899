//
//  CallMenuViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CallMenuViewController.h"
#import "AddressViewController.h"
#import "GPSViewController.h"
#import "FavorViewController.h"
#import "HistoryViewController.h"
#import "LandmarkViewController.h"
#import "UINavigationController+Customize.h"
#import "AFNetworking.h"
#import "UIImage+helper.h"


@implementation CallMenuViewController

#pragma mark - synthesize

@synthesize historyBtn;
@synthesize landmarkBtn;
@synthesize favorBtn;
@synthesize GPSBtn;
@synthesize addressBtn;

#pragma mark - dealloc

- (void)dealloc
{
    [addressBtn release];
    [GPSBtn release];
    [favorBtn release];
    [historyBtn release];
    [landmarkBtn release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release]; _adBannerView = nil;
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage* anImage = [UIImage imageNamed:@"叫車服務.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"網路叫車" image:anImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton = YES;
    UIButton* leftButton = [self.navigationController setUpCustomizeButtonWithText:@"回首頁" 
                                                                              icon:nil
                                                                     iconPlacement:CustomizeButtonIconPlacementLeft 
                                                                            target:self 
                                                                            action:@selector(showHomePage)];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftButton] autorelease];
    
    // -------------------- view related --------------------
    
//    self.adBannerView.delegate = self;
    
    self.trackedViewName = @"Call Menu Screen";
    
    //edited by kiki Huang 2013.12.13
    //---------------------TWMTA ad-------------------
    TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                                  slotId:@"Dg1386570971882Nso"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.view addSubview:_upperAdView];
    [_upperAdView release];
    //-------------------------------------------------
}

- (void)viewDidUnload
{
    [self setAddressBtn:nil];
    [self setGPSBtn:nil];
    [self setFavorBtn:nil];
    [self setHistoryBtn:nil];
    [self setLandmarkBtn:nil];
//    [self setAdBannerView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)useWrite:(id)sender
{
    AddressViewController *addressViewController=[[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    addressViewController.title = @"地址訂車";
    [self.navigationController pushViewController:addressViewController animated:YES];
    [addressViewController release];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS];
}

- (IBAction)uesGPS:(id)sender
{
    GPSViewController *gpsViewController=[[GPSViewController alloc] initWithNibName:@"GPSViewController" bundle:nil];
    [self.navigationController pushViewController:gpsViewController animated:YES];
    [gpsViewController release];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_VISUAL_GPS];
}

- (IBAction)useFavorite:(id)sender
{
    FavorViewController *favorViewController=[[FavorViewController alloc] initWithNibName:@"FavorViewController" bundle:nil];
    [self.navigationController pushViewController:favorViewController animated:YES];
    [favorViewController release];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_FAVORITE];
}

- (IBAction)useHistory:(id)sender
{
    HistoryViewController *historyViewController=[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyViewController animated:YES];
    [historyViewController release];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_HISTORY];
}

- (IBAction)useLandmark:(id)sender
{
    LandmarkViewController *lvc = [[LandmarkViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:YES];
    [lvc release];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_LANDMARK];
}

-(void)showHomePage
{
    [self.notifCenter postNotificationName:SHOW_HOME_PAGE_NOTIFICATION
                                    object:nil];
    
    [self passCheckpoint:TF_CHECKPOINT_SHOW_HOME_PAGE];
}
/*
#pragma mark - CustomAdBannerViewDelegate

- (void)bannerButtonPressed:(NSString *)url
{
    if([url isKindOfClass:[NSNull class]] == NO)
    {
        [self handleClickAd:url];
    }
}
*/
@end
