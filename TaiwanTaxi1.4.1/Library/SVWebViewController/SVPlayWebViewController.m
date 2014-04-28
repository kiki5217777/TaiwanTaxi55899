//
//  SVPlayWebViewController.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 14/1/16.
//
//

#import "SVPlayWebViewController.h"
#import <MessageUI/MessageUI.h>
@interface SVPlayWebViewController () <MFMailComposeViewControllerDelegate,UIWebViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong, readonly) UIActionSheet *pageActionSheet;

@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSDictionary *DICT;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;
@end

@implementation SVPlayWebViewController{
    BOOL playEnable;
    NSURL * _nowURL;
}
@synthesize availableActions;

@synthesize URL, mainWebView;
@synthesize backBarButtonItem, forwardBarButtonItem, refreshBarButtonItem, stopBarButtonItem, actionBarButtonItem, pageActionSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - setters and getters

- (UIBarButtonItem *)backBarButtonItem {
    
    if (!backBarButtonItem) {
        backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
        backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		backBarButtonItem.width = 18.0f;
    }
    return backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    
    if (!forwardBarButtonItem) {
        forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
        forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		forwardBarButtonItem.width = 18.0f;
    }
    return forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    
    if (!refreshBarButtonItem) {
        refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    
    return refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    
    if (!stopBarButtonItem) {
        stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    
    if (!actionBarButtonItem) {
        actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return actionBarButtonItem;
}

- (UIActionSheet *)pageActionSheet {
    
    if(!pageActionSheet) {
        pageActionSheet = [[UIActionSheet alloc]
                           initWithTitle:self.mainWebView.request.URL.absoluteString
                           delegate:self
                           cancelButtonTitle:nil
                           destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsCopyLink) == SVWebViewControllerAvailableActionsCopyLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Copy Link", @"")];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsOpenInSafari) == SVWebViewControllerAvailableActionsOpenInSafari)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
        
        if([MFMailComposeViewController canSendMail] && (self.availableActions & SVWebViewControllerAvailableActionsMailLink) == SVWebViewControllerAvailableActionsMailLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Mail Link to this Page", @"")];
        
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        pageActionSheet.cancelButtonIndex = [self.pageActionSheet numberOfButtons]-1;
    }
    
    return pageActionSheet;
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    
    if(self = [super init]) {
        self.URL = pageURL;
        self.DICT = nil;
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
        self.showPageTitle = NO;
    }
    
    return self;
}

//edited by kiki Huang 2013.12.09
- (id)initWithPOST:(NSDictionary*)dict {
    
    if(self = [super init]) {
        self.URL = [NSURL URLWithString:[[dict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        self.DICT = dict;
        //        NSLog(@"real DICT post%@", self.DICT);
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
        self.showPageTitle = NO;
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void)loadView {
    mainWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    
    //edited by kiki Huang 2013.12.09
    if (self.DICT != nil) {
        
        NSString *parameter;
        
        if ([[self.DICT objectForKey:@"API_type"] isEqualToString:@"taxiPlay"]) {
            parameter = [NSString stringWithFormat: @"userName=%@&device=%@&accessToken=%@",
                    [self.DICT objectForKey:@"user"],
                    [self.DICT objectForKey:@"device"],
                    [self.DICT objectForKey:@"access"]];
            NSLog(@"self DICT request%@",parameter);
        }
       
        //        if ([[self.DICT objectForKey:@"API_type"] isEqualToString:@"taxiTicket"]) {
        //            body = [NSString stringWithFormat: @"CUSTACCT=%@",
        //                    [self.DICT objectForKey:@"token"]];
        //        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.URL];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: [parameter dataUsingEncoding: NSUTF8StringEncoding]];
        [mainWebView loadRequest: request];
    }
    
    else
        [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    
    self.view = mainWebView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self updateToolbarItems];
    
    playEnable = false;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    mainWebView = nil;
    backBarButtonItem = nil;
    forwardBarButtonItem = nil;
    refreshBarButtonItem = nil;
    stopBarButtonItem = nil;
    actionBarButtonItem = nil;
    pageActionSheet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.forwardBarButtonItem.enabled = self.mainWebView.canGoForward;
    self.actionBarButtonItem.enabled = !self.mainWebView.isLoading;
    
    UIBarButtonItem *refreshStopBarButtonItem = self.mainWebView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *items;
        CGFloat toolbarWidth = 250.0f;
        
        if(self.availableActions == 0) {
            toolbarWidth = 200.0f;
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     fixedSpace,
                     nil];
        } else {
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     self.actionBarButtonItem,
                     fixedSpace,
                     nil];
        }
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    }
    
    else {
        NSArray *items;
        
        if(self.availableActions == 0) {
            items = [NSArray arrayWithObjects:
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     nil];
        } else {
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.actionBarButtonItem,
                     fixedSpace,
                     nil];
        }
        
        self.toolbarItems = items;
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    /*
    NSLog(@"request.URL. ----->>%@",request.URL);
    NSLog(@"navigationType = %i",navigationType);
    
    NSURL *url = request.URL;
    
    if([[url absoluteString] rangeOfString:@"e55688.com/web55688/login.do"].length == 0 &&
       [[url absoluteString] rangeOfString:@"e55688.com/web55688/register.do"].length == 0 &&
       [[url absoluteString] rangeOfString:@"e55688.com/web55688/missionList.do"].length == 0 &&
       [[url absoluteString] rangeOfString:@"e55688.com/web55688/validateRegister.do"].length == 0){ // 不是 AAA 的 網站
        _nowURL = url;
        return YES;
    }
    else{
        NSString * oldUrlStr= [url absoluteString];
        if([oldUrlStr rangeOfString:@"userName"].length != 0) {
            NSLog(@"已有參數");
            
            return YES;
        }
        else{
            NSString * newUrlStr;
            //&accessToken=%@  [self.DICT objectForKey:@"access"]
            NSString *parameter = [NSString stringWithFormat: @"userName=%@&device=%@",
                                   [self.DICT objectForKey:@"user"],
                                   [self.DICT objectForKey:@"device"]
                                   ];
            NSLog(@"self DICT request%@",parameter);
            if([oldUrlStr rangeOfString:@"?"].length != 0 ){
                newUrlStr = [NSString stringWithFormat:@"%@&%@",oldUrlStr,parameter];
            }
            else{
                newUrlStr = [NSString stringWithFormat:@"%@?%@",oldUrlStr,parameter];
            }
            NSLog(@"newUrlStr. ----->>%@",newUrlStr);
            [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newUrlStr]]];
            return NO;
        }
    }*/
    
    NSURL *url = request.URL;
    NSLog(@"requestURL : %@",[url absoluteString]);
    
    if ([[url absoluteString] rangeOfString:@"startTask.do"].length != 0 ) {
        NSString *newUrl = [[url absoluteString] copy];
        NSString *checkUrlStr;
        BOOL webViewNeedReload = NO;
        
        //check device
        checkUrlStr = [self matchDeviceInUrl:newUrl];
        if (checkUrlStr != nil) {
            newUrl = checkUrlStr;
            webViewNeedReload = YES;
        }
        
        
        //check user
        checkUrlStr = [self matchUserNameInUrl:newUrl withUserName:[self.DICT objectForKey:@"user"]];
        if (checkUrlStr != nil) {
            newUrl = checkUrlStr;
            webViewNeedReload = YES;
        }
        
        
        
        NSLog(@"newUrl : %@", newUrl);
        if (webViewNeedReload) {
            [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]]];
            return NO;
        }
        
        else
            return YES;
    }
    else
        return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if(self.showPageTitle)
        self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [mainWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [mainWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [mainWebView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [mainWebView stopLoading];
	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    
    if(pageActionSheet)
        return;
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.pageActionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
    else
        [self.pageActionSheet showFromToolbar:self.navigationController.toolbar];
    
}

- (void)doneButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:NSLocalizedString(@"Open in Safari", @"")])
        [[UIApplication sharedApplication] openURL:self.mainWebView.request.URL];
    
    if([title isEqualToString:NSLocalizedString(@"Copy Link", @"")]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.mainWebView.request.URL.absoluteString;
    }
    
    else if([title isEqualToString:NSLocalizedString(@"Mail Link to this Page", @"")]) {
        
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
  		[mailViewController setMessageBody:self.mainWebView.request.URL.absoluteString isHTML:NO];
		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
		[self presentModalViewController:mailViewController animated:YES];
	}
    
    pageActionSheet = nil;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Check parameter web URL
//edited by kiki Huang 2014.01.20
-(NSString*) matchDeviceInUrl:(NSString*)orgUrlstr {
    NSString *pattern = @"device=(.*)&";//in url midden
    NSString *pattern1 = @"device=(.*)";//in url end
    NSString *result;
    NSString * newUrlStr = orgUrlstr;
    
    //check "device=(.*)&" condiction
    if ((result = [self fineKeyPointInString:orgUrlstr withPattern:pattern])) {
        NSLog(@"device1 : %@", result);
        
        if (result.length == 0)
            newUrlStr = [orgUrlstr stringByReplacingOccurrencesOfString:@"device=" withString:@"device=ios"];
        
        else
            return nil;
    }
    //check "device=(.*)" condition
    else if ((result = [self fineKeyPointInString:orgUrlstr withPattern:pattern1])) {
        NSLog(@"device2 : %@", result);
        
        if (result.length == 0)
            newUrlStr = [orgUrlstr stringByReplacingOccurrencesOfString:@"device=" withString:@"device=ios"];
        
        else
            return nil;
    }
    //check has "device=ios"
    else {
        NSLog(@"device3 : %@", result);
        newUrlStr = [orgUrlstr stringByAppendingString:@"&device=ios"];
    }
    
    return newUrlStr;
}

-(NSString*) matchUserNameInUrl:(NSString*)orgUrlstr withUserName:(NSString*)user{
    NSString *pattern = @"userName=(.*)&";
    NSString *pattern1 = @"userName=(.*)";
    NSString *result;
    NSString * newUrlStr = orgUrlstr;
    
    if ((result = [self fineKeyPointInString:orgUrlstr withPattern:pattern])) {
        NSLog(@"user1 : %@", result);
        
        if (result.length == 0)
            newUrlStr = [orgUrlstr stringByReplacingOccurrencesOfString:@"userName=" withString:user];
        
        else
            return nil;
        
    }
    
    else if ((result = [self fineKeyPointInString:orgUrlstr withPattern:pattern1])) {
        NSLog(@"user2 : %@", result);
        
        if (result.length == 0)
            newUrlStr = [orgUrlstr stringByReplacingOccurrencesOfString:@"userName=" withString:user];
        
        else
            return nil;
        
    }
    
    else {
        NSLog(@"user3 : %@", result);
        newUrlStr = [NSString stringWithFormat:@"%@&userName=%@", orgUrlstr, user];
    }
    
    return newUrlStr;
}

-(NSString*)fineKeyPointInString:(NSString*)content withPattern:(NSString*)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:content
                                      options:0 range:NSMakeRange(0, content.length)];

    if ([matches count]) {
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSLog(@"-> %@", [content substringWithRange:[match rangeAtIndex:match.numberOfRanges-1]]);
        
        return [content substringWithRange:[match rangeAtIndex:match.numberOfRanges-1]];
    }
    
    return nil;
}

@end
