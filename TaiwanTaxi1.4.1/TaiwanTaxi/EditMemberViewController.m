//
//  EditMemberViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditMemberViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"

@interface EditMemberViewController()
@property (nonatomic, retain) NSArray *indexArrayOccupation;
@property (nonatomic, retain) NSArray *indexArrayCard;
@end

@implementation EditMemberViewController

#pragma mark - define

#define CONTENT_VIEW_SIZE_3_5_INCH      416
#define CONTENT_VIEW_SIZE_4_INCH        504
#define CARD_INDEX_OFFSET               20

#pragma mark - synthesize

@synthesize myScrollView;
@synthesize accountPwdTextField;
@synthesize againPwdTextField;
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
@synthesize cardLabel;
@synthesize cardButton;
@synthesize cardPickerView;
@synthesize cardArray;

#pragma mark - dealloc

- (void)dealloc
{
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
    [cardLabel release];
    [cardButton release];
    [cardArray release];
    cardPickerView.dataSource = nil;
    cardPickerView.delegate = nil;
    [cardPickerView release];
    [_myView release];
    [_accountIdTextField release];
    [againPwdTextField release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release]; _adBannerView = nil;
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

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // -------------------- view related --------------------
    
    self.accountIdTextField.text = self.manager.userID;
    self.userNameTextField.text = self.manager.userName;
    self.accountPwdTextField.text = self.manager.userPwd;
    self.againPwdTextField.text = self.manager.userPwd;
    self.emailTextField.text = self.manager.userEmail;
    
    self.myScrollView.contentSize = self.myView.frame.size;
    [self.myScrollView addSubview:self.myView];
    
    occupationPickerView = [[UIPickerView alloc] init];
    occupationPickerView.delegate = self;
    occupationPickerView.dataSource = self;
    occupationPickerView.showsSelectionIndicator = YES;
    self.occupationButton.inputView = occupationPickerView;
    
    cardPickerView = [[UIPickerView alloc] init];
    cardPickerView.delegate = self;
    cardPickerView.dataSource = self;
    cardPickerView.showsSelectionIndicator = YES;
    self.cardButton.inputView = cardPickerView;
    
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
    
    if(self.manager.userBirthDay.length == 8)
    {
        NSString *b = self.manager.userBirthDay;
        NSRange r;
        r.location = 0;
        r.length = 4;
        currentBirthDayYear = [[b substringWithRange:r] intValue];
        r.location = 4;
        r.length = 2;
        currentBirthDayMonth = [[b substringWithRange:r] intValue];
        r.location = 6;
        r.length = 2;
        currentBirthDayDay = [[b substringWithRange:r] intValue];
    }
    
    [comps setDay:currentBirthDayDay];
    [comps setMonth:currentBirthDayMonth];
    [comps setYear:currentBirthDayYear];
    date = [cal dateFromComponents:comps];
    birthdayPickerView.date = date;
    
    self.birthdayLabel.text = [NSString stringWithFormat:@"%d年%.2d月%.2d日", currentBirthDayYear, currentBirthDayMonth, currentBirthDayDay];
    
    self.birthdayButton.inputView = birthdayPickerView;
    self.birthdayButton.inputAccessoryView = self.birthdayInputToolBar;
    
    [birthdayPickerView addTarget:self
                           action:@selector(birthdayPickerValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.maleButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.maleButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.femaleButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.femaleButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    self.femaleButton.selected = !self.manager.userIsMale;
    self.maleButton.selected = self.manager.userIsMale;
    isMale = self.manager.userIsMale;
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    // -------------------- data --------------------
    
    self.occupationArray = [NSArray arrayWithObjects:
                            @"上班族",
                            @"自營生意",
                            @"SOHO族",
                            @"學生",
                            @"家庭主婦",
                            @"軍公教", nil];
    
    self.indexArrayOccupation = [NSArray arrayWithObjects:
                                 @"00",
                                 @"01",
                                 @"02",
                                 @"03",
                                 @"04",
                                 @"05",
                                 @"06", nil];
    
    if(self.manager.occpuationChoices)
    {
        /*
        __block NSMutableArray *array1 = [NSMutableArray array];
        __block NSMutableArray *array2 = [NSMutableArray array];
        [self.manager.occpuationChoices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array1 addObject:obj];
            [array2 addObject:key];
            
            
        }];
        
        for (NSString *s in array1) {
            NSLog(@"career:%@",s);
        }
        for (NSString *s in array2) {
            NSLog(@"index:%@",s);
        }
        */
         NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[self.manager.occpuationChoices count]];
        for (int i =0; i<[self.manager.occpuationChoices count]; i++) {
            [tempArray addObject:[NSNull null]];
        }
        for (int i =0; i<[self.manager.occpuationChoices count]; i++) {
            NSDictionary *dict = [[self.manager.occpuationChoices objectForKey:[NSString stringWithFormat:@"0%d",i]] copy];
            [tempArray replaceObjectAtIndex:i withObject:dict];
            
        }
        
        currentOccupationIndex = 0;
        self.occupationArray = tempArray;
//        self.indexArrayOccupation = array2;
        for (int i = 0 ;i<[self.occupationArray count];i++) {
            NSString *str = [self.occupationArray objectAtIndex:i];
            NSLog(@"%d:%@",i,str);
        }
        self.occupationLabel.text = [tempArray objectAtIndex:currentOccupationIndex];
    }
    
    if(self.manager.userJob.length)
    {
        int jobIndex = [self.indexArrayOccupation indexOfObject:self.manager.userJob];
        
        if(jobIndex >= 0 && jobIndex < self.occupationArray.count)
        {
            currentOccupationIndex = jobIndex;
            [self.occupationPickerView selectRow:currentOccupationIndex inComponent:0 animated:NO];
            self.occupationLabel.text = [self.occupationArray objectAtIndex:currentOccupationIndex];
        }
    }
    
    self.cardArray = [NSArray arrayWithObjects:
                      @"中國信託",
                      @"國泰世華",
                      @"富邦",
                      @"台新",
                      @"花旗",
                      @"其它發卡行",
                      @"不使用信用卡", nil];
    
    self.indexArrayCard = [NSArray arrayWithObjects:
                           @"20",
                           @"21",
                           @"22",
                           @"23",
                           @"24",
                           @"25",
                           @"26",nil];
    
    currentCardIndex = self.cardArray.count - 1;
    
    if(self.manager.creditCardChoices)
    {
        __block NSMutableArray *array1 = [NSMutableArray array];
        __block NSMutableArray *array2 = [NSMutableArray array];
        [self.manager.creditCardChoices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [array1 addObject:obj];
            [array2 addObject:key];
        }];
        
        currentCardIndex = 0;
        self.cardArray = array1;
        self.indexArrayCard = array2;
        self.cardLabel.text = [array1 objectAtIndex:currentCardIndex];
    }
    
    if(self.manager.userCard.length)
    {
        int cardIndex = [self.indexArrayCard indexOfObject:self.manager.userCard];
        if(cardIndex >= 0 && cardIndex < self.cardArray.count)
        {
            currentCardIndex = cardIndex;
            [self.cardPickerView selectRow:currentCardIndex inComponent:0 animated:NO];
            self.cardLabel.text = [self.cardArray objectAtIndex:currentCardIndex];
        }
    }
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"Edit Account Screen";
    
    //modified by kiki Huang 2013.12.13
    //----------------------TWMTA Ad-------------------------
    TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                                  slotId:@"Dg1386570971882Nso"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.myScrollView addSubview:_upperAdView];
    [_upperAdView release];
    //-------------------------------------------------------
}

- (void)viewDidUnload
{
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
    self.occupationPickerView.dataSource = nil;
    self.occupationPickerView.delegate = nil;
    [self setOccupationPickerView:nil];
    [self setBirthdayPickerView:nil];
    [self setBirthdayInputToolBar:nil];
    [self setCardLabel:nil];
    [self setCardButton:nil];
    cardPickerView.dataSource = nil;
    cardPickerView.delegate = nil;
    [self setCardPickerView:nil];
    [self setMyView:nil];
//    [self setAdBannerView:nil];
    [self setAccountIdTextField:nil];
    [self setAgainPwdTextField:nil];
    
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
    [SVProgressHUD showWithStatus:@"更新中..."];
    
    NSString *uID = self.manager.userID;
    NSString *pwd = self.accountPwdTextField.text;
    NSString *pwdAgain = self.againPwdTextField.text;
    NSString *name = self.userNameTextField.text;
    NSString *first = @"";
    if(name.length)
        first = [name substringToIndex:1];
    NSString *title = isMale == YES? @"先生" : @"小姐";
    title = [NSString stringWithFormat:@"%@%@", first, title];
    NSString *birthday = [NSString stringWithFormat:@"%d%.2d%.2d", currentBirthDayYear, currentBirthDayMonth, currentBirthDayDay];
    NSString *email = self.emailTextField.text;
    NSString *ages = @"29";
    //modified by kiki Huang 2014.02.06
    NSString *career = [self.indexArrayOccupation objectAtIndex:currentOccupationIndex];
    NSLog(@"%d:%@",currentOccupationIndex,career);
    NSString *card = [self.indexArrayCard objectAtIndex:currentCardIndex];
    
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
    
    [self.manager updateAccountWithID:uID
                                  pwd:pwd
                                 name:name
                                title:title
                             birthday:birthday
                                email:email
                               career:career
                                 ages:ages
                                 card:card
                               isMale:isMale
                              success:^(int code) {
        [SVProgressHUD showSuccessWithStatus:@"更新成功"];
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
        return self.cardArray.count;
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
    if (textField == accountPwdTextField || textField==againPwdTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 11) ? NO : YES;
    }
    return YES;
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
@end
