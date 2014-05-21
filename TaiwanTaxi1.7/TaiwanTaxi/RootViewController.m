//
//  RootViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "CallMenuViewController.h"
#import "HomeViewController.h"
#import "MemberSectionViewController.h"
#import "SVWebViewController.h"
#import "NewsMessageViewController.h"

#import "AppDelegate.h"
#import "TaxiManager.h"

#import "DDlog.h"


@implementation RootViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize homeViewController;

#pragma mark - dealloc

- (void)dealloc
{
    [homeViewController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - setup

- (void)setupTabBarControllers
{
    // set up the tab bar controllers
    NSMutableArray *array = [NSMutableArray array];
    
    // 1.
    CallMenuViewController *callCar = [[[CallMenuViewController alloc] initWithNibName:@"CallMenuViewController" bundle:nil] autorelease];
    callCar.title = @"網路叫車";
    UINavigationController *nav1 = [[[UINavigationController alloc] initWithRootViewController:callCar] autorelease];
    [nav1.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [array addObject:nav1];
    
    // 2.
    MemberSectionViewController *member = [[MemberSectionViewController alloc] init];
    member.title = @"會員專區";
    UINavigationController *nav2 = [[[UINavigationController alloc] initWithRootViewController:member] autorelease];
    [nav2.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [array addObject:nav2];
    [member release];
    
    // 3.
    NewsMessageViewController *message = [[NewsMessageViewController alloc] initWithNibName:nil bundle:nil];
    message.title = @"訊息快遞";
    UINavigationController *nav3 = [[[UINavigationController alloc] initWithRootViewController:message] autorelease];
    [nav3.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    nav3.toolbar.barStyle = UIBarStyleBlackOpaque;
    [array addObject:nav3];
    [message release];
    
    self.viewControllers = array;
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)setupHomeViewController
{
    HomeViewController *hvc = [[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil] autorelease];
    self.homeViewController = hvc;
    
    [self showViewController:self.homeViewController animated:NO];
    
    self.homeViewController.view.userInteractionEnabled = false;
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(changeToTab:)
												 name:CHANGE_TAB_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showHomePage:)
												 name:SHOW_HOME_PAGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(hideHomePage:)
												 name:HIDE_HOME_PAGE_NOTIFICATION
                                               object:nil];
    //edited by kiki Huang 2014.02.05
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableSelfView:) name:TAXI_TABBAR_DISABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSelfView:) name:TAXI_TABBAR_ENABLE object:nil];
    //--------------------------------
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTabBarControllers];
    [self setupHomeViewController];
    [self setupNotification];
    
    [self performSelector:@selector(handleLogInProcess)
               withObject:nil
               afterDelay:0.3];

}

- (void)viewDidUnload
{
    [self setHomeViewController:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - helper methods

- (void)handleLogInProcess
{
    
    TaxiManager *manager = [TaxiManager sharedInstance];

    if(manager.autoLogIn == YES)
    {
//        [SVProgressHUD showWithStatus:@"登入中..."];
        [SVProgressHUD showWithStatus:@"登入中.." maskType:SVProgressHUDMaskTypeClear];
        
        [manager logInWithUserID:manager.userID
                             pwd:manager.userPwd
                         success:^
         {
             [SVProgressHUD showSuccessWithStatus:@"登入成功"];
             
             
         }
                         failure:^(NSString *errorMessage, NSError *error)
         {
             
             [SVProgressHUD showErrorWithStatus:errorMessage];
             manager.isLogIn = NO;
             [manager saveUserInfo];
             
             [self openSignIn];
             
         }];
    }
    else
    {
        [self openSignIn];
    }
}

- (void)openSignIn
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showSignInView];
}

- (void)changeToTab:(NSNotification *)notif
{
	NSNumber *tabIndex = (NSNumber *)[notif object];
    self.selectedIndex = [tabIndex intValue];
    
    DDLogInfo(@"%@: %@ - %d", THIS_FILE, THIS_METHOD, self.selectedIndex);
}

- (void)showHomePage:(NSNotification *)notif
{
    DDLogInfo(@"showHomePage");
        
    [self showViewController:self.homeViewController animated:YES];
    [self.homeViewController configStatusView];
}

- (void)hideHomePage:(NSNotification *)notif
{
    DDLogInfo(@"hideHomePage");
    
    [self hideViewController:self.homeViewController animated:YES];
}

- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated
{
    // only if view is not presented
    if(vc.parentViewController == nil)
    {
        if(animated)
        {
            [self addChildViewController:vc];
            
            if(vc.isViewLoaded == NO)
            {
                // need to adjust the y to compensate the status bar
                CGRect hvcRect = CGRectMake(0, 0, 320, 460);
                if([self isRetina4inch] == YES)
                    hvcRect = CGRectMake(0, 0, 320, 548);
                hvcRect.origin.y = 20;
                self.homeViewController.view.frame = hvcRect;
            }
            
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.view addSubview:vc.view];
                            }
                            completion:^(BOOL finished) {
                                [vc didMoveToParentViewController:self];
                            }];
        }
        else
        {
            [self addChildViewController:vc];
            
            if(vc.isViewLoaded == NO)
            {
                // need to adjust the y to compensate the status bar
                CGRect hvcRect = CGRectMake(0, 0, 320, 460);
                if([self isRetina4inch] == YES)
                    hvcRect = CGRectMake(0, 0, 320, 548);
                hvcRect.origin.y = 20;
                self.homeViewController.view.frame = hvcRect;
            }
            
            [self.view addSubview:vc.view];
            [vc didMoveToParentViewController:self];
        }
    }
}

- (void)hideViewController:(UIViewController *)vc animated:(BOOL)animated
{
    // only if view is presented
    if(vc.parentViewController)
    {
        if(animated)
        {
            [vc willMoveToParentViewController:nil];
            
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [vc.view removeFromSuperview];
                            }
                            completion:^(BOOL finished) {
                                [vc removeFromParentViewController];
                            }];
        }
        else
        {
            [vc willMoveToParentViewController:nil];
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
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

//edited by kiki Huang 2014.02.05
-(void)disableSelfView:(NSNotification *)notif{
    self.tabBar.userInteractionEnabled = NO;
}
-(void)enableSelfView:(NSNotification *)notif{
    self.tabBar.userInteractionEnabled = YES;
}
@end
