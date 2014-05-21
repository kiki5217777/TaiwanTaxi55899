//
//  SingInViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface SignInViewController : BaseViewController <UITextFieldDelegate, CustomAdBannerViewDelegate, UIAlertViewDelegate,TWMTAMediaViewDelegate>

@property (retain, nonatomic) IBOutlet UITextField *userIDTextField;
@property (retain, nonatomic) IBOutlet UITextField *userPwdTextField;
@property (retain, nonatomic) IBOutlet UISwitch *autoLogInSwitch;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;


- (IBAction)forgetPwdButtonPressed:(id)sender;
- (IBAction)logInButtonPressed:(id)sender;

@end