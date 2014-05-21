//
//  HomeViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "RatingViewController.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "SVPlayWebViewController.h"
#import "NewsMessageViewController.h"

#import "DDlog.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "UIImage+helper.h"


#import <Crashlytics/Crashlytics.h>

@interface HomeViewController() {
    UIAlertView *pushUrlAlert;
    NSFetchedResultsController *prc;
}

@property (nonatomic, retain) NSString *callNumber;
@property (nonatomic, retain) CustomAdBannerView *bottomBannerView;
@end


@implementation HomeViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define BANNER_WIDTH    304
#define BANNER_HEIGHT   68

#define ALERT_CANCEL_ORDER  10
#define ALERT_MAKE_CALL     11
#define ALERT_AUTOBUTTON_UI    12//edited by kiki Huang 2013.12.31  QQQQQQQQQ
#define ALERT_PUSH          13//edited by kiki Huang 2014.01.08
#define ALERT_PUSH_URL     14

#pragma mark - synthesize

//@synthesize appCallTaxiBtn;
//@synthesize memberAreaBtn;
//@synthesize telCallTaxi;
//@synthesize ratingBtn;
//@synthesize topBannerImage;
//@synthesize botBannerImage;
@synthesize carNumberLabel;
@synthesize estimateTimeLabel;
//@synthesize cancelOrderLabel;
@synthesize taxiCallLabel;
@synthesize callNumber;
@synthesize adInfoTop;
@synthesize adInfoBot;

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [appCallTaxiBtn release];
//    [memberAreaBtn release];
//    [telCallTaxi release];
//    [ratingBtn release];
//    [topBannerImage release];
//    [botBannerImage release];
    [carNumberLabel release];
    [estimateTimeLabel release];
//    [cancelOrderLabel release];
    [taxiCallLabel release];
    [callNumber release];
    [adInfoTop release];
    [adInfoBot release];
    [_centerGridView release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release];  _adBannerView = nil;
    _bottomBannerView.delegate = nil;
    [_bottomBannerView release];
//    [_vponBannerView release];
//    [_pointBtn release];
//    [_messageBtn release];
    [_bonusOverDateLabel release];
    
    //modified by kiki Huang 2013.12.13
    [_backgroundImage release];
    [_buttonScrollView release];
    [_personBoardImageView release];
    [_personBtn release];
    [_cancelBtn release];
    [prc release];
    tapGesture.delegate = nil;
    [tapGesture release];
    tapGesture = nil;
    [rightArrow release];
    [leftArrow release];
    [actionsheet release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewDidLoadFirst = TRUE;
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    isalertShow = false;
    
    // -------------------- notif --------------------
    /*
    [self.notifCenter addObserver:self
                         selector:@selector(showFbShareDialog)
                             name:SHOW_FB_SHARE_FEED_DIALOG
                           object:nil];*/
    
    [self.notifCenter addObserver:self
                         selector:@selector(handleOrderSuccessfulNotif:)
                             name:ORDER_SUCCEEDED_NOTIFICATION
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(configStatusView)
                             name:ORDER_CANCELLED_NOTIFICATION
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(handlePush)
                             name:@"PushFuction"
                           object:nil];
    
    [self.notifCenter addObserver:self selector:@selector(handleUrlPushForHome) name:@"PushUrl" object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(signViewPresent)
                             name:@"signPresent"
                           object:nil];
    
    // -------------------- view --------------------
    
    if([self isRetina4inch])
    {
        CGRect frame = self.centerGridView.frame;
        frame.origin.y += 44;
        self.centerGridView.frame = frame;
    }
    
    self.trackedViewName = @"Home Screen";
    
    [self configStatusView];
    
//    if ([self checkFolder:[self saveFacePicturePath]]) {
//        [self.personBtn setImage:[UIImage imageWithContentsOfFile:[self saveFacePicturePath]] forState:UIControlStateNormal];
//    }
    
    
    // -------------------- ad ----------------------
    
//    [self.vponBannerView startShowAd:self.parentViewController];
//    self.adBannerView.delegate = self;
    //-----------------------Intro Image--------------------------------
    //edited by kiki Huang 2013.12.30
    NSString *type =@" ";
    
    if (IS_IPHONE_5) {
        type = @"M";
    }else
        type = @"S";
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type", nil];
    [self.manager taxiIntroUI:parameter];

    
    //---------------------TWMTA Ad--------------------------------------edited by kiki Huang 2013.12.13
    
    TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                             slotId:@"Dg1386570971882Nso"
                                        developerID:@""
                                         gpsEnabled:YES
                                           testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.view addSubview:_upperAdView];
    [_upperAdView release];
    
     TWMTAMediaView *_downAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-90, 320, 50)
                                                  slotId:@"I2h1386571020133T3"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _downAdView.delegate = self;
    [_downAdView receiveAd];
    [self.view addSubview:_downAdView];
    [_downAdView release];
    
    //-----------------------Menu Auto Buttons--------------------------modified by kiki Huang 2014.01.04
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetAutoButton) name:@"autoButtonDone" object:nil];//2014.02.10
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMenuButtonUI) name:@"changeHomeButtonUI" object:nil];
    
    self.originScrollView.contentSize = CGSizeMake(self.originScrollView.frame.size.width+100 , self.originScrollView.frame.size.height);
    
    NSInteger buttonOffset = 170;
    if (IS_IPHONE_5) {
        buttonOffset=210;
    }
    leftArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"left.png"]];
    rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"right.png"]];
    [leftArrow setFrame:CGRectMake(0, self.buttonScrollView.frame.origin.y+buttonOffset, 29, 45)];
    
    [rightArrow setFrame:CGRectMake(self.view.frame.size.width-50, self.buttonScrollView.frame.origin.y+buttonOffset, 29, 45)];
    
    [self.view addSubview:leftArrow];
    [self.view addSubview:rightArrow];

    [self changeMenuButtonUI];
    
    [self handleUrlPushForHome];
    
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self setAppCallTaxiBtn:nil];
//    [self setMemberAreaBtn:nil];
//    [self setTelCallTaxi:nil];
//    [self setRatingBtn:nil];
    [self setCarNumberLabel:nil];
    [self setEstimateTimeLabel:nil];
//    [self setCancelOrderLabel:nil];
    [self setTaxiCallLabel:nil];
    [self setCallNumber:nil];
    [self setAdInfoTop:nil];
    [self setAdInfoBot:nil];
    [self setCenterGridView:nil];
//    [self setAdBannerView:nil];
//    [self setAdBannerView:nil];
//    [self setVponBannerView:nil];
//    [self setPointBtn:nil];
//    [self setMessageBtn:nil];
//    [self setBonusOverDateLabel:nil];
    
    //modified by kiki Huang 2013.12.13
    rightArrow = nil;
    leftArrow = nil;
    actionsheet = nil;
    
    tapGesture.delegate = nil;
    tapGesture=nil;
    prc = nil;
    [self setPersonBoardImageView:nil];
    [self setBackgroundImage:nil];
    [self setButtonScrollView:nil];
    [self setPersonBtn:nil];
    [self setCancelBtn:nil];
   
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Change Menu UI

-(void)resetAutoButton {
    //modified by kiki Huang 2014.02.10
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"changeHomeButtonUI" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMenuButtonUI) name:@"changeHomeButtonUI" object:nil];
}
-(void)changeMenuButtonUI{
    
    if (!viewDidLoadFirst) {
        [self handleSignInSuccessful:nil];
    }
    
    NSArray *viewsToRemove = [self.buttonScrollView subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ImageIsDownload"])
    {
    
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MenuObject"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"ButtonObject"]) {
            
            //load local saved file
            NSArray *menuArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MenuObject"]];
            NSArray *buttonArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ButtonObject"]];
            
            //menu setup
            [self.backgroundImage setImage:[UIImage imageWithContentsOfFile:[[menuArray objectAtIndex:0] objectForKey:@"SavePath"]]];
            [self.personBoardImageView setImage:[UIImage imageWithContentsOfFile:[[menuArray objectAtIndex:1] objectForKey:@"SavePath"]]];
            //auto button in scrollview
            CGRect rect;
            CGFloat orgX = 10 , orgY = 0;
            CGSize buttonSize = CGSizeMake(90, 90);
            CGFloat horizontalOffset = buttonSize.width+15;
            CGFloat verticalOffset = buttonSize.height+15;
            CGFloat temp = -(horizontalOffset)+orgX;
            
            for (int i=0; i<[buttonArray count]; i++) {
                if (i % 2 ==0) {
                    temp += verticalOffset;
                    rect = CGRectMake(temp, orgY, buttonSize.width, buttonSize.height);
                }else{
                    rect = CGRectMake(temp, orgY+verticalOffset, buttonSize.width, buttonSize.height);
                }
                
                if ([[[buttonArray objectAtIndex:i] objectForKey:@"FunctionTag"] intValue] !=-1) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setFrame:rect];
                    [button setBackgroundColor:[UIColor clearColor]];
                    NSLog(@"set img %@",[[buttonArray objectAtIndex:i] objectForKey:@"SavePath"]);
                    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[buttonArray objectAtIndex:i] objectForKey:@"SavePath"]] forState:UIControlStateNormal];
                    
                    [button setTag:[[[buttonArray objectAtIndex:i] objectForKey:@"FunctionTag"] integerValue]];
                    [button addTarget:self action:@selector(scrollViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [self.buttonScrollView addSubview:button];
                }
            }
            
            [self.buttonScrollView setContentSize:CGSizeMake(temp+buttonSize.width+10, self.buttonScrollView.frame.size.height)];
            
            
            
            if (self.buttonScrollView.contentOffset.x <=10){
                
                rightArrow.hidden = NO;
                leftArrow.hidden = YES;
            }else if(self.buttonScrollView.contentOffset.x >=self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width-10){
                rightArrow.hidden = YES;
                leftArrow.hidden = NO;
            }else if(self.buttonScrollView.contentOffset.x>10 && self.buttonScrollView.contentOffset.x < self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width-10){
                leftArrow.hidden = NO;
                rightArrow.hidden = NO;
            }
            return;
        }
        
        //for exception
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"MenuObject"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ButtonObject"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //modified by kiki Huang 2014.02.10
    CGRect rect;
    CGFloat orgX = 10 , orgY = 0;
    CGSize buttonSize = CGSizeMake(90, 90);
    CGFloat horizontalOffset = buttonSize.width+15;
    CGFloat verticalOffset = buttonSize.height+15;
    CGFloat temp = -(horizontalOffset)+orgX;
    NSArray *tagTypeArray = [[NSArray alloc]initWithObjects:TaxiMenuDefaultTag];
    
    for (int i=0; i<8; i++) {
        if (i % 2 ==0) {
            temp += verticalOffset;
            rect = CGRectMake(temp, orgY, buttonSize.width, buttonSize.height);
        }else{
            rect = CGRectMake(temp, orgY+verticalOffset, buttonSize.width, buttonSize.height);
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:rect];
        [button setBackgroundColor:[UIColor clearColor]];
        NSString *strVal= [NSString stringWithFormat:@"menuButton%d.png",i];
        NSInteger n = [tagTypeArray indexOfObject:strVal];
        [button setBackgroundImage:[UIImage imageNamed:strVal]  forState:UIControlStateNormal];
//        NSLog(@"i %d",i);
        [button setTag:n];
        [button addTarget:self action:@selector(scrollViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonScrollView addSubview:button];
    }
    
    [self.buttonScrollView setContentSize:CGSizeMake(temp+buttonSize.width+10, self.buttonScrollView.frame.size.height)];
    
    
    
    if (self.buttonScrollView.contentOffset.x <=10){
        
        rightArrow.hidden = NO;
        leftArrow.hidden = YES;
    }else if(self.buttonScrollView.contentOffset.x >=self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width-10){
        rightArrow.hidden = YES;
        leftArrow.hidden = NO;
    }else if(self.buttonScrollView.contentOffset.x>10 && self.buttonScrollView.contentOffset.x < self.buttonScrollView.contentSize.width - self.buttonScrollView.frame.size.width-10){
        leftArrow.hidden = NO;
        rightArrow.hidden = NO;
    }
}

-(BOOL)checkFolder:(NSString*) _name {
    
//    NSString *filetype = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"];
//    if (filetype !=nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:_name] stringByAppendingPathExtension:filetype];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:_name];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            return NO;
        }
        else
            return YES;
        
//    }
//    return NO;
    
}
-(void)removeFileWithName:(NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
    }
    else
        NSLog(@"db file name not exit");
}
#pragma mark - user interaction

- (IBAction)appCallTaxi:(id)sender
{
    [self.notifCenter postNotificationName:CHANGE_TAB_NOTIFICATION
                                    object:[NSNumber numberWithInt:0]];
    
    [self.notifCenter postNotificationName:HIDE_HOME_PAGE_NOTIFICATION
                                    object:nil];
    
    [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_INTERNET];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (IBAction)memberArea:(id)sender
{
    [self.notifCenter postNotificationName:CHANGE_TAB_NOTIFICATION
                                    object:[NSNumber numberWithInt:1]];
    
    [self.notifCenter postNotificationName:HIDE_HOME_PAGE_NOTIFICATION
                                    object:nil];
    
    [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_MEMBER];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (IBAction)pointBtnPressed:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"準備中"];
    [self.manager generateBonusLink:^(NSString *urlLink, NSString *msg, NSError *error) {
        
        //edited by kiki Huang 2014.01.12-------------------------
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"homePresnet" object:nil];
        //---------------------------------------------------------
        button.enabled = YES;
        
        if(urlLink.length)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RELIEVE_HOME_PRESENT object:nil];
            
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

- (IBAction)telCallTaxi:(id)sender
{
    NSString *msg = [NSString stringWithFormat:@"%@電話叫車", self.callNumber];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"叫車服務"
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"取消撥打"
                                               otherButtonTitles:@"確定撥打",nil] autorelease];
    alertView.tag = ALERT_MAKE_CALL;
    [alertView show];
    
    [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_PHONE];
}

- (IBAction)rating:(id)sender
{
//    [Crashlytics sharedInstance].debugMode = YES;
//    [[Crashlytics sharedInstance]crash];
//    TaxiOrder *lastOrder = [self.orderManager getLastTaxiOrderIfExists];
//    if(lastOrder)
//    {
//        
//        
//        if(lastOrder.orderStatus.intValue != OrderStatusSubmittedSuccessful)
//        {
//            [SVProgressHUD showErrorWithStatus:@"目前沒有您的成功搭車記錄喔"];
//            return;
//        }
    
//        RatingViewController *ratingView = [[[RatingViewController alloc] initWithNibName:@"RatingViewController"
//                                                                                   bundle:nil] autorelease];
//        ratingView.orderID = lastOrder.objectID;
//        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ratingView] autorelease];
//        [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
//        [delegate presentModalViewController:nav animated:YES];
//    }
//    else
//    {
//        [SVProgressHUD showErrorWithStatus:@"目前並沒有您的搭車記錄喔"];
//        return;
//    }
//    
//    [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_RATING];
    
    
//edited by kiki Huang 2013.12.18---------------------------------------------------------------------------------------------------------
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sd_Directory.db"];
//
//   [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    [SVProgressHUD showWithStatus:@"準備中"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"]) {
        NSNumber *dbNameVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"];
        NSLog(@"%d",[dbNameVersion intValue]);
        
        if ([dbNameVersion intValue]>1) {
            [self removeFileWithName:[NSString stringWithFormat:@"NEW_ETC_DB%d.db",[dbNameVersion intValue]-1]];
        }
    }
    
    
    [self.manager taxiFreeway:^(id JSON) {
        
        button.enabled = YES;
        NSLog(@"%@",JSON);
        
        if (JSON !=nil && JSON !=[NSNull null]) {
            if ([[JSON objectForKey:@"ok"] boolValue]) {
                
                if ([JSON objectForKey:@"rsp"] !=nil && [JSON objectForKey:@"rsp"]!=[NSNull null]) {
                    
                    NSString *ver = [[NSUserDefaults standardUserDefaults] valueForKey:@"DBVersion"];
                    NSLog(@"freeway old ver %@",ver);
                    
                    if ([[JSON objectForKey:@"rsp"] objectForKey:@"VER"] !=nil && [[JSON objectForKey:@"rsp"] objectForKey:@"VER"]!=[NSNull null] && [[JSON objectForKey:@"rsp"] objectForKey:@"URL"] !=nil && [[JSON objectForKey:@"rsp"] objectForKey:@"URL"]!=[NSNull null]) {
                        
                        
                        NSLog(@"freeway_db newVer:%@, url: %@",[[JSON objectForKey:@"rsp"] objectForKey:@"VER"],[[JSON objectForKey:@"rsp"] objectForKey:@"URL"]);
                        
                        if (![[[[JSON objectForKey:@"rsp"] objectForKey:@"VER"] stringValue] isEqualToString:ver]) {
                            
                           
//                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DBVersion"];
//                            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"freewayDBisDownloadNewFileName"];
                            
                            [self updateDB:[[JSON objectForKey:@"rsp"] objectForKey:@"URL"] version:[[[JSON objectForKey:@"rsp"] objectForKey:@"VER"] stringValue]];

                        }
                        else{
                            NSLog(@"無更新");
                            [SVProgressHUD showSuccessWithStatus:@"準備成功"];
//                            [self pushFreewayViewController];
                        }
//                        [self pushFreewayViewController];
                    }else
                        [SVProgressHUD showErrorWithStatus:@"資料庫版本更新失敗"];
                    
                }
                else{
                    [SVProgressHUD showErrorWithStatus:@"資料庫版本更新失敗"];
//                    [self pushFreewayViewController];
                }
                
            }else{
                
                if ([JSON objectForKey:@"msg"]!=[NSNull null] && [JSON objectForKey:@"msg"]!=nil) {
                    [SVProgressHUD showErrorWithStatus:[JSON objectForKey:@"msg"]];
                }else
                    [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，資料庫版本更新失敗"];
//                [self pushFreewayViewController];
            }

        }else
            [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，資料庫版本更新失敗"];
        
        
        [self pushFreewayViewController];
        
    } failure:^(NSString *errorMessage, NSError *error) {
        if (error) {
            button.enabled = YES;
            [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，資料庫版本更新失敗"];
            [self pushFreewayViewController];
            NSLog(@"web failure%@",error);
        }
    }];
    
   
}

- (IBAction)messageBtnPressed:(id)sender
{
    /*
     SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:self.manager.mini_site_url]];
     swc.availableActions = SVWebViewControllerAvailableActionsNone;
     swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
     swc.toolbar.barStyle = UIBarStyleBlackOpaque;
     swc.webViewController.showPageTitle = YES;
     
     AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [delegate presentModalViewController:swc animated:YES];
     [swc release];
     
     [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_MESSAGE];*/
    
    //modified by kiki Huang 2013.12.13
    [self.notifCenter postNotificationName:CHANGE_TAB_NOTIFICATION
                                    object:[NSNumber numberWithInt:2]];
    
    [self.notifCenter postNotificationName:HIDE_HOME_PAGE_NOTIFICATION
                                    object:nil];
}

- (IBAction)shareToFB:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
    
    [self passCheckpoint:TF_CHECKPOINT_HOMEPAGE_SHARE];
}

//modified by kiki Huang 2014.01.02
- (IBAction)cancelButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    //    if([self.cancelOrderLabel.text isEqualToString:@"取消訂車"] == YES)
    if (button.tag == 81)
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
        tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOut:)];
        tapGesture.numberOfTapsRequired =1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.delegate = self;
        
        actionsheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"從相簿選擇",@"登出", nil];
        [actionsheet setBounds:CGRectMake(0, 0, 320, 400)];
        [actionsheet showInView:self.view];
        [actionsheet.window addGestureRecognizer:tapGesture];
    }
    
}

//actionsheet tap outside - edited by kiki Huang 2014.01.05
-(void)tapOut:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint p = [gestureRecognizer locationInView:actionsheet];
	if (p.y < 0) { // They tapped outside
		[actionsheet dismissWithClickedButtonIndex:0 animated:YES];
        [actionsheet removeGestureRecognizer:tapGesture];
	}
}

#pragma mark -  Added functions for Update on 2013.11.25
//edited by kiki Huang 2013.12.26

-(void)updateDB:(NSString *)url version:(NSString *)str{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    __block int temp=1;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"]) {
        temp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"freewayDBisDownload_NewFileName"] intValue];
        temp++;
        NSLog(@"temp %d",temp);
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"NEW_ETC_DB%d.db",temp]];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DBVersion"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"freewayDBisDownload_NewFileName"];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"準備成功"];
        NSLog(@"Successfully downloaded file");
         [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"DBVersion"];
        NSLog(@"%d",temp);
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:temp] forKey:@"freewayDBisDownload_NewFileName"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"更新資料庫失敗"];

        if (temp>1) {
            temp--;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:temp] forKey:@"freewayDBisDownload_NewFileName"];
        }else
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"freewayDBisDownload_NewFileName"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"DBVersion"];
    }];
    
    [operation start];
}

-(void)pushFreewayViewController{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FreewayViewController *freewayView = [[[FreewayViewController alloc]initWithNibName:@"FreewayViewController" bundle:nil] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:freewayView]autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [delegate presentModalViewController:nav animated:YES];
}

// ActionSheet Delegate
-(void)willPresentActionSheet:(UIActionSheet *)actionSheet{
    
    if([self isRunningiOS7]){
        for (int i =0 ;i<[actionSheet.subviews count];i++) {
            UIView *subview  =[[actionSheet subviews] objectAtIndex:i];
            NSLog(@"i %d",[actionSheet.subviews count]);
            if ([subview isKindOfClass:[UIButton class]]) {
                if (i==[actionSheet.subviews count]-1) {
                    UIButton *button = (UIButton *)subview;
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                }else{
                    UIButton *button = (UIButton *)subview;
                    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
                }
                
            }
        }

    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELIEVE_HOME_PRESENT object:nil];
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    switch (buttonIndex) {
        case 0:
        {
            [self snapImage];
            actionsheetIndex = 0;
            break;
        }
        case 1:
        {
            [self pickImage];
            actionsheetIndex = 1;
            break;
        }
        case 2:
        {
            actionsheetIndex = 2;
            self.manager.isLogIn = NO;
            self.manager.autoLogIn = NO;
            [self.manager saveUserInfo];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate showSignInView];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CM5Version"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"cm5AddressArray"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"cm5filterArray"];
            [self.personBtn setImage:[UIImage imageNamed:@"porfile_pic_default.png"] forState:UIControlStateNormal];
            break;
        }
        case 3:
        {
            //cancel button;
            break;
        }
        default:
            break;
    }
}

- (IBAction)taxiPlayButtonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"準備中"];
    
    [self.manager taxiPlayToken:self.manager.userID
                        success:^(id JSON) {
        
        button.enabled=YES;
        NSLog(@"paly %@",JSON);
                            
        if (JSON!=[NSNull null] && JSON!=nil && [[JSON objectForKey:@"ok"] intValue] && [JSON objectForKey:JSON_API_KEY_rsp]!=[NSNull null] && [JSON objectForKey:JSON_API_KEY_rsp]!=nil)
        {
            if ([[JSON objectForKey:JSON_API_KEY_rsp] objectForKey:@"accessToken"] && [[JSON objectForKey:JSON_API_KEY_rsp] objectForKey:@"accessUrl"]) {
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RELIEVE_HOME_PRESENT object:nil];
                
                SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithPLAYPOST:
                                                 [NSDictionary dictionaryWithObjectsAndKeys:@"ios", @"device", self.manager.userID,@"user", [[JSON objectForKey:JSON_API_KEY_rsp] objectForKey:@"accessToken"], @"access", [[JSON objectForKey:JSON_API_KEY_rsp] objectForKey:@"accessUrl"], @"url",@"taxiPlay",@"API_type",nil]];
                swc.availableActions = SVWebViewControllerAvailableActionsNone;
                swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
                swc.toolbar.barStyle = UIBarStyleBlackOpaque;
                swc.webViewController.navigationItem.title = @"大玩家";
                
                
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate.window.rootViewController presentViewController:swc
                                                                 animated:YES
                                                               completion:^{
                                                                   
                                                                   int64_t delayInSeconds = 2.0;
                                                                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                       [SVProgressHUD showSuccessWithStatus:@"準備完成"];
                                                                   });
                                                                   
                                                                   
                                                               }];
                [swc release];

            }else{
                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，網址錯誤"];
            }
        }
        else{
            
            if ([JSON objectForKey:@"msg"]!=nil && [JSON objectForKey:@"msg"]!=[NSNull null]) {
                [SVProgressHUD showErrorWithStatus:[JSON objectForKey:@"msg"]];
            }else
                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤\n請稍後再試"];
        }
    }
    failure:^(NSString *errorMessage, NSError *error) {
        button.enabled=YES;
        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
        NSLog(@"web failure%@",error);
        
    }];

}

- (IBAction)taxiTicketButtonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    }else
        baseUrl = @"http://124.219.2.122/";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RELIEVE_HOME_PRESENT object:nil];
    
    NSDictionary *parameter = [[NSDictionary alloc]initWithObjectsAndKeys:self.manager.userID,@"CUSTACCT", nil];

    [SVProgressHUD showWithStatus:@"準備中"];
    /*
    [self.manager taxiTicketToken:self.manager.userID success:^(id JSON) {
        NSLog(@"ticket success %@",JSON);
        if ([[JSON objectForKey:@"ok"] boolValue]==1) {
            if ([JSON objectForKey:@"rsp"] !=[NSNull null]) {
                
                if ([[JSON objectForKey:@"rsp"] objectForKey:@"TIP"]!=[NSNull null]) {
                    [SVProgressHUD showSuccessWithStatus:[[JSON objectForKey:@"rsp"] objectForKey:@"TIP"]];
                    
                }
                else
                {
                    if ([[JSON objectForKey:@"rsp"] objectForKey:@"LINK"]!=[NSNull null] && [[JSON objectForKey:@"rsp"] objectForKey:@"TOKEN"]!=[NSNull null]) {
                        NSString *url = [NSString stringWithFormat:@"%@?TOKEN=%@",[[JSON objectForKey:@"rsp"] objectForKey:@"LINK"],[[JSON objectForKey:@"rsp"] objectForKey:@"TOKEN"]];
                        
                        SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
                        swc.availableActions = SVWebViewControllerAvailableActionsNone;
                        swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
                        swc.toolbar.barStyle = UIBarStyleBlackOpaque;
                        swc.webViewController.navigationItem.title = @"電子酬賓券";
                        
                        
                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [delegate.window.rootViewController presentViewController:swc
                                                                         animated:YES
                                                                       completion:^{
                                                                           
                                                                           int64_t delayInSeconds = 0.5;
                                                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                               [SVProgressHUD showSuccessWithStatus:@"準備完成"];
                                                                           });
                                                                           
                                                                           
                                                                       }];
                        [swc release];
                        
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，網址錯誤"];
                    
                }
                
            }
            else{
                if ([JSON objectForKey:@"msg"]!=[NSNull null] && [JSON objectForKey:@"msg"]!=nil) {
                    [SVProgressHUD showErrorWithStatus:[JSON objectForKey:@"msg"]];
                }else
                    [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤\n請稍後再試"];
            }
            
        }
        else{
            
            if ([JSON objectForKey:@"msg"]!=[NSNull null] && [JSON objectForKey:@"msg"]!=nil) {
                [SVProgressHUD showErrorWithStatus:[JSON objectForKey:@"msg"]];
            }else
                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
        }

        
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"ticket error %@",error);
        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
    }];
     */
    
    [self.manager taxiTicketTokenWithCookie:[NSString stringWithFormat:@"%@api/phone/getTICKET_TOKEN.aspx",baseUrl ] para:parameter success:^(id JSON) {
        
        button.enabled = YES;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:nil];
        NSLog(@"ticket success %@",json);
        
        NSLog(@"bool %d",[[json objectForKey:@"ok"] boolValue]);
        
        if ([[json objectForKey:@"ok"] boolValue]==1) {
            if ([json objectForKey:@"rsp"] !=[NSNull null]) {
                
                if ([[json objectForKey:@"rsp"] objectForKey:@"TIP"]!=[NSNull null]) {
                    [SVProgressHUD showSuccessWithStatus:[[json objectForKey:@"rsp"] objectForKey:@"TIP"]];
                    
                }
                else
                {
                    if ([[json objectForKey:@"rsp"] objectForKey:@"LINK"]!=[NSNull null] && [[json objectForKey:@"rsp"] objectForKey:@"TOKEN"]!=[NSNull null]) {
                        NSString *url = [NSString stringWithFormat:@"%@?TOKEN=%@",[[json objectForKey:@"rsp"] objectForKey:@"LINK"],[[json objectForKey:@"rsp"] objectForKey:@"TOKEN"]];
                        
                        SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
                        swc.availableActions = SVWebViewControllerAvailableActionsNone;
                        swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
                        swc.toolbar.barStyle = UIBarStyleBlackOpaque;
                        swc.webViewController.navigationItem.title = @"電子酬賓券";
                        
                        
                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [delegate.window.rootViewController presentViewController:swc
                                                                         animated:YES
                                                                       completion:^{
                                                                           
                                                                           int64_t delayInSeconds = 0.5;
                                                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                               [SVProgressHUD showSuccessWithStatus:@"準備完成"];
                                                                           });
                                                                           
                                                                           
                                                                       }];
                        [swc release];
                        
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，網址錯誤"];

                }
                
            }
            else{
                if ([json objectForKey:@"msg"]!=[NSNull null] && [json objectForKey:@"msg"]!=nil) {
                    [SVProgressHUD showErrorWithStatus:[json objectForKey:@"msg"]];
                }else
                    [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤\n請稍後再試"];
            }
           
        }
        else{
            
            if ([json objectForKey:@"msg"]!=[NSNull null] && [json objectForKey:@"msg"]!=nil) {
                [SVProgressHUD showErrorWithStatus:[json objectForKey:@"msg"]];
            }else
                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
        }
    } failure:^(NSString *errorMessage, NSError *error) {
        button.enabled = YES;
        NSLog(@"ticket error %@",error);
        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
    }];
    
}

-(void)scrollViewButtonPressed:(id)sender{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 0:
            [self appCallTaxi:sender];
            break;
        case 1:
            [self telCallTaxi:sender];
            break;
            
        case 2:
            [self memberArea:sender];
            break;
            
        case 3:
            [self rating:sender];
            break;
            
        case 4:
            [self pointBtnPressed:sender];
            break;
            
        case 5:
            [self messageBtnPressed:sender];
            break;
        case 6:
            [self taxiPlayButtonPressed:sender];
            break;
        case 7:
            [self taxiTicketButtonPressed:sender];
            break;
        default:
            break;
    }
    
    
}
#pragma mark - support methods

- (void)handleOrderSuccessfulNotif:(NSNotification *)notif
{
    [self performSelector:@selector(configStatusView)
               withObject:nil
               afterDelay:TAXI_ORDER_VALID_DURATION];
    
    [self performSelector:@selector(removeOrderKey)
               withObject:nil
               afterDelay:ABS([self.manager.currentOrderDate timeIntervalSinceNow])];
}
-(void)removeOrderKey{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"currentOrderID"];
}
/*
- (void)showFbShareDialog
{
    ShareViewController *svc = [[[ShareViewController alloc] initWithNibName:@"ShareViewController"
                                                                      bundle:nil] autorelease];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate presentModalViewController:svc animated:YES];
}*/

- (void)configStatusView
{
    self.bonusOverDateLabel.hidden =NO;
    
    NSLog(@"%@ %@",self.manager.currentOrderID,self.manager.currentOrderID);
    if(self.manager.currentOrderID.length && self.manager.currentOrderDate)
    {
        NSLog(@"%@ %@",self.manager.currentOrderID,self.manager.currentOrderID);
        double timeDiff = ABS([self.manager.currentOrderDate timeIntervalSinceNow]);
        if(timeDiff < TAXI_ORDER_VALID_DURATION)
        {
            //車輛編號：9999
            self.carNumberLabel.text = [NSString stringWithFormat:@"車輛編號：%@", self.manager.currentOrderCarNumber];
            
            //預計x分鐘到達
            self.estimateTimeLabel.text = [NSString stringWithFormat:@"預計%@分鐘到達",
                                           self.manager.currentOrderETA];
            [self.estimateTimeLabel setFont:[UIFont boldSystemFontOfSize:18]];
            
            //取消訂車
//            self.cancelOrderLabel.text = @"取消訂車";
            self.personBtn.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.bonusOverDateLabel.hidden = YES;
            
            return;
        }
        else
        {
            self.manager.currentOrderID = nil;
            self.manager.currentOrderDate = nil;
            self.manager.currentOrderCarNumber = nil;
        }
    }
    
    [self.manager getBonusWithUserID:self.manager.userID
                             success:^{
                                 NSLog(@"取得紅利 success");
                                 self.estimateTimeLabel.text = [NSString stringWithFormat:@"您目前累計點數：%@點", self.manager.bonusValue];
                                 [self.estimateTimeLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
                                 
                                 self.bonusOverDateLabel.text = [NSString stringWithFormat:@"%@ 到期點數：%@點",self.manager.overDate,self.manager.bonusOverDate];
                             }
                             failure:^(NSString *errorMessage, NSError *error) {
                                 NSLog(@"取得紅利 failure");
                                 self.estimateTimeLabel.text = [NSString stringWithFormat:@"您目前累計點數：伺服器回應錯誤"];
                                 [self.estimateTimeLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
                                 self.bonusOverDateLabel.text = [NSString stringWithFormat:@"到期點數：伺服器回應錯誤"];
                             }];
    
    if(self.manager.userTitle)
    {
        self.carNumberLabel.text = [NSString stringWithFormat:@"%@ 您好",
                                    self.manager.userTitle];
    }
    
    if(self.manager.currentAppMode == AppModeTWTaxi)
    {
        // self.estimateTimeLabel.text = @"歡迎使用台灣大車隊網路訂車服務";
        self.taxiCallLabel.text = @"55688叫車";
        NSString *mpvn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_KEY_USE_MVPN] ? [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULT_KEY_MVPN] : @"";
        self.callNumber = [NSString stringWithFormat:@"%@%@", mpvn, @"55688"] ;
    }
    else
    {
        // self.estimateTimeLabel.text = @"歡迎使用城市衛星網路訂車服務";
        self.taxiCallLabel.text = @"55899叫車";
        self.callNumber = @"55899";
    }
    
//    self.cancelOrderLabel.text = @"登出";
    self.cancelBtn.hidden = YES;
    self.personBtn.hidden = NO;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_MAKE_CALL)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSString *callString = [NSString stringWithFormat:@"tel:%@", self.callNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callString]];
        }
        else if(buttonIndex == alertView.firstOtherButtonIndex + 1)
        {
            NSString *callString = [NSString stringWithFormat:@"tel:99%@", self.callNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callString]];
        }
    }
    else if (alertView.tag == ALERT_CANCEL_ORDER)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSLog(@"%@",self.manager.currentOrderID);
            if(self.manager.currentOrderID.length)
            {
                [SVProgressHUD showWithStatus:@"取消叫車中..." maskType:SVProgressHUDMaskTypeClear];
                NSLog(@"self currentID %@",self.manager.currentOrderID);
                
                [self.manager cancelTaxiOrderWithBlock:self.manager.currentOrderID success:^{
                    
                    [self.manager updateProcessOrderWithKey:self.manager.currentOrderKey result:ORDER_STATUS_FAILURE_CANCEL_AFTER_DISPATCH cancelOn:[NSDate date]];
                    
                    [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                    
                    [self configStatusView];
                    
                    
                } failure:^{
                    NSLog(@"cancel order error");
                    [SVProgressHUD dismiss];
                    [self.manager showOrderCancelErrorAlert];
                    NSLog(@"%@",self.manager.currentOrderID);
//                    [self configStatusView];
                    
                }];
                
                
            }
            
            
        }
    }
    else if(alertView.tag == ALERT_AUTOBUTTON_UI){
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //modified by kiki Huang 2014.02.10
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"changeHomeButtonUI" object:nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DownloadImage" object:self];
        }
        else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveMenuVersion" object:self];
//            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ImageIsDownload"];
        }
    }
    else if(alertView.tag == ALERT_PUSH){
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self functionOpen];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushFunctionTag"];
        isalertShow = false;
    }
    if(alertView.tag == ALERT_PUSH_URL){
        if (buttonIndex==1) {
            isalertShow = false;
            NSLog(@"kobe %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"]);
            SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"]]];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            swc.availableActions = SVWebViewControllerAvailableActionsNone;
            swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
            swc.toolbar.barStyle = UIBarStyleBlackOpaque;
            swc.playWebViewController.navigationItem.title = @"連結網頁";
            
            [delegate presentModalViewController:swc animated:YES];
            [swc release];
        }
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"pushUrl"];
    }

}

#pragma mark - notif

- (void)handleSignInSuccessful:(NSNotification *)notif
{
    //edited by kiki Huang 2014.02.06
    FaceInfo *f = [self searchData];
    if (f!=nil) {
        NSLog(@"picturePath :%@",f.picturePath);
        UIImage *image = [UIImage imageWithContentsOfFile:f.picturePath];
        NSLog(@"0900000000:%@",image);
        [self.personBtn setImage:[UIImage imageWithContentsOfFile:[self getImageFilePath:f.picturePath]] forState:UIControlStateNormal];
    }
    f = nil;

    //edited by kiki Huang 2014.01.17
    if (isalertShow) {
        isalertShow = false;
    }
    self.view.userInteractionEnabled = YES;
    [self handlePush];// if kill app it will restart to trigger when user login
    
    viewDidLoadFirst = FALSE;
    
    //    [super handleSignInSuccessful:notif];
    [self configStatusView];
    
    [AutoButtonManager sharedInstance].alertDelegate = self;
    NSString *type =@" ";
    
    if (IS_IPHONE_5) {
        type = @"M";
    }else
        type = @"S";
    
    //    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type", nil];
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type", nil];
        [self.manager taxiMenuUIButton:parameter success:^(id JSON) {
            
            NSLog(@"success autobtn %@",JSON);
            [[AutoButtonManager sharedInstance] setupMenuButton:JSON ];
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"Error :%@",error);
        }];
        parameter = nil;
    });
}

// edited by kiki Huang 2014.01.17---------------------------------------------------------------
- (void)signViewPresent {
    isalertShow = true;
    [pushUrlAlert dismissWithClickedButtonIndex:-1 animated:NO];
}
- (void)handlePush {
    if (!isalertShow) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"PushFunctionTag"])
        {
            NSString *msg = @"";
            
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"PushMessage"]) {
                
                msg = [[NSUserDefaults standardUserDefaults]objectForKey:@"PushMessage"];
            }
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"台灣大車隊" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
            alert.tag = ALERT_PUSH;
            [alert show];
            isalertShow = true;
            alert = nil;
        }
        
    }
    
}
-(void)handleUrlPushForHome{
    
    if (!isalertShow) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"])
        {
            NSString *msg = @"";
            
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"PushUrlMessage"]) {
                
                msg = [[NSUserDefaults standardUserDefaults]objectForKey:@"PushUrlMessage"];
            }
            pushUrlAlert =[[UIAlertView alloc]initWithTitle:@"台灣大車隊" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
            pushUrlAlert.tag = ALERT_PUSH_URL;
            [pushUrlAlert show];
            isalertShow = true;
//            pushUrlAlert = nil;
        }
        
    }
}
-(BOOL) doesAlertViewExist {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if (alert || action)
                return YES;
        }
    }
    return NO;
}


-(void)functionOpen{
    NSString *s = [[NSUserDefaults standardUserDefaults]objectForKey:@"PushFunctionTag"];
    if ([s isEqualToString:@"A_1"]) {
        [self appCallTaxi:nil];
    }
    else if ([s isEqualToString:@"A_2"]){
        [self telCallTaxi:nil];
    }else if ([s isEqualToString:@"A_3"]){
        [self memberArea:nil];
        
    }else if ([s isEqualToString:@"A_4"]){
        [self rating:nil];
    }else if ([s isEqualToString:@"A_5"]){
        [self pointBtnPressed:nil];
    }else if ([s isEqualToString:@"A_6"]){
        [self messageBtnPressed:nil];
    }else if ([s isEqualToString:@"A_7"]){
        [self taxiPlayButtonPressed:nil];
    }else if ([s isEqualToString:@"A_8"]){
        [self taxiTicketButtonPressed:nil];
    }
}

//------------------------------------------------------------------------------------------
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
#pragma mark - AutoButtonManager Delegate

//edited by kiki Huang 2013.12.30
-(void)showChangeMenuUIAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"主選單主題更新" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
    alert.tag =ALERT_AUTOBUTTON_UI;
    [alert show];
    alert = nil;
}

#pragma mark - ImagePicker Delegate and Methods
//edited by kiki Huang 2014.01.03
-(void) snapImage{
    // initial imgae picker
	imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePickerController.delegate = self;
	
//	if (IS_IPHONE)
//	{
        [self presentViewController:imagePickerController animated:YES completion:nil];
//	}
//	else
//	{
//        if (popoverController) [popoverController dismissPopoverAnimated:NO];
//        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
//        popoverController.delegate = self;
//        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//	}
}

-(void)pushImageCropController:(UIImage*)img{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    PECropViewController *controller = [[[PECropViewController alloc] init] autorelease];
    controller.delegate = self;
    controller.image = img;
    
    controller.keepingCropAspectRatio = YES;
    
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:controller] autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [delegate presentModalViewController:nav animated:YES];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *img =[croppedImage imageByScalingAndCroppingForSize:CGSizeMake(180, 180)];
        
        NSData *imageData = UIImageJPEGRepresentation(img, 1);
        
        BOOL save = [imageData writeToFile:[self saveFacePicturePath] atomically:YES];
        if (save) {
            NSLog(@"write image file successed");
            
            //edited by kiki Huang 2014.02.06
            FaceInfo *f = [self searchData];
            if (f != nil) {
                f.userID = self.manager.userID;
//                f.picturePath = [self saveFacePicturePath];
                f.picturePath = [NSString stringWithFormat:@"%@.jpg", self.manager.userID];
                [self.orderManager save];
                
                f = nil;
            }
            else {
//                [self addData:[self saveFacePicturePath]];
                [self addData:[NSString stringWithFormat:@"%@.jpg", self.manager.userID]];
            }
            
        }else{
            
            NSLog(@"write image file failure");
            [imageData writeToFile:[self saveFacePicturePath] atomically:YES];//save again
        }
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            FaceInfo *f1 = [self searchData];
            NSLog(@"%@", f1.picturePath);
//            [self.personBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            [self.personBtn setImage:[UIImage imageWithContentsOfFile:[self getImageFilePath:f1.picturePath]] forState:UIControlStateNormal];
        });
    });
    
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

// reload image，if the device is iPhone, dismiss ViewController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self pushImageCropController:info[UIImagePickerControllerOriginalImage]];
    
    imagePickerController = nil;
    
}
//Image picker delegate functions
-(void) imgaePickerControllerDidCancel:(UIImagePickerController *) picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    imagePickerController = nil;
}
- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *)error contextInfo:(void *)contextInfo;
{
    if (!error)
        NSLog(@"Image written to photo album");
    else
        NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
}

#pragma mark - ImagePicker get pictures from camera roll

//edited by kiki Huang 2014.01.03
CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}
- (void) pickImage
{
	// Create an initialize the picker
	imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	
//	if (IS_IPHONE)
//	{
        [self presentModalViewController:imagePickerController animated:YES];
//	}
//	else
//	{
//        if (popoverController) [popoverController dismissPopoverAnimated:NO];
//        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
//        popoverController.delegate = self;
//        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//	}
}

- (void) loadImageFromAssetURL: (NSURL *) assetURL
{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    
    ALAssetsLibraryAssetForURLResultBlock result = ^(ALAsset *__strong asset){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        __block CGImageRef cgImage = [assetRepresentation CGImageWithOptions:nil];
        
        if (cgImage){
            NSLog(@"%d",assetRepresentation.orientation);
            UIImage *image2 = [UIImage imageWithCGImage:cgImage];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                

                UIImage *resultImage= [[image2 imageByScalingAndCroppingForSize:CGSizeMake(180, 180)] fixOrientation:assetRepresentation];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.personBtn setImage:resultImage forState:UIControlStateNormal];
                    [UIImageJPEGRepresentation(resultImage, 1) writeToFile:[self saveFacePicturePath] atomically:YES];
                });
            });
            
        }
        
    };
    
    ALAssetsLibraryAccessFailureBlock failure = ^(NSError *__strong error){
        NSLog(@"Error retrieving asset from url: %@", [error localizedFailureReason]);
    };
    
    [library assetForURL:assetURL resultBlock:result failureBlock:failure];
}
-(NSString *) saveFacePicturePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", self.manager.userID]];
    return dataPath;
}
-(NSString *)getImageFilePath:(NSString *)filename{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}
-(CGSize)reSizeDownLoadImageFrame:(CGSize)imageSize {
    CGFloat deviceOffset = 60;
    
    
    CGFloat tempSize = imageSize.width;
    CGFloat tempSize1 = imageSize.height;
    
    tempSize = (tempSize > tempSize1) ? tempSize : tempSize1;
    tempSize1 = tempSize / deviceOffset;
    
    return CGSizeMake(imageSize.width / tempSize1, imageSize.height / tempSize1);
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    NSLog(@"content offset x %f",scrollView.contentOffset.x);

    if (scrollView.contentOffset.x >=scrollView.contentSize.width - scrollView.frame.size.width-10) {
        
        leftArrow.hidden = NO;
        rightArrow.hidden = YES;
    }else if (scrollView.contentOffset.x <=10){
        leftArrow.hidden = YES;
        rightArrow.hidden = NO;
    }
    else if(scrollView.contentOffset.x>10 && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width-10){
        leftArrow.hidden = NO;
        rightArrow.hidden = NO;
    }

}

#pragma mark- FaceInfoCoreData methods

- (FaceInfo *)searchData
{
    prc = nil;
    
    
    // setup fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FaceInfo" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
    
    // setup predicate
    if(self.manager.userID)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", self.manager.userID];
        [fetchRequest setPredicate:predicate];
    }
    
    
    // setup sorting
    NSSortDescriptor *sort1 = [[[NSSortDescriptor alloc] initWithKey:@"userID" ascending:YES] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, nil]];
	[fetchRequest setFetchBatchSize:20];
    
	
    NSLog(@"kk : %@", prc);
	prc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                              managedObjectContext:self.context
                                                sectionNameKeyPath:nil
                                                         cacheName:nil];
    
	[fetchRequest release];
	
	NSError *error;
	if (![prc performFetch:&error])
    {
		// Update to handle the error appropriately.
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	else
    {
        if ([[[prc sections] objectAtIndex:0] numberOfObjects] != 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            FaceInfo *f = [prc objectAtIndexPath:indexPath];
            return f;
        }
	}
    
    return nil;
}

- (void)addData:(NSString *)path
{
    FaceInfo *p = nil;
    
    p = [self.orderManager createFaceInfo];
    
    NSLog(@"%@", self.manager.userID);
    p.userID = self.manager.userID;
    p.picturePath = path;
    NSLog(@"%@, %@", p.userID, path);
    
    [self.orderManager save];
}

@end

#pragma mark - Fixed Image Orientation when snap a picture
@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation:(ALAssetRepresentation*)alasset{
    
    
    NSInteger alassert1;
    if (alasset == nil) {
        // No-op if the orientation is already correct
        if (self.imageOrientation == UIImageOrientationUp)
            return self;
        alassert1 = (NSInteger)self.imageOrientation;
    }
    
    else {
        alassert1 =(NSInteger)alasset.orientation;
    }
    
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (alassert1) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (alassert1) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (alassert1) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

@implementation UIImage (Extras)

#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO)
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor)
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		}
        else
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil)
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}



@end