//
//  VponAdBannerView.m
//  TaiwanTaxi
//
//  Created by jason on 9/18/13.
//
//

#import "VponAdBannerView.h"

#import "VponBanner.h"
#import "AppDelegate.h"

@interface VponAdBannerView() <VponBannerDelegate>
@property (nonatomic, retain) VponBanner* vponAd; // 宣告使用VponBanner廣告
@end

@implementation VponAdBannerView

#pragma mark - memeory management

- (void)dealloc
{
    _vponAd.delegate = nil;
    [_vponAd release]; _vponAd = nil;
    
    [super dealloc];
}

#pragma mark - init and setup

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // -------------------- view --------------------
    
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - ad related

- (void)startShowAd:(UIViewController *)rootViewController
{
    if(self.vponAd == nil)
    {
        // 設定廣告位置 320x50
        CGPoint origin = CGPointZero;
        
        // 初始化Banner物件
        VponBanner *v = [[[VponBanner alloc] initWithAdSize:VponAdSizeBanner origin:origin] autorelease];
        v.strBannerId = @"8a8081823f9e259a013fa2fbf2bc035c";   // 填入您的BannerId
        v.delegate = self;       // 設定delegate接收protocol回傳訊息
        v.platform = TW;       // 台灣地區請填TW 大陸則填CN
        [v setAdAutoRefresh:YES]; //如果為mediation則set NO
        
        if(!rootViewController)
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            rootViewController = appDelegate.window.rootViewController;
        }
        
        [v setRootViewController:rootViewController];
        
        self.vponAd = v;
        
        // 將VponBanner的View加入此 view 中
        [self addSubview:[self.vponAd getVponAdView]];
        
        // Start showing ads
        [self.vponAd startGetAd:[self getTestIdentifiers]];
    }
}

- (void)startShowLargeAd:(UIViewController *)rootViewController
{
    if(self.vponAd == nil)
    {
        // 設定廣告位置 300x250
        CGPoint origin = CGPointZero;
        
        // 初始化Banner物件
        VponBanner *v = [[[VponBanner alloc] initWithAdSize:VponAdSizeMediumRectangle origin:origin] autorelease];
        v.strBannerId = @"8a8081823f9e259a013fa2fc390e035e";   // 填入您的BannerId
        v.delegate = self;       // 設定delegate接收protocol回傳訊息
        v.platform = TW;       // 台灣地區請填TW 大陸則填CN
        [v setAdAutoRefresh:YES]; //如果為mediation則set NO
        
        if(!rootViewController)
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            rootViewController = appDelegate.window.rootViewController;
        }
        
        [v setRootViewController:rootViewController];
        
        self.vponAd = v;
        
        // 將VponBanner的View加入此 view 中
        [self addSubview:[self.vponAd getVponAdView]];
        
        // Start showing ads
        [self.vponAd startGetAd:[self getTestIdentifiers]];
    }
}

// 請新增此function到您的程式內 如果為測試用 則在下方填入UUID，即可看到測試廣告。
- (NSArray*)getTestIdentifiers
{
    return [NSArray arrayWithObjects:
            @"b69fb2f660866caee30e63b621f9f90d", // jason
            @"c7c128e16574efae3416f4ddbdcdbf9e", // kevin
            @"dbb451d995769e9900583c5e961bbf6f", // Boky
            @"a844e10a182bc1f91e65973cffb79d634fc61ab4", // ???
            nil];
}

#pragma mark - VponBannerDelegate

- (void)onVponAdReceived:(UIView *)bannerView{
    NSLog(@"廣告抓取成功");
}

- (void)onVponAdFailed:(UIView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"廣告抓取失敗");
}

- (void)onVponPresent:(UIView *)bannerView{
    NSLog(@"開啟vpon廣告頁面 %@",bannerView);
}

- (void)onVponDismiss:(UIView *)bannerView{
    NSLog(@"關閉vpon廣告頁面 %@",bannerView);
}

- (void)onVponLeaveApplication:(UIView *)bannerView{
    NSLog(@"離開publisher application");
}

@end
