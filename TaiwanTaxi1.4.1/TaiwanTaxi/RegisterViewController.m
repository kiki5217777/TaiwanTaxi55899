//
//  RegisterViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "OTPCodeViewController.h"
#import "UINavigationController+Customize.h"

@implementation RegisterViewController

#pragma mark - define

//#define CONTENT_VIEW_SIZE_3_5_INCH      430
//#define CONTENT_VIEW_SIZE_4_INCH        518
#define CARD_INDEX_OFFSET               20

#pragma mark - synthesize

@synthesize myScrollView;
@synthesize pwdAgainTextField;
@synthesize accountIDTextField;
@synthesize accountPwdTextField;
@synthesize userNameTextField;
@synthesize maleButton;
@synthesize femaleButton;
@synthesize occupationLabel;
@synthesize occupationButton;
@synthesize birthdayLabel;
@synthesize birthdayButton;
@synthesize emailTextField;
@synthesize occupationPickerView;
@synthesize birthdayPickerView;
@synthesize occupationArray;
@synthesize birthdayInputToolBar;
@synthesize cardArray;
@synthesize cardLabel;
@synthesize cardButton;
@synthesize cardPickerView;

#pragma mark - dealloc

- (void)dealloc
{
    [accountIDTextField release];
    [accountPwdTextField release];
    [userNameTextField release];
    [maleButton release];
    [femaleButton release];
    [occupationButton release];
    [birthdayButton release];
    [emailTextField release];
    [myScrollView release];
    [occupationLabel release];
    [birthdayLabel release];
    occupationPickerView.dataSource = nil;
    occupationPickerView.delegate = nil;
    [occupationPickerView release];
    [birthdayPickerView release];
    [occupationArray release];
    [birthdayInputToolBar release];
    [pwdAgainTextField release];
    [cardArray release];
    [cardLabel release];
    [cardButton release];
    cardPickerView.dataSource = nil;
    cardPickerView.delegate = nil;
    [cardPickerView release];
    [_myView release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release];  _adBannerView = nil;
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
    
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    // -------------------- view related --------------------
    
//    if([self isRetina4inch] == YES)
//        viewHeight = CONTENT_VIEW_SIZE_4_INCH;
//    else
//        viewHeight = CONTENT_VIEW_SIZE_3_5_INCH;
    
    viewWidth = 320;
    
    self.myScrollView.contentSize = self.myView.frame.size;
    [self.myScrollView addSubview:self.myView];
    
    occupationPickerView = [[UIPickerView alloc] init];
    occupationPickerView.delegate = self;
    occupationPickerView.dataSource = self;
    occupationPickerView.showsSelectionIndicator = YES;
    self.occupationButton.inputView = occupationPickerView;
    
    birthdayPickerView = [[UIDatePicker alloc] init];
    birthdayPickerView.datePickerMode = UIDatePickerModeDate;
    birthdayPickerView.maximumDate = [NSDate date];
    
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:1900];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [cal dateFromComponents:comps];
    
    birthdayPickerView.minimumDate = date;
    
    currentBirthDayYear = 1970;
    currentBirthDayMonth = 1;
    currentBirthDayDay = 1;
    [comps setDay:currentBirthDayDay];
    [comps setMonth:currentBirthDayMonth];
    [comps setYear:currentBirthDayYear];
    date = [cal dateFromComponents:comps];
    birthdayPickerView.date = date;
    
    self.birthdayButton.inputView = birthdayPickerView;
    self.birthdayButton.inputAccessoryView = self.birthdayInputToolBar;
    
    [birthdayPickerView addTarget:self
                           action:@selector(birthdayPickerValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.maleButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.maleButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.femaleButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    self.femaleButton.selected = YES;
    isMale = NO;
    
    cardPickerView = [[UIPickerView alloc] init];
    cardPickerView.delegate = self;
    cardPickerView.dataSource = self;
    cardPickerView.showsSelectionIndicator = YES;
    self.cardButton.inputView = cardPickerView;
    
    self.trackedViewName = @"Register Screen";
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
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

    // -------------------- data --------------------
    
    self.occupationArray = [NSArray arrayWithObjects:
                            @"上班族",
                            @"自營生意",
                            @"SOHO族",
                            @"學生",
                            @"家庭主婦",
                            @"軍公教", nil];
    
    self.cardArray = [NSArray arrayWithObjects:
                      @"中國信託",
                      @"國泰世華",
                      @"富邦",
                      @"台新",
                      @"花旗",
                      @"其它發卡行",
                      @"不使用信用卡", nil];
    
    currentOccupationIndex = 0;
    currentCardIndex = self.cardArray.count - 1;
    NSLog(@"%@",self.manager.occpuationChoices);
    for (NSString *str in self.manager.occpuationChoices.allKeys) {
        NSLog(@"%@: %@",str,[self.manager.occpuationChoices objectForKey:str]);
    }
    if(self.manager.occpuationChoices)
    {
        NSLog(@"%@",self.manager.occpuationChoices);
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[self.manager.occpuationChoices count]];
        for (int i =0; i<[self.manager.occpuationChoices count]; i++) {
            [tempArray addObject:[NSNull null]];
        }
        for (int i =0; i<[self.manager.occpuationChoices count]; i++) {
            NSDictionary *dict = [[self.manager.occpuationChoices objectForKey:[NSString stringWithFormat:@"0%d",i]] copy];
            [tempArray replaceObjectAtIndex:i withObject:dict];
           
        }
        for (int i = 0 ;i<[tempArray count];i++) {
            NSString *str = [tempArray objectAtIndex:i];
            NSLog(@"%d:%@",i,str);
        }
        /*
        __block NSMutableArray *array = [NSMutableArray array];
        [self.manager.occpuationChoices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array addObject:obj];
        }];
        for (NSString *str in array) {
            NSLog(@"array data :%@",str);
        }
        */
        self.occupationArray = tempArray;
        self.occupationLabel.text = [tempArray objectAtIndex:currentOccupationIndex];
    }
    
    if(self.manager.creditCardChoices)
    {
        __block NSMutableArray *array = [NSMutableArray array];
        [self.manager.creditCardChoices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array addObject:obj];
        }];
        
        currentCardIndex = 0;
        self.cardArray = array;
        self.cardLabel.text = [array objectAtIndex:currentCardIndex];
    }
}

- (void)viewDidUnload
{
    [self setAccountIDTextField:nil];
    [self setAccountPwdTextField:nil];
    [self setUserNameTextField:nil];
    [self setMaleButton:nil];
    [self setFemaleButton:nil];
    [self setOccupationButton:nil];
    [self setBirthdayButton:nil];
    [self setEmailTextField:nil];
    [self setMyScrollView:nil];
    [self setOccupationLabel:nil];
    [self setBirthdayLabel:nil];
    occupationPickerView.dataSource = nil;
    occupationPickerView.delegate = nil;
    [self setOccupationPickerView:nil];
    [self setBirthdayPickerView:nil];
    [self setBirthdayInputToolBar:nil];
    [self setPwdAgainTextField:nil];
    [self setCardLabel:nil];
    [self setCardButton:nil];
    cardPickerView.dataSource = nil;
    cardPickerView.delegate = nil;
    [self setCardPickerView:nil];
    [self setMyView:nil];
//    [self setAdBannerView:nil];
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

#pragma mark - user interaction

- (IBAction)birthdayInputDoneButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    
}

- (IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button == self.occupationButton)
    {
        [self.occupationButton becomeFirstResponder];
    }
    else if(button == self.birthdayButton)
    {
        [self.birthdayButton becomeFirstResponder];
    }
    else if(button == self.maleButton)
    {
        self.maleButton.selected = YES;
        self.femaleButton.selected = NO;
        isMale = YES;
    }
    else if(button == self.femaleButton)
    {
        self.maleButton.selected = NO;
        self.femaleButton.selected = YES;
        isMale = NO;
    }
    else if(button == self.cardButton)
    {
        [self.cardButton becomeFirstResponder];
    }
}

- (IBAction)submitButtonPressed:(id)sender
{
    [SVProgressHUD showWithStatus:@"註冊中..."];
    [self.view endEditing:NO];
    
    NSString *uID = self.accountIDTextField.text;
    NSString *pwd = self.accountPwdTextField.text;
    NSString *pwdAgain = self.pwdAgainTextField.text;
    NSString *name = self.userNameTextField.text;
    NSString *first = @"";
    if(name.length)
        first = [name substringToIndex:1];
    NSString *title = isMale == YES? @"先生" : @"小姐";
    title = [NSString stringWithFormat:@"%@%@", first, title];
    NSString *birthday = [NSString stringWithFormat:@"%d%.2d%.2d", currentBirthDayYear, currentBirthDayMonth, currentBirthDayDay];
    NSString *email = self.emailTextField.text;
    //modified by kiki Huang 2014.02.06
    NSString *career = [NSString stringWithFormat:@"%.2d", currentOccupationIndex];
    
    NSLog(@"%@",career);
    NSString *ages = @"29";
    NSString *card = [NSString stringWithFormat:@"%d", currentCardIndex + CARD_INDEX_OFFSET];
    
    if(pwd.length && [pwd isEqualToString:pwdAgain] == NO)
    {
        [SVProgressHUD showErrorWithStatus:@"密碼並不一致"];
        return;
    }
    
    if(pwd.length < 6)
    {
        [SVProgressHUD showErrorWithStatus:@"密碼不得少於6碼"];
        return;
    }
    
    if(pwd.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"密碼不得大於11碼"];
        return;
    }
    
    if(email.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"請輸入email"];
        return;
    }
    else
    {
        NSRange range = [email rangeOfString:@"@"];
        NSRange notFound = NSMakeRange(NSNotFound, 0);
        if(NSEqualRanges(range, notFound) == YES || range.location == 0 || range.location == email.length - 1)
        {
            [SVProgressHUD showErrorWithStatus:@"請輸入正確的email"];
            return;
        }
    }
    
    NSLog(@"%@",career);
    [self.manager registerAccountWithID:uID
                                    pwd:pwd
                                   name:name
                                  title:title
                               birthday:birthday
                                  email:email
                                 career:career
                                   ages:ages
                                   card:card
                                success:^(int code) {
        
                                    [SVProgressHUD showSuccessWithStatus:@"註冊成功"];
                                    
                                    OTPCodeViewController *ovc = [[OTPCodeViewController alloc] init];
                                    [self.navigationController pushViewController:ovc animated:YES];
                                    [ovc release];
        
    } failure:^(int code, NSString *errorMessage, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:errorMessage];
    }];
}

- (void)birthdayPickerValueChanged:(id)sender
{
    NSDate *date = self.birthdayPickerView.date;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    currentBirthDayYear = comps.year;
    currentBirthDayMonth = comps.month;
    currentBirthDayDay = comps.day;
    
    self.birthdayLabel.text = [NSString stringWithFormat:@"%d年%.2d月%.2d日", currentBirthDayYear, currentBirthDayMonth, currentBirthDayDay];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == self.occupationPickerView)
    {
        return self.occupationArray.count;
    }
    
    if(pickerView == self.cardPickerView)
    {
        return  self.cardArray.count;
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    
    if(pickerView == self.occupationPickerView)
    {
        title = [self.occupationArray objectAtIndex:row];
//        NSLog(@"title %@",title);
    }
    
    if(pickerView == self.cardPickerView)
    {
        title = [self.cardArray objectAtIndex:row];
    }
    
    return title;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if(pickerView == self.occupationPickerView)
    {
        title = [self.occupationArray objectAtIndex:row];
        self.occupationLabel.text = title;
        currentOccupationIndex = row;
    }
    
    if(pickerView == self.cardPickerView)
    {
        title = [self.cardArray objectAtIndex:row];
        self.cardLabel.text = title;
        currentCardIndex = row;
    }
    
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentActiveTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentActiveTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

//edited by kiki Huang 2014.02.13
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == accountPwdTextField || textField==pwdAgainTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 11) ? NO : YES;
    }
    return YES;
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
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    if(currentActiveTextField)
    {
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, currentActiveTextField.frame.origin) )
        {
            [self.myScrollView scrollRectToVisible:currentActiveTextField.frame animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.myScrollView.contentInset = contentInsets;
    self.myScrollView.scrollIndicatorInsets = contentInsets;
}

@end
