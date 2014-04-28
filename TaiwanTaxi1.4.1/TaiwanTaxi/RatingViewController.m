//
//  RatingViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RatingViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"

@interface RatingViewController ()
-(void)close;
@end

@implementation RatingViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define STAR_IMAGE_EMPTY        @"星星空.png"
#define STAR_IMAGE_FULL         @"星星滿.png"
#define STAR_COUNT_MAX          5
#define STAR_COUNT_MIN          0

#define CONTENT_VIEW_SIZE_3_5_INCH      416
#define CONTENT_VIEW_SIZE_4_INCH        504

#pragma mark - synthesize

@synthesize addressLabel;
@synthesize resultLabel;
@synthesize carLabel;
@synthesize timeLabel;
@synthesize favoriteSwitch;
@synthesize ratingButton;
@synthesize clearButton;
@synthesize submitButton;
@synthesize star1;
@synthesize star2;
@synthesize star3;
@synthesize star4;
@synthesize star5;
@synthesize noteTextView;
@synthesize dateFormatter;
@synthesize orderID;
@synthesize starArray;
@synthesize ratingPickerView;
@synthesize myScrollView;
@synthesize ratingArray;
@synthesize selectedRating;
@synthesize currentActiveTextView;

#pragma mark - dealloc

- (void)dealloc
{
    [addressLabel release];
    [resultLabel release];
    [carLabel release];
    [timeLabel release];
    [favoriteSwitch release];
    [ratingButton release];
    [clearButton release];
    [submitButton release];
    [star1 release];
    [star2 release];
    [star3 release];
    [star4 release];
    [star5 release];
    [noteTextView release];
    [dateFormatter release];
    [orderID release];
    [starArray release];
    [ratingPickerView release];
    [ratingArray release];
    
    [myScrollView release];
    [_myView release];
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
    
    self.title=@"搭車評價";
    
    // -------------------- navigation bar buttons --------------------
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"關閉" 
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft 
                                                                             target:self 
                                                                             action:@selector(close)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- view related --------------------
    
    if([self isRetina4inch] == YES)
        viewHeight = CONTENT_VIEW_SIZE_4_INCH;
    else
        viewHeight = CONTENT_VIEW_SIZE_3_5_INCH;
    
    viewWidth = 320;
    
    self.myScrollView.contentSize = CGSizeMake(viewWidth, viewHeight);
    self.currentActiveTextView = nil;
    self.favoriteSwitch.on = NO;
    self.noteTextView.text = @"";
    
    self.trackedViewName = @"Rating Screen";
    
    // -------------------- rating related --------------------
    
    ratingPickerView = [[UIPickerView alloc] init];
    ratingPickerView.delegate = self;
    ratingPickerView.dataSource = self;
    ratingPickerView.showsSelectionIndicator = YES;
    self.ratingButton.inputView = ratingPickerView;
    
    self.starArray = [NSArray arrayWithObjects:star1, star2, star3, star4, star5, nil];
    
    self.ratingArray = [NSArray arrayWithObjects:@"零顆星", @"一顆星", @"兩顆星", @"三顆星", @"四顆星", @"五顆星", nil];
    
    // -------------------- date formatter --------------------
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"HH:mm yyyy-MM-dd"];
    
    // -------------------- view data --------------------
    
    [self populateView];
    
    
    // -------------------- post view configuration --------------------
    
    /*
    TaxiOrder *o = (TaxiOrder *)[self.context objectWithID:self.orderID];
    
    if(o == nil || o.orderStatus.intValue != OrderStatusSubmittedSuccessful)
    {
        [SVProgressHUD showErrorWithStatus:@"目前沒有您的成功搭車記錄喔"];
        [self executeBlock:^{
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate dismissModalViewControllerAnimated:YES];
        } withDelay:0.5f];
    }
     */
}

- (void)viewDidUnload
{
    [self setAddressLabel:nil];
    [self setResultLabel:nil];
    [self setCarLabel:nil];
    [self setTimeLabel:nil];
    [self setFavoriteSwitch:nil];
    [self setRatingButton:nil];
    [self setClearButton:nil];
    [self setSubmitButton:nil];
    [self setStar1:nil];
    [self setStar2:nil];
    [self setStar3:nil];
    [self setStar4:nil];
    [self setStar5:nil];
    [self setNoteTextView:nil];
    [self setDateFormatter:nil];
    [self setOrderID:nil];
    [self setStarArray:nil];
    self.ratingPickerView.delegate = nil;
    [self setRatingPickerView:nil];
    [self setRatingArray:nil];
    [self setCurrentActiveTextView:nil];
    
    [self setMyScrollView:nil];
    [self setMyView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self subscribeForKeyboardEvents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unsubscribeFromKeyboardEvents];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView == self.ratingPickerView)
        return 1;
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == self.ratingPickerView)
        return self.ratingArray.count;
    
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if(pickerView == self.ratingPickerView)
    {
        title = [self.ratingArray objectAtIndex:row];
    }
    
    return title;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == self.ratingPickerView)
    {
        [self populateRating:row];
        self.selectedRating = row;
    }
    
    [self.view endEditing:YES];
}

#pragma mark - view data

- (void)populateView
{
    if(self.orderID == nil)
        return;
    
    TaxiOrder *o = (TaxiOrder *)[self.context objectWithID:self.orderID];
    
    if(o == nil)
        return;
    
    if(o.reviewInfo == nil)
    {
        o.reviewInfo = [self.orderManager createReviewInfo];
        [self.orderManager save];
    }
    
    // info at top
    self.addressLabel.text = o.pickupInfo.fullAddress;
    
    if(o.effect.intValue == OrderEffectSuccess)
    {
        self.resultLabel.textColor = [UIColor greenColor];
        self.resultLabel.text = @"成功";
        self.carLabel.text = [NSString stringWithFormat:@"車輛編號：%@", o.carNumber];
        self.timeLabel.text = [self.dateFormatter stringFromDate:o.createdDate];
    }
    else
    {
        self.resultLabel.textColor = [UIColor redColor];
        self.resultLabel.text = @"失敗";
        self.carLabel.text = @"";
        self.timeLabel.text = @"";
    }
    
    // setup the rating stars
    self.selectedRating = o.reviewInfo.rating.intValue;
    [self populateRating:self.selectedRating];
    
    self.noteTextView.text = o.reviewInfo.note;
}

- (void)populateRating:(int)rating
{
    for(UIImageView *star in self.starArray)
    {
        star.image = [UIImage imageNamed:STAR_IMAGE_EMPTY];
    }
    
    for(int i = 0; i < rating; i++)
    {
        if(i >= self.starArray.count)
            break;
        
        UIImageView *star = [self.starArray objectAtIndex:i];
        star.image = [UIImage imageNamed:STAR_IMAGE_FULL];
    }
}

#pragma mark - user interaction

-(void)close
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate dismissModalViewControllerAnimated:YES];
}

- (IBAction)favoriteSwitchChanged:(id)sender
{
    
}

- (IBAction)ratingButtonPressed:(id)sender
{
    [self.ratingButton becomeFirstResponder];
}

- (IBAction)clearButtonPressed:(id)sender
{
    self.favoriteSwitch.on = NO;
    self.selectedRating = 0;
    [self populateRating:self.selectedRating];
    
    self.noteTextView.text = @"";
}

- (IBAction)submitButtonPressed:(id)sender
{
    if(self.orderID == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"目前並沒有您的搭車記錄喔"];
        return;
    }
    
    TaxiOrder *o = (TaxiOrder *)[self.context objectWithID:self.orderID];
    
    if(o == nil || o.reviewInfo == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"目前並沒有您的搭車記錄喔"];
        return;
    }
    
    self.submitButton.enabled = NO;
    [SVProgressHUD showWithStatus:@"傳送中..."];
    
    o.reviewInfo.rating = [NSNumber numberWithInt:self.selectedRating];
    o.reviewInfo.note = self.noteTextView.text;
    o.reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusLocal];
    [self.orderManager save];
    
    [self.manager sendTaxiOrderEvaluation:o.orderID success:^{
        [SVProgressHUD showSuccessWithStatus:@"傳送成功"];
        self.submitButton.enabled = YES;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate dismissModalViewControllerAnimated:YES];
        
    } failure:^(NSString *errorMessage, NSError *error) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
        self.submitButton.enabled = YES;
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.currentActiveTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.currentActiveTextView = nil;
}

#pragma mark - keyboard

- (void)subscribeForKeyboardEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unsubscribeFromKeyboardEvents
{
    /* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.myScrollView.contentInset = contentInsets;
    self.myScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.myScrollView.contentInset = contentInsets;
    self.myScrollView.scrollIndicatorInsets = contentInsets;
}

@end
