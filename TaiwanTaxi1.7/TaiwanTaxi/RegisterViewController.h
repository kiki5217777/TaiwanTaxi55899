//
//  RegisterViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPickerViewButton.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface RegisterViewController : BaseViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, CustomAdBannerViewDelegate, TWMTAMediaViewDelegate>
{
    int currentOccupationIndex;
    int currentBirthDayYear;
    int currentBirthDayMonth;
    int currentBirthDayDay;
    BOOL isMale;
    UITextField *currentActiveTextField;
    int currentCardIndex;
}

@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;

//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

@property (retain, nonatomic) IBOutlet UITextField *accountIDTextField;
@property (retain, nonatomic) IBOutlet UITextField *accountPwdTextField;
@property (retain, nonatomic) IBOutlet UITextField *pwdAgainTextField;
@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UIButton *maleButton;
@property (retain, nonatomic) IBOutlet UIButton *femaleButton;
@property (retain, nonatomic) IBOutlet UILabel *occupationLabel;

@property (retain, nonatomic) IBOutlet UIPickerViewButton *occupationButton;
@property (retain, nonatomic) IBOutlet UILabel *birthdayLabel;

@property (retain, nonatomic) IBOutlet UIPickerViewButton *birthdayButton;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;

@property (retain, nonatomic) UIPickerView *occupationPickerView;
@property (retain, nonatomic) UIDatePicker *birthdayPickerView;
@property (retain, nonatomic) NSArray *occupationArray;
@property (retain, nonatomic) IBOutlet UIToolbar *birthdayInputToolBar;
@property (retain, nonatomic) NSArray *cardArray;

@property (retain, nonatomic) IBOutlet UILabel *cardLabel;
@property (retain, nonatomic) IBOutlet UIPickerViewButton *cardButton;
@property (retain, nonatomic) UIPickerView *cardPickerView;


- (IBAction)birthdayInputDoneButtonPressed:(id)sender;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;

@end
