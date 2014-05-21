//
//  AFCityTaxiAPIClient.m
//  TaiwanTaxi
//
//  Created by jason on 9/13/12.
//
//

#import "AFCityTaxiAPIClient.h"
#import "AFKissXMLRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "Constants.h"

@implementation AFCityTaxiAPIClient

#pragma mark - define

+ (AFCityTaxiAPIClient *)sharedClient:(NSString *)baseURL
{
    if(baseURL.length == 0)
        baseURL = @"http://www.taiwantaxi.com.tw";
    static AFCityTaxiAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFCityTaxiAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    return _sharedClient;
}

+ (AFCityTaxiAPIClient *)sharedBaseURLClient:(NSString *)baseURL
{
    if(baseURL.length == 0)
        baseURL =@"http://124.219.2.122";
    static AFCityTaxiAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFCityTaxiAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
//    NSLog(@"cookie %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]);
//    [self setDefaultHeader:@"Cookie" value:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]];
    
    return self;
}

@end
