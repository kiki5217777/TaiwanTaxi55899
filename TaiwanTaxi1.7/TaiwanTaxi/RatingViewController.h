//
//  RatingViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPickerViewButton.h"

@interface RatingViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) IBOutlet UILabel *carLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UISwitch *favoriteSwitch;
@property (retain, nonatomic) IBOutlet UIPickerViewButton *ratingButton;
@property (retain, nonatomic) IBOutlet UIButton *clearButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIImageView *star1;
@property (retain, nonatomic) IBOutlet UIImageView *star2;
@property (retain, nonatomic) IBOutlet UIImageView *star3;
@property (retain, nonatomic) IBOutlet UIImageView *star4;
@property (retain, nonatomic) IBOutlet UIImageView *star5;
@property (retain, nonatomic) IBOutlet UITextView *noteTextView;
@property (retain, nonatomic) UIPickerView *ratingPickerView;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (retain, nonatomic) NSManagedObjectID *orderID;
@property (retain, nonatomic) NSArray *starArray;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;
@property (retain, nonatomic) NSArray *ratingArray;
@property (assign, nonatomic) int selectedRating;
@property (assign, nonatomic) UITextView *currentActiveTextView;

- (IBAction)favoriteSwitchChanged:(id)sender;
- (IBAction)ratingButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;

@end
