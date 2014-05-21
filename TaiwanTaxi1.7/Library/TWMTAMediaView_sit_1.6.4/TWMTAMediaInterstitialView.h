//
//  TWMTAMediaInterstitialView.h
//  TWMTAMediaView
//
//  Created by William Lin on 13/7/3.
//  Copyright (c) 2013年 TaiwanMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TWMTAMediaInterstitialViewDelegate;

@interface TWMTAMediaInterstitialView : UIView
{
    id <TWMTAMediaInterstitialViewDelegate> delegate;
}

@property (nonatomic, retain) NSString *slotId;

@property (nonatomic, retain) id <TWMTAMediaInterstitialViewDelegate> delegate;

// YES if an advertisement is loaded, NO otherwise.
@property (nonatomic, readonly, getter=isInterstitialLoaded) BOOL interstitialLoaded;

- (id)initWithSlotId:(NSString *)slotId;

- (id)initWithFrame:(CGRect)frame slotId:(NSString *)slotId;

- (id)initWithFrame:(CGRect)frame slotId:(NSString *)slotId developerID:(NSString *)developerID gpsEnabled:(BOOL)gpsEnabled testMode:(BOOL)testMode;

- (void)receiveAd;

- (void)showAd:(UIView *)rootView;

@end

@protocol TWMTAMediaInterstitialViewDelegate <NSObject>
@optional

- (void)interstitialViewWillLoadAd:(TWMTAMediaInterstitialView *)view;

- (void)interstitialViewDidLoadAd:(TWMTAMediaInterstitialView *)view;

- (void)interstitialView:(TWMTAMediaInterstitialView *)view didFailToReceiveAdWithError:(NSError *)error;

- (BOOL)interstitialViewActionShouldBegin:(TWMTAMediaInterstitialView *)view willLeaveApplication:(BOOL)willLeave;

- (void)interstitialViewWillDisappear:(TWMTAMediaInterstitialView *)view;

- (void)interstitialViewDidDisappear:(TWMTAMediaInterstitialView *)view;

@end
