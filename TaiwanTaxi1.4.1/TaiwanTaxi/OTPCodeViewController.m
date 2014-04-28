//
//  OTPCodeViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OTPCodeViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"


@implementation OTPCodeViewController

#pragma mark - synthesize

@synthesize codeTextField;

#pragma mark - dealloc

- (void)dealloc
{
    [codeTextField release];
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
    
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"OTP Screen";
}

- (void)viewDidUnload
{
    [self setCodeTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)activateButtonPressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"驗證中..."];
    [self.view endEditing:NO];
    
    NSString *code = self.codeTextField.text;
    NSString *uId = self.manager.userID;
    [self.manager performOTPWith:uId code:code success:^(int code) {
        [SVProgressHUD showSuccessWithStatus:@"驗證成功"];
        
        [self.manager logInWithUserID:self.manager.userID
                                  pwd:self.manager.userPwd success:^
         {
             [SVProgressHUD showSuccessWithStatus:@"登入成功"];
             self.manager.isLogIn = YES;
             [self.manager saveUserInfo];
             
             AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [delegate dismissModalViewControllerAnimated:YES];
         }
                              failure:^(NSString *errorMessage, NSError *error)
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
             self.manager.isLogIn = NO;
             [self.manager saveUserInfo];
         }];
        
    } failure:^(int code, NSString *errorMessage, NSError *error) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

- (IBAction)resendButtonPressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"申請中..."];
    [self.view endEditing:NO];
    
    NSString *uId = self.manager.userID;
    [self.manager requestOTPCode:uId success:^(int code) {
        [SVProgressHUD showSuccessWithStatus:@"驗證碼已送出, 請稍等.."];
    } failure:^(int code, NSString *errorMessage, NSError *error) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

@end
