//
//  AFTaiwanTaxiAPIClient.h
//  TaiwanTaxi
//
//  Created by jason on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface AFTaiwanTaxiAPIClient : AFHTTPClient
{
    
}

+ (AFTaiwanTaxiAPIClient *)sharedClient:(NSString *)baseURL;

@end
