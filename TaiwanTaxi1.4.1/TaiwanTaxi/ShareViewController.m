//
//  ShareViewController.m
//  TaiwanTaxi
//
//  Created by jason on 8/14/12.
//
//

#import "ShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>

NSString *const kPlaceholderPostMessage = @"輸入您的訊息...";

@implementation ShareViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize postMessageTextView;
@synthesize postImageView;
@synthesize postNameLabel;
@synthesize postCaptionLabel;
@synthesize postDescriptionLabel;
@synthesize postParams = _postParams;
@synthesize imageData = _imageData;
@synthesize imageConnection = _imageConnection;
@synthesize shareButton;

#pragma mark - dealloc

- (void)dealloc
{
    [postMessageTextView release];
    [postImageView release];
    [postNameLabel release];
    [postCaptionLabel release];
    [postDescriptionLabel release];
    [_postParams release];
    [_imageData release];
    [_imageConnection release];
    
    [shareButton release];
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
    
    // -------------------- notifications --------------------
    
    [self.notifCenter addObserver:self
                         selector:@selector(sessionStateChanged:)
                             name:FBSessionStateChangedNotification
                           object:nil];
    
    // -------------------- post params --------------------
    
    // Getting post info from user default
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *title = [df stringForKey:USER_DEFAULT_KEY_FB_TITLE];
    NSString *caption = @"";
    if(self.manager.currentAppMode == AppModeTWTaxi)
        caption= @"台灣大車隊 iOS App";
    else
        caption= @"城市衛星 iOS App";
    NSString *desc = [df stringForKey:USER_DEFAULT_KEY_FB_DESCRIPTION];
    NSString *link = [df stringForKey:USER_DEFAULT_KEY_FB_LINK];
    NSString *image = [NSString stringWithFormat:@"%@%@", self.manager.json_base_url, [df stringForKey:USER_DEFAULT_KEY_FB_IMAGE]];
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if(title)[params setObject:title        forKey:@"name"];
    if(caption)[params setObject:caption    forKey:@"caption"];
    if(desc)[params setObject:desc          forKey:@"description"];
    if(link)[params setObject:link          forKey:@"link"];
    if(image)[params setObject:image        forKey:@"picture"];
    
    self.postParams = params;
    
    // -------------------- view related --------------------
    
    // Show placeholder text
    [self resetPostMessage];
    
    // Set up the post information, hard-coded for this sample
    self.postNameLabel.text = [self.postParams objectForKey:@"name"];
    self.postCaptionLabel.text = [self.postParams objectForKey:@"caption"];
    [self.postCaptionLabel sizeToFit];
    
    self.postDescriptionLabel.text = [self.postParams objectForKey:@"description"];
    [self.postDescriptionLabel sizeToFit];
    
    self.trackedViewName = @"FB Share Screen";
    
    // -------------------- image --------------------
    
    // Kick off loading of image data asynchronously so as not to block the UI.
    self.imageData = [NSMutableData data];
    NSURL *url = [NSURL URLWithString:[self.postParams objectForKey:@"picture"]];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
    self.imageConnection = [[[NSURLConnection alloc] initWithRequest:imageRequest delegate:self] autorelease];
}

- (void)viewDidUnload
{
    [self setPostMessageTextView:nil];
    [self setPostImageView:nil];
    [self setPostNameLabel:nil];
    [self setPostCaptionLabel:nil];
    [self setPostDescriptionLabel:nil];
    
    if (self.imageConnection) {
        [self.imageConnection cancel];
        self.imageConnection = nil;
    }
    
    [self setShareButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)cancelButtonAction:(id)sender
{
    [[self presentingViewController]
     dismissModalViewControllerAnimated:YES];
}

- (IBAction)shareButtonAction:(id)sender
{
    [SVProgressHUD showWithStatus:@"分享中..."];
    // Hide keyboard if showing when button clicked
    if ([self.postMessageTextView isFirstResponder])
    {
        [self.postMessageTextView resignFirstResponder];
    }
    
    // Add user message parameter if user filled it in
    if (![self.postMessageTextView.text
          isEqualToString:kPlaceholderPostMessage] &&
        ![self.postMessageTextView.text isEqualToString:@""])
    {
        [self.postParams setObject:self.postMessageTextView.text
                            forKey:@"message"];
    }
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:self.postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              [SVProgressHUD dismiss];
                              NSString *alertText;
                              
                              if (error)
                              {
                                  alertText = @"分享失敗";
                                  DDLogError(@"error: domain = %@, code = %d", error.domain, error.code);
                              }
                              else
                              {
                                  alertText = @"分享成功";
                                  DDLogInfo(@"Posted action, id: %@", [result objectForKey:@"id"]);
                              }
                              
                              // Show the result in an alert
                              UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"結果"
                                                                                   message:alertText
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"OK!"
                                                                         otherButtonTitles:nil] autorelease];
                              [alertView show];
                          }];
    

}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:kPlaceholderPostMessage])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
    if ([textView.text isEqualToString:@""])
    {
        [self resetPostMessage];
    }
}

#pragma mark - NSURLConnection related

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Load the image
    self.postImageView.image = [UIImage imageWithData:[NSData dataWithData:self.imageData]];
    self.imageConnection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.imageConnection = nil;
    self.imageData = nil;
}

#pragma mark - helper methods

- (void)resetPostMessage
{
    self.postMessageTextView.text = kPlaceholderPostMessage;
    self.postMessageTextView.textColor = [UIColor lightGrayColor];
}

/*
 * A simple way to dismiss the message text view:
 * whenever the user clicks outside the view.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.postMessageTextView isFirstResponder] &&
        (self.postMessageTextView != touch.view))
    {
        [self.postMessageTextView resignFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen)
    {
        self.shareButton.enabled = YES;
    }
    else
    {
        self.shareButton.enabled = NO;
    }
}

@end
