//
//  BaseViewController.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "SVModalWebViewController.h"
#import "SVPlayWebViewController.h"
#define ALERT_PUSH_URL         14//edited by kiki Huang 2014.01.16
//#import "TestFlight.h"

@interface BaseViewController () {
    BOOL isalertShow;
}

@end

@implementation BaseViewController

@synthesize manager;
@synthesize orderManager;
@synthesize context;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

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
	// Do any additional setup after loading the view.
    isalertShow = false;
    if(self.manager == nil)
        self.manager = [TaxiManager sharedInstance];
    
    if(self.orderManager == nil)
        self.orderManager = [OrderManager sharedInstance];
    
    if(self.context == nil)
    {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.context = delegate.managedObjectContext;
    }
    
    self.notifCenter = [NSNotificationCenter defaultCenter];
    self.userDefault = [NSUserDefaults standardUserDefaults];
    
    // common notification
    [self.notifCenter addObserver:self
                         selector:@selector(handleSignInSuccessful:)
                             name:SIGN_IN_SUCCESS_NOTIFICATION
                           object:nil];
    
//    [self.notifCenter addObserver:self selector:@selector(handleUrlPush) name:@"PushUrl" object:nil];
//    [self handleUrlPush];
    
#ifdef __IPHONE_7_0
    if([[UIDevice currentDevice].systemVersion hasPrefix:@"7"])
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif

}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewDidUnload
{
    [self setManager:nil];
    [self setOrderManager:nil];
    [self setContext:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:NO];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - notification handling

- (void)handleSignInSuccessful:(NSNotification *)notif
{
    
}

#pragma mark - helper

- (void)executeBlock:(void (^)())block withDelay:(NSTimeInterval)delayInSeconds
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(block)
            block();
    });
}

- (void)passCheckpoint:(NSString *)checkPointName
{
//    if(IS_DEBUG_MODE == YES)
//        [TestFlight passCheckpoint:checkPointName];
}

- (BOOL)isRetina4inch
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (scale == 2.0f)
        {
            if (pixelHeight == 1136.0f)
                return YES;
        }
    }
    return NO;
}

- (BOOL)isRunningiOS6
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] <= 6.0;
}

- (BOOL)isRunningiOS7
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0;
}

- (void)handleClickAd:(id)urlObj
{
    if([urlObj isKindOfClass:[NSNull class]] == NO)
    {
        NSString *urlString = (NSString *)urlObj;
        NSURL *url = [NSURL URLWithString:[@"http://www.taiwantaxi.com.tw/" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if(urlString.length)
            url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}
/*
-(void)handleUrlPush{
    if (!isalertShow) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"])
        {
            NSString *msg = @"";
            
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"PushUrlMessage"]) {
                
                msg = [[NSUserDefaults standardUserDefaults]objectForKey:@"PushUrlMessage"];
            }
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"台灣大車隊" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
            alert.tag = ALERT_PUSH_URL;
            [alert show];
            isalertShow = true;
            alert = nil;
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == ALERT_PUSH_URL){
        if (buttonIndex==1) {
//            [[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"];
            SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"]]];
            
//            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            swc.availableActions = SVWebViewControllerAvailableActionsNone;
            swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
            swc.toolbar.barStyle = UIBarStyleBlackOpaque;
            swc.playWebViewController.navigationItem.title = @"連結網頁";
            
            //            UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:swc]autorelease];
            //            [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
            
            [self presentModalViewController:swc animated:YES];
            [swc release];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pushUrl"];
        }
        
        isalertShow=false;
    }
}
*/
@end
