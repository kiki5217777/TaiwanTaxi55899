//
//  MemberSectionViewController.m
//  TaiwanTaxi
//
//  Created by jason on 8/15/12.
//
//

#import "MemberSectionViewController.h"
#import "SettingsViewController.h"

#import "AppDelegate.h"
#import "UINavigationController+Customize.h"


@implementation MemberSectionViewController

@synthesize mvc;
@synthesize rvc;
@synthesize cvc;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mvc release];
    [rvc release];
    [cvc release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImage* anImage = [UIImage imageNamed:@"會員專區.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"會員專區" image:anImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];
    }
    return self;
}

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
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"會員資料"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(editMember)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- views --------------------
    
    MemberViewController *memberViewController = [[MemberViewController alloc] initWithNibName:@"MemberViewController"
                                                                                        bundle:nil];
    self.mvc = memberViewController;
    [memberViewController release];
    
    RelieveViewController *relieveViewController = [[RelieveViewController alloc] initWithNibName:@"RelieveViewController"
                                                                                           bundle:nil];
    self.rvc = relieveViewController;
    [relieveViewController release];
    
    ContactViewController *contactViewController = [[ContactViewController alloc] initWithNibName:@"ContactViewController"
                                                                                           bundle:nil];
    self.cvc = contactViewController;
    [contactViewController release];
    
    // default first view is member view controller
    [self showViewController:self.mvc];
    
    self.trackedViewName = @"Member Screen";
    
    // -------------------- notifications --------------------
    
    [self.notifCenter addObserver:self
                         selector:@selector(changeToRecordView:)
                             name:SHOW_MEMBER_RIDE_HISTORY_VIEW
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(changeToTrackingView:)
                             name:SHOW_MEMBER_TRACKING_VIEW
                           object:nil];
    
    [self.notifCenter addObserver:self
                         selector:@selector(changeToContactView:)
                             name:SHOW_MEMBER_CONTACT_VIEW
                           object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setMvc:nil];
    [self setRvc:nil];
    [self setCvc:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - views changing mechanism

- (void)changeToRecordView:(NSNotification *)notif
{
    [self showViewController:self.mvc];
    [self hideViewController:self.cvc];
    [self hideViewController:self.rvc];
}

- (void)changeToTrackingView:(NSNotification *)notif
{
    [self showViewController:self.rvc];
    [self hideViewController:self.cvc];
    [self hideViewController:self.mvc];
}

- (void)changeToContactView:(NSNotification *)notif
{
    [self showViewController:self.cvc];
    
    [self hideViewController:self.mvc];
    [self hideViewController:self.rvc];
}

- (void)showViewController:(UIViewController *)vc
{
    // only if view is not presented
    if(vc.parentViewController == nil)
    {
        vc.view.frame = self.view.bounds;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
}

- (void)hideViewController:(UIViewController *)vc
{
    // only if view is presented
    if(vc.parentViewController)
    {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
}

#pragma mark - user interaction

-(void)showHomePage
{
    [self.view endEditing:YES];
    [self.notifCenter postNotificationName:SHOW_HOME_PAGE_NOTIFICATION
                                    object:nil];
}

-(void)editMember
{
    [self.view endEditing:YES];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SettingsViewController *svc = [[[SettingsViewController alloc] init] autorelease];
    
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:svc] autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [delegate presentModalViewController:nav animated:YES];
}

@end
