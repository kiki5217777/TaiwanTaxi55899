//
//  NewsMessageViewController.m
//  TaiwanTaxi
//
//  Created by jason on 2/7/13.
//
//

#import "NewsMessageViewController.h"

@interface NewsMessageViewController() <UIWebViewDelegate>
@property (nonatomic, retain) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, retain) UIWebView *mainWebView;

- (void)updateToolbarItems;
- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
@end

@implementation NewsMessageViewController

#pragma mark - memory management

- (void)dealloc
{
//    _adBannerView.delegate = nil;
//    [_adBannerView release];  _adBannerView = nil;
    _mainWebView.delegate = nil;
    [_mainWebView release];
    [_backBarButtonItem release];
    [_forwardBarButtonItem release];
    [_refreshBarButtonItem release];
    [_stopBarButtonItem release];
    [_actionBarButtonItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setters and getters

@synthesize backBarButtonItem = _backBarButtonItem;
@synthesize forwardBarButtonItem = _forwardBarButtonItem;
@synthesize refreshBarButtonItem = _refreshBarButtonItem;
@synthesize stopBarButtonItem = _stopBarButtonItem;

- (UIBarButtonItem *)backBarButtonItem {
    
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
        _backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		_backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    
    if (!_forwardBarButtonItem) {
        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
        _forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		_forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    
    if (!_stopBarButtonItem) {
        _stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return _stopBarButtonItem;
}

#pragma mark - init and setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage* anImage = [UIImage imageNamed:@"訊息快遞.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"訊息快遞" image:anImage tag:0];
        self.tabBarItem = theItem;
        [theItem release];
    }
    return self;
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIButton* leftButton = [self.navigationController setUpCustomizeButtonWithText:@"回首頁"
                                                                              icon:nil
                                                                     iconPlacement:CustomizeButtonIconPlacementLeft
                                                                            target:self
                                                                            action:@selector(showHomePage)];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftButton] autorelease];
    
    // -------------------- view --------------------

    self.trackedViewName = @"News Screen";
    
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
    
    // -------------------- web view controller --------------------
    
    _mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 86, 320, 281)];
    _mainWebView.delegate = self;
    _mainWebView.scalesPageToFit = YES;
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.manager.mini_site_url]]];
    
    if([self isRetina4inch])
    {
        CGRect frame = _mainWebView.frame;
        frame.size.height += 88;
        _mainWebView.frame = frame;
    }
    
    [self.view addSubview:_mainWebView];
    
    [self updateToolbarItems];
}

- (void)viewDidUnload
{
//    self.adBannerView.delegate = nil;
//    [self setAdBannerView:nil];
    self.mainWebView = nil;
    self.backBarButtonItem = nil;
    self.forwardBarButtonItem = nil;
    self.refreshBarButtonItem = nil;
    self.stopBarButtonItem = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

#pragma mark - Toolbar

- (void)updateToolbarItems
{
    self.backBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.forwardBarButtonItem.enabled = self.mainWebView.canGoForward;
    self.actionBarButtonItem.enabled = !self.mainWebView.isLoading;
    
    UIBarButtonItem *refreshStopBarButtonItem = self.mainWebView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil] autorelease];
    fixedSpace.width = 5.0f;
    
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil] autorelease];
    
    NSArray *items = [NSArray arrayWithObjects:
                      flexibleSpace,
                      self.backBarButtonItem,
                      flexibleSpace,
                      self.forwardBarButtonItem,
                      flexibleSpace,
                      refreshStopBarButtonItem,
                      flexibleSpace,
                      nil];
    
    self.toolbarItems = items;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [self.mainWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [self.mainWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [self.mainWebView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [self.mainWebView stopLoading];
	[self updateToolbarItems];
}

- (void)doneButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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
#pragma mark - user interaction

-(void)showHomePage
{
    [self.view endEditing:YES];
    [self.notifCenter postNotificationName:SHOW_HOME_PAGE_NOTIFICATION
                                    object:nil];
}
@end
