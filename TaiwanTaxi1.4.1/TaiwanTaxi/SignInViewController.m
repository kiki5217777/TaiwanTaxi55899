//
//  SingInViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"
#import "RegisterViewController.h"
#import "TextAlertView.h"
#import "SVModalWebViewController.h"
#import "SVPlayWebViewController.h"

@implementation SignInViewController{
    BOOL isalertShow;
}

#pragma mark - define

#define TAG_REGISTER_ALERT 12
#define ALERT_PUSH_URL     14

#pragma mark - synthesize

@synthesize userIDTextField;
@synthesize userPwdTextField;
@synthesize autoLogInSwitch;

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [userIDTextField release];
    [userPwdTextField release];
    [autoLogInSwitch release];
//    [_adBannerView release];
//    _adBannerView = nil;
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
    // Do any additional setup after loading the view from its nib.
    
    isalertShow = false;
    
    self.userIDTextField.text = self.manager.userID;
    self.userPwdTextField.text = self.manager.userPwd;
    
    // -------------------- navigation bar buttons --------------------
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"註冊"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(registerAccount)];
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"Sign-in Screen";
    
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
    
    [self configNaviBarTitle];
    [self.notifCenter addObserver:self selector:@selector(handleUrlPush) name:@"PushUrl" object:nil];
    [self handleUrlPush];
}
//-(void)viewDidAppear:(BOOL)animated{
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"pushUrl"]) {
//        
//    }
//}
- (void)viewDidUnload
{
//    self.adBannerView.delegate = nil;
    [self setUserIDTextField:nil];
    [self setUserPwdTextField:nil];
    [self setAutoLogInSwitch:nil];
//    [self setAdBannerView:nil];
    
    //edited by kiki Huang 2014.01.17
    [self.notifCenter removeObserver:self name:@"PushUrl" object:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)forgetPwdButtonPressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"處理中..."];
    
    [self.manager forgetPassword:self.userIDTextField.text success:^{
        [SVProgressHUD showSuccessWithStatus:@"已發送新的密碼到您的簡訊中"];
    } failure:^(NSString *errorMessage, NSError *error) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

- (IBAction)logInButtonPressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"登入中..."];
    
    
    
    [self.manager logInWithUserID:self.userIDTextField.text
                              pwd:self.userPwdTextField.text success:^
     {
         [SVProgressHUD showSuccessWithStatus:@"登入成功"];
         self.manager.isLogIn = YES;
         self.manager.autoLogIn = self.autoLogInSwitch.on;
         [self.manager saveUserInfo];
         
         //edited by kiki Huang 2014.01.17
         [self.notifCenter removeObserver:self name:@"PushUrl" object:nil];
         
         AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         [delegate dismissModalViewControllerAnimated:YES];
     }
                          failure:^(NSString *errorMessage, NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:errorMessage];
         self.manager.isLogIn = NO;
         [self.manager saveUserInfo];
     }];
}

- (void)registerAccount
{
    [self.userIDTextField resignFirstResponder];
    [self.userPwdTextField resignFirstResponder];
    NSString *title = @"";
    NSString *termOfService = @"";
    
    if(self.manager.currentAppMode == AppModeTWTaxi)
    {
        title = @"台灣大車隊註冊會員同意條款";
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"term"
                                                         ofType:@"txt"];
        termOfService = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    }
    else if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        title = @"衛星城市註冊會員同意條款";
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"term"
                                                         ofType:@"txt"];
        termOfService = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    }
    
    if([self isRunningiOS7])
    {
        // need to use parent vc's view cuz this third party control is lame
        TextAlertViewiOS7 *alert = [[[TextAlertViewiOS7 alloc] initWithTitle:title termOfService:termOfService parentView:self.parentViewController.view] autorelease];
        alert.tag = TAG_REGISTER_ALERT;
        alert.delegate = self;
        [alert show:0];
    }
    else
    {
        TextAlertView *alert = [[[TextAlertView alloc] initWithTitle:title
                                                       termOfService:termOfService] autorelease];
        alert.tag = TAG_REGISTER_ALERT;
        alert.delegate = self;
        [alert show];
    }
}

- (void)changeAppMode
{
    [SVProgressHUD show];
    [self.manager changeAppModeSuccess:^(NSString *message) {
        [SVProgressHUD showSuccessWithStatus:message];
        [self configNaviBarTitle];
    } failure:^(NSString *errorMessage, NSError *error) {
        [SVProgressHUD dismiss];
    }];
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
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.userIDTextField)
    {
        [self.userPwdTextField becomeFirstResponder];
    }
    else if(textField == self.userPwdTextField)
    {
        [self.userPwdTextField resignFirstResponder];
    }
    
    return YES;
}
//edited by kiki Huang 2014.02.13
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField==userPwdTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 11) ? NO : YES;
    }
    return YES;
}
#pragma mark - UIAlertViewDelegate
//modified by kiki Huang 2013.12.17
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == TAG_REGISTER_ALERT)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            RegisterViewController *rvc = [[RegisterViewController alloc] init];
            [self.navigationController pushViewController:rvc animated:YES];
            [rvc release];
        }
    }
    if(alertView.tag == ALERT_PUSH_URL){
        if (buttonIndex==1) {
            isalertShow = false;
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
        }
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"pushUrl"];
    }

}

//modified by kiki Huang 2013.12.17
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(alertView.tag == TAG_REGISTER_ALERT)
    {
        if(buttonIndex == 1) // 0:cancel 1:ok
        {
            RegisterViewController *rvc = [[RegisterViewController alloc] init];
            [self.navigationController pushViewController:rvc animated:YES];
            [rvc release];
        }
    }
    
    [alertView close];
}

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



#pragma mark - misc

- (void)configNaviBarTitle
{
    if (self.manager.currentAppMode == AppModeTWTaxi)
        self.title = @"台灣大車隊";
    else
        self.title = @"城市衛星";
}

@end
