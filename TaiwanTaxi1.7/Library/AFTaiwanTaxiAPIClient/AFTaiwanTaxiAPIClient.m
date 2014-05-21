//
//  AFTaiwanTaxiAPIClient.m
//  TaiwanTaxi
//
//  Created by jason on 8/10/12.
//
//

#import "AFTaiwanTaxiAPIClient.h"
#import "AFKissXMLRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "Constants.h"

@implementation AFTaiwanTaxiAPIClient

#pragma mark - define 

+ (AFTaiwanTaxiAPIClient *)sharedClient:(NSString *)baseURL
{
    if(baseURL.length == 0)
        baseURL = @"http://www.taiwantaxi.com.tw";
    static AFTaiwanTaxiAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFTaiwanTaxiAPIClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
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
    
    return self;
}

@end
