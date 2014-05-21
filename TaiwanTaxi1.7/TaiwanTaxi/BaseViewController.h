//
//  BaseViewController.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/26/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaxiManager.h"
#import "OrderManager.h"
#import "SVProgressHUD.h"
#import "DDLog.h"
#import "Constants.h"
#import "GAITrackedViewController.h"


@interface BaseViewController : GAITrackedViewController
{
    int viewWidth;
    int viewHeight;
}

@property (nonatomic, assign) TaxiManager *manager;
@property (nonatomic, assign) OrderManager *orderManager;
@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, assign) NSNotificationCenter *notifCenter;
@property (nonatomic, assign) NSUserDefaults *userDefault;


// notif
- (void)handleSignInSuccessful:(NSNotification *)notif;

// helpers
- (void)executeBlock:(void (^)())block
           withDelay:(NSTimeInterval)delayInSeconds;

- (void)passCheckpoint:(NSString *)checkPointName;

- (BOOL)isRetina4inch;
- (BOOL)isRunningiOS6;
- (BOOL)isRunningiOS7;

- (void)handleClickAd:(id)urlObj;

@end

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}
