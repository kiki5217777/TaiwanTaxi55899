//
//  ServiceManager.h
//  TaiwanTaxi
//
//  Created by jason on 8/23/12.
//
//

#import <Foundation/Foundation.h>

@interface ServiceManager : NSObject
{
    
}

- (void)startManageAdService;
- (void)stopManageAdService;

- (void)updateAdInfo;

+ (ServiceManager *)sharedInstance;

@end
