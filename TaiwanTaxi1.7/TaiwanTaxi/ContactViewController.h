//
//  ContactViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ContactViewController : BaseViewController
{
    
}

// for adjusting the view base on app mode
@property (retain, nonatomic) IBOutlet UIImageView *modeButtonsBg;
@property (retain, nonatomic) IBOutlet UIButton *contactBtn;
@property (retain, nonatomic) IBOutlet UIImageView *modeTextImageView;
@property (retain, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *telLabel;
@property (retain, nonatomic) IBOutlet UILabel *emailLabel;
@property (retain, nonatomic) IBOutlet UIImageView *textViewBg;

@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UIButton *recordsBtn;
@property (retain, nonatomic) IBOutlet UIButton *relievedBtn;
@property (retain, nonatomic) IBOutlet UIButton *bonusBtn;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *telTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UIImageView *contentTextViewBgImageView;
@property (retain, nonatomic) IBOutlet UITextView *contextTextView;
@property (retain, nonatomic) IBOutlet UIButton *clear;
@property (retain, nonatomic) IBOutlet UIButton *submit;

- (IBAction)bonusBannerPressed:(id)sender;
- (IBAction)routerRecords:(id)sender;
- (IBAction)relievedService:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;

@end
