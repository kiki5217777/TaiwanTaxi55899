//
//  ServiceManager.m
//  TaiwanTaxi
//
//  Created by jason on 8/23/12.
//
//

#import "ServiceManager.h"
#import "Constants.h"
#import "DDLog.h"
#import "TaxiManager.h"

@implementation ServiceManager

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // register for application start up
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(appBecameActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

#pragma mark - notification handling

- (void)appBecameActive:(NSNotification *)notif
{
    [self updateAdInfo];
}

- (void)updateAdInfo
{
    [[TaxiManager sharedInstance] retrieveAdsInfoSuccess:^(NSArray *info) {
        
        DDLogInfo(@"retrieve Ads info successful");
        
        [TaxiManager sharedInstance].adsDict = info;
        [[TaxiManager sharedInstance] saveAdInfoToDisk];
        
        for(NSDictionary *ad in info)
        {
            [[TaxiManager sharedInstance] getAdImage:ad success:^(UIImage *newImage) {
                
            }];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_AD_NOTIFICATION object:nil];
    } failure:^(NSString *errorMessage, NSError *error) {
        DDLogError(@"retrieve Ads info failed. Reason: %@", errorMessage);
    }];
}

#pragma mark - services

- (void)startManageAdService
{
    
}

- (void)stopManageAdService
{
    
}

#pragma mark - main methods

#pragma mark - internal helper



#pragma mark - singleton implementation code

static ServiceManager *singletonManager = nil;
+ (ServiceManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static ServiceManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}
@end
