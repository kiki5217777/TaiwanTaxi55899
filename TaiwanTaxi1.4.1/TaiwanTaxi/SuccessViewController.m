//
//  SuccessViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuccessViewController.h"
#import "UINavigationController+Customize.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"



@interface SuccessViewController()
@property (retain, nonatomic) NSDate *bookTime;

@end

@implementation SuccessViewController

#pragma mark - define

#define ALERT_CANCEL_ORDER  10
#define STAY_VISIBLE_DURATION 120 // 2 mins

#pragma mark - synthesize

@synthesize carNumber;
@synthesize bookTime;

#pragma mark - dealloc

- (void)dealloc
{
    [carNumber release];
    [bookTime release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_carNumberLabel release];
    [_etaLabel release];
    [_reliefButton release];
    [_cancelButton release];
    [_bonusChangeBtn release];
//    [_adBannerView release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // -------------------- navigation bar buttons --------------------
    
    /*
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"回首頁"
                                                                              icon:nil
                                                                     iconPlacement:CustomizeButtonIconPlacementLeft
                                                                            target:self
                                                                            action:@selector(showHomePage)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
     */
    
    // -------------------- notif --------------------
    
    [self.notifCenter addObserver:self
                         selector:@selector(handleOrderCancelledNotification:)
                             name:ORDER_CANCELLED_NOTIFICATION
                           object:nil];
    
    // -------------------- ad --------------------
    
//    [self.adBannerView startShowLargeAd:nil];
    
    //edited by kiki Huang 2013.12.13
    //----------------------TWMTA Interstitial Ad View --------------------------h0Lz1374718054864uDt--f1386820451081V
   
    CGRect frame = CGRectMake(10, 80, 300, 250);
    TWMTAMediaView *_squareAdView = [[TWMTAMediaView alloc] initWithFrame:frame
                                                                   slotId:@"f1386820451081V"
                                                              developerID:@""
                                                               gpsEnabled:YES
                                                                 testMode:NO];

    
    _squareAdView.delegate = self;
    [_squareAdView receiveAd];
    [self.view addSubview:_squareAdView];
    [_squareAdView release];
    
    // -------------------- view related --------------------
    
    self.carNumberLabel.text = self.carNumber;
    self.bookTime = [NSDate date];
    if(self.eta.length)
        self.etaLabel.text = self.eta;
    
    self.trackedViewName = @"Success Screen";
    
    [self performSelector:@selector(dismiss)
               withObject:nil
               afterDelay:STAY_VISIBLE_DURATION];
    
    // -------------------- bonus --------------------
    
    [self.manager getBonusWithUserID:self.manager.userID
                             success:^{
                                 NSLog(@"取得紅利 success");
                                 
                                 NSString *title = [NSString stringWithFormat:@"您目前累計點數：%@點，點我兌換", self.manager.bonusValue];
                                 [self.bonusChangeBtn setTitle:title forState:UIControlStateNormal];
                                 
                             } failure:^(NSString *errorMessage, NSError *error) {
                                 NSLog(@"取得紅利 failure");
                             }];
}

- (void)viewDidUnload
{
    [self setCarNumber:nil];
    [self setBookTime:nil];
    [self setCarNumberLabel:nil];
    [self setEtaLabel:nil];
    [self setReliefButton:nil];
    [self setCancelButton:nil];
    [self setBonusChangeBtn:nil];
//    [self setAdBannerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)reliefButtonPressed:(id)sender
{
    [self.notifCenter postNotificationName:CHANGE_TAB_NOTIFICATION
                                    object:[NSNumber numberWithInt:1]];
    
    [self executeBlock:^{
        [self.notifCenter postNotificationName:SHOW_MEMBER_TRACKING_VIEW
                                        object:self];
    } withDelay:0.5f];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"叫車服務"
                                                     message:@"確定要取消訂車?"
                                                    delegate:self
                                           cancelButtonTitle:@"不是"
                                           otherButtonTitles:@"是", nil] autorelease];
    
    alert.tag = ALERT_CANCEL_ORDER;
    [alert show];
    alert = nil;
}

- (IBAction)bonusBtnPressed:(id)sender
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

- (void)showHomePage
{
    [self.notifCenter postNotificationName:SHOW_HOME_PAGE_NOTIFICATION
                                    object:nil];
    
    [self passCheckpoint:TF_CHECKPOINT_SHOW_HOME_PAGE];
}

#pragma mark - notification

- (void)handleOrderCancelledNotification:(NSNotification *)notif
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_CANCEL_ORDER)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            if(self.manager.currentOrderID.length)
            {
                //modified by kiki Huang 2014.01.12
                [SVProgressHUD showWithStatus:@"取消叫車中..." maskType:SVProgressHUDMaskTypeClear];
                
                [self.manager cancelTaxiOrderWithBlock:self.manager.currentOrderID success:^{
                    [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                    
                    [self.manager updateProcessOrderWithKey:self.manager.currentOrderKey result:ORDER_STATUS_FAILURE_CANCEL_AFTER_DISPATCH cancelOn:[NSDate date]];
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                } failure:^{
                    [SVProgressHUD dismiss];
                    [self.manager showOrderCancelErrorAlert];
                }];
                
            }
            
        }
    }
}

#pragma mark - helper

- (void)dismiss
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - TWMTA Interstitial Ad View Delegate

- (void)ViewWillLoadAd:(TWMTAMediaView *)view{
//    NSLog(@"%@ ViewWillLoadAd", view);
}
- (void)iViewDidLoadAd:(TWMTAMediaView *)view
{
//    NSLog(@"%@ iViewDidLoadAd", view);
    
}
- (void)view:(TWMTAMediaView *)view didFailToReceiveAdWithError:(NSError *)error{
//    NSLog(@"didFailToReceiveAdWithError");
}

- (BOOL)viewActionShouldBegin:(TWMTAMediaView *)view willLeaveApplication:(BOOL)willLeave{
    return YES;
}

@end
