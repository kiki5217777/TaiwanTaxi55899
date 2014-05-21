//
//  AdBannerView.m
//  TaiwanTaxi
//
//  Created by jason on 2/6/13.
//
//

#import "CustomAdBannerView.h"
#import "Constants.h"
#import "TaxiManager.h"

@interface CustomAdBannerView()
@property (nonatomic, retain) UIButton *bannerButton;
@property (nonatomic, retain) NSArray *adInfo;
@property (nonatomic, retain) NSMutableArray *primaryAdArray;
@property (nonatomic, retain) NSMutableArray *secondaryAdArray;
@property (nonatomic, assign) TaxiManager *manager;
@property (nonatomic, retain) NSString *currentURL;
@property (nonatomic, retain) NSTimer *myTimer;
@end

@implementation CustomAdBannerView

#pragma mark - memeory management

- (void)dealloc
{
    [_myTimer invalidate]; _myTimer = nil;
    _delegate = nil;
    [_bannerButton release];
    [_primaryAdArray release];
    [_secondaryAdArray release];
    [_adInfo release];
    [_currentURL release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    currentIndex = 0;
    
    UIImage *defaultImage = [UIImage imageNamed:@"banner"];
    
    self.bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bannerButton.frame = self.bounds;
    self.bannerButton.backgroundColor = [UIColor orangeColor];
    [self addSubview:self.bannerButton];
    
    [self.bannerButton setImage:defaultImage forState:UIControlStateNormal];
    [self.bannerButton addTarget:self
                          action:@selector(bannerButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedAdInfo:)
                                                 name:REFRESH_AD_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    self.primaryAdArray = [NSMutableArray array];
    self.secondaryAdArray = [NSMutableArray array];
    self.manager = [TaxiManager sharedInstance];
    
    if(self.manager.adsDict)
    {
        [self loadAdInfo:self.manager.adsDict];
        [self changeAd:nil];
    }
    
    [self configTimer];
}

- (void)configTimer
{
    self.myTimer = [NSTimer timerWithTimeInterval:10.0f
                                           target:self
                                         selector:@selector(changeAd:)
                                         userInfo:nil
                                          repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.myTimer forMode: NSDefaultRunLoopMode];
}

#pragma mark - view related

- (void)layoutSubviews
{
    self.bannerButton.frame = self.bounds;
}

#pragma mark - state management

- (void)appBecameActive:(NSNotification *)notif
{
    if(self.myTimer == nil)
    {
        [self configTimer];
    }
}

- (void)appWillResignActive:(NSNotification *)notif
{
    [self.myTimer invalidate];
    self.myTimer = nil;
}

- (void)removeFromSuperview
{
    [self.myTimer invalidate];
    self.myTimer = nil;
    
    [super removeFromSuperview];
}

#pragma mark - ad management related code

- (void)receivedAdInfo:(NSNotification *)notif
{
    [self loadAdInfo:self.manager.adsDict];
}

- (void)loadAdInfo:(NSArray *)info
{
    self.adInfo = info;
    if(self.adInfo.count)
    {
        if(self.primaryAdArray.count == 0)
        {
            self.primaryAdArray = [NSMutableArray arrayWithArray:self.adInfo];
            [self shuffleArray:self.primaryAdArray];
        }
        else
        {
            self.secondaryAdArray = [NSMutableArray arrayWithArray:self.adInfo];
            [self shuffleArray:self.secondaryAdArray];
        }
    }
}

- (void)changeAd:(NSTimer*)theTimer
{
    if(self.primaryAdArray.count && self && self.bannerButton)
    {
        if(currentIndex == self.primaryAdArray.count)
        {
            if(self.secondaryAdArray.count)
            {
                self.primaryAdArray = self.secondaryAdArray;
                self.secondaryAdArray = nil;
            }
            else
            {
                [self shuffleArray:self.primaryAdArray];
            }
        }
        
        currentIndex = currentIndex % self.primaryAdArray.count;
        NSDictionary *currentAd = [self.primaryAdArray objectAtIndex:currentIndex];
        
        [self.manager getAdImage:currentAd success:^(UIImage *newImage) {
            
            [self.bannerButton setImage:newImage forState:UIControlStateNormal];
            self.currentURL = [currentAd objectForKey:ADINFO_API_KEY_link];
            
        }];
        
        currentIndex += 1;
    }
}

- (void)shuffleArray:(NSMutableArray *)array
{
    for (NSInteger i = [array count] - 1; i > 0; --i)
    {
        [array exchangeObjectAtIndex: arc4random() % (i+1) withObjectAtIndex: i];
    }
}

#pragma mark - user interaction

- (void)bannerButtonPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(bannerButtonPressed:)])
    {
        [self.delegate bannerButtonPressed:self.currentURL];
    }
}

@end
