//
//  AFCityTaxiAPIClient.h
//  TaiwanTaxi
//
//  Created by jason on 9/13/12.
//
//

#import "AFHTTPClient.h"

@interface AFCityTaxiAPIClient : AFHTTPClient
{
    
}

+ (AFCityTaxiAPIClient *)sharedClient:(NSString *)baseURL;

//edited by kiki Huang 2013.12.19
+ (AFCityTaxiAPIClient *)sharedBaseURLClient:(NSString *)baseURL;

@end
