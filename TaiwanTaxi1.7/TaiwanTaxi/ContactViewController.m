//
//  ContactViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContactViewController.h"
#import "AppDelegate.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"


@implementation ContactViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define CONTENT_VIEW_SIZE_3_5_INCH      367
#define CONTENT_VIEW_SIZE_4_INCH        455

#pragma mark - synthesize

@synthesize relievedBtn;
@synthesize myScrollView;
@synthesize nameTextField;
@synthesize telTextField;
@synthesize emailTextField;
@synthesize contextTextView;
@synthesize recordsBtn;

#pragma mark - dealloc

- (void)dealloc
{
    [recordsBtn release];
    [relievedBtn release];
    [myScrollView release];
    [nameTextField release];
    [telTextField release];
    [emailTextField release];
    [contextTextView release];
    [_myView release];
    [_submit release];
    [_contentTextViewBgImageView release];
    [_clear release];
    [_bonusBtn release];
    [_modeButtonsBg release];
    [_contactBtn release];
    [_modeTextImageView release];
    [_mainTitleLabel release];
    [_nameLabel release];
    [_telLabel release];
    [_emailLabel release];
    [_textViewBg release];
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
    
    // -------------------- view related --------------------
    
    if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        self.bonusBtn.hidden = YES;
        
        CGFloat offset = self.bonusBtn.frame.size.height;
        CGRect frame;
        
        // orz...
        frame = self.modeButtonsBg.frame;
        frame.origin.y -= offset;
        self.modeButtonsBg.frame = frame;
        
        frame = self.contactBtn.frame;
        frame.origin.y -= offset;
        self.contactBtn.frame = frame;
        
        frame = self.modeTextImageView.frame;
        frame.origin.y -= offset;
        self.modeTextImageView.frame = frame;
        
        frame = self.mainTitleLabel.frame;
        frame.origin.y -= offset;
        self.mainTitleLabel.frame = frame;
        
        frame = self.nameLabel.frame;
        frame.origin.y -= offset;
        self.nameLabel.frame = frame;
        
        frame = self.telLabel.frame;
        frame.origin.y -= offset;
        self.telLabel.frame = frame;
        
        frame = self.emailLabel.frame;
        frame.origin.y -= offset;
        self.emailLabel.frame = frame;
        
        frame = self.textViewBg.frame;
        frame.origin.y -= offset;
        self.textViewBg.frame = frame;
        
        frame = self.recordsBtn.frame;
        frame.origin.y -= offset;
        self.recordsBtn.frame = frame;
        
        frame = self.relievedBtn.frame;
        frame.origin.y -= offset;
        self.relievedBtn.frame = frame;
        
        frame = self.nameTextField.frame;
        frame.origin.y -= offset;
        self.nameTextField.frame = frame;
        
        frame = self.telTextField.frame;
        frame.origin.y -= offset;
        self.telTextField.frame = frame;
        
        frame = self.emailTextField.frame;
        frame.origin.y -= offset;
        self.emailTextField.frame = frame;
        
        frame = self.contextTextView.frame;
        frame.origin.y -= offset;
        self.contextTextView.frame = frame;
        
        frame = self.clear.frame;
        frame.origin.y -= offset;
        self.clear.frame = frame;
        
        frame = self.submit.frame;
        frame.origin.y -= offset;
        self.submit.frame = frame;
    }
    
    if([self isRetina4inch] == YES)
    {
        viewHeight = CONTENT_VIEW_SIZE_4_INCH;
        
        // make the text view bigger to utilize the iphone 5 4inch screen
        
        // text bg image view
        CGRect frame = self.contentTextViewBgImageView.frame;
        frame.size.height += 88;
        self.contentTextViewBgImageView.frame = frame;
        
        // text view
        frame = self.contextTextView.frame;
        frame.size.height += 88;
        self.contextTextView.frame = frame;
        
        // adust the button position
        
        // clear button
        frame = self.clear.frame;
        frame.origin.y += 88;
        self.clear.frame = frame;
        
        // submit button
        frame = self.submit.frame;
        frame.origin.y += 88;
        self.submit.frame = frame;
    }
    else
        viewHeight = CONTENT_VIEW_SIZE_3_5_INCH;
    
    viewWidth = 320;
    
    self.myScrollView.contentSize = CGSizeMake(viewWidth, viewHeight);
    
    self.nameTextField.text = self.manager.userTitle;
    self.telTextField.text = self.manager.userTel;
    self.emailTextField.text = self.manager.userEmail;
    self.contextTextView.text = @"";
}

- (void)viewDidUnload
{
    [self setRecordsBtn:nil];
    [self setRelievedBtn:nil];
    [self setMyScrollView:nil];
    [self setNameTextField:nil];
    [self setTelTextField:nil];
    [self setEmailTextField:nil];
    [self setContextTextView:nil];
    
    [self setMyView:nil];
    [self setSubmit:nil];
    [self setContentTextViewBgImageView:nil];
    [self setClear:nil];
    [self setBonusBtn:nil];
    [self setModeButtonsBg:nil];
    [self setContactBtn:nil];
    [self setModeTextImageView:nil];
    [self setMainTitleLabel:nil];
    [self setNameLabel:nil];
    [self setTelLabel:nil];
    [self setEmailLabel:nil];
    [self setTextViewBg:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self subscribeForKeyboardEvents];
    
    self.nameTextField.text = self.manager.userTitle;
    self.telTextField.text = self.manager.userTel;
    self.emailTextField.text = self.manager.userEmail;
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

- (IBAction)bonusBannerPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"準備中"];
    [self.manager generateBonusLink:^(NSString *urlLink, NSString *msg, NSError *error) {
        
        button.enabled = YES;
        
        if(urlLink.length)
        {
            SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:urlLink]];
            swc.availableActions = SVWebViewControllerAvailableActionsNone;
            swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
            swc.toolbar.barStyle = UIBarStyleBlackOpaque;
            swc.webViewController.navigationItem.title = @"紅利大積點";
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.window.rootViewController presentViewController:swc
                                                             animated:YES
                                                           completion:^{
                                                               
                                                               int64_t delayInSeconds = 2.0;
                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                   [SVProgressHUD showSuccessWithStatus:msg];
                                                               });
                
                                                               
            }];
            [swc release];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:msg];
        }
        
    }];
}

- (IBAction)routerRecords:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_RIDE_HISTORY_VIEW
                                    object:self];
}

- (IBAction)relievedService:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_TRACKING_VIEW
                                    object:self];
}

- (IBAction)clearButtonPressed:(id)sender
{
    self.contextTextView.text = @"";
}

- (IBAction)submitButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    if(self.contextTextView.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"您尚未輸入任何意見"];
        return;
    }
    
    self.submit.enabled = NO;
    [SVProgressHUD showWithStatus:@"傳送中..."];
    
    [self.manager sendSuggestionWithName:self.nameTextField.text
                                     tel:self.telTextField.text
                                   email:self.emailTextField.text
                                 context:self.contextTextView.text
                                 success:^{
                                     
                                     [SVProgressHUD showSuccessWithStatus:@"傳送成功, 感謝您的意見"];
                                     self.submit.enabled = YES;
                                     self.contextTextView.text = @"";
        
    } failure:^(NSString *errorMessage, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:errorMessage];
        self.submit.enabled = YES;
    }];
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
