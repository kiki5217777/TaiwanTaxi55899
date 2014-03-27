//
//  SettingsViewController.m
//  TaiwanTaxi
//
//  Created by jason on 9/15/13.
//
//

#import "SettingsViewController.h"
#import "EditMemberViewController.h"
#import "OtherSettingsViewController.h"

#import "AppDelegate.h"
#import "UINavigationController+Customize.h"

@interface SettingsViewController ()
@property (nonatomic, retain) EditMemberViewController *editMember;
@property (nonatomic, retain) OtherSettingsViewController *otherSettings;
@end

@implementation SettingsViewController

- (void)dealloc {
    [_buttonsView release];
    [_contentView release];
    [_editAccountBtn release];
    [_otherSettingsBtn release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - memory management

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
    
    // -------------------- nav bar --------------------
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"關閉"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(close)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- view controllers --------------------
    
    self.editMember = [[[EditMemberViewController alloc] init] autorelease];
    self.otherSettings = [[[OtherSettingsViewController alloc] init] autorelease];
}

- (void)viewDidUnload
{
    [self setButtonsView:nil];
    [self setContentView:nil];
    [self setEditAccountBtn:nil];
    [self setOtherSettingsBtn:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self btnPressed:self.editAccountBtn];
}

#pragma mark - user interaction

- (IBAction)btnPressed:(id)sender
{
    if(sender == self.editAccountBtn)
    {
        self.title = @"會員資料";
        [self showViewController:self.editMember];
        [self hideViewController:self.otherSettings];
    }
    
    if(sender == self.otherSettingsBtn)
    {
        [self showViewController:self.otherSettings];
        [self hideViewController:self.editMember];
    }
    
    self.editAccountBtn.selected = sender == self.editAccountBtn;
    self.otherSettingsBtn.selected =sender == self.otherSettingsBtn;
}

-(void)close
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate dismissModalViewControllerAnimated:YES];
}

#pragma mark - view transition

- (void)showViewController:(UIViewController *)vc
{
    // only if view is not presented
    if(vc.parentViewController == nil)
    {
        // adjust the content view
        vc.view.frame = self.contentView.bounds;
        
        [self addChildViewController:vc];
        [self.contentView addSubview:vc.view];
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

@end
