//
//  FailViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FailViewController.h"
#import "UINavigationController+Customize.h"

@interface FailViewController ()

@end

@implementation FailViewController

#pragma mark - define

#define STAY_VISIBLE_DURATION 120 // 2 mins

#pragma mark - synthesize

@synthesize retyButton;

#pragma mark - dealloc

- (void)dealloc 
{
    [retyButton release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release]; _adBannerView = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
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
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"Failure Screen";
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
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
    
    // -------------------- misc --------------------
    
    [self performSelector:@selector(dismiss)
               withObject:nil
               afterDelay:STAY_VISIBLE_DURATION];
    
    
}

- (void)viewDidUnload
{
//    self.adBannerView.delegate = nil;
    [self setRetyButton:nil];
//    [self setAdBannerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)retyButtonPressed:(id)sender 
{
    // right now set to last view
    [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark - helper

- (void)dismiss
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
