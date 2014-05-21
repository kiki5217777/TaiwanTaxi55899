//
//  TWMTWMTAMediaView.h
//  TWMTAMediaView
//
//  Created by William Lin on 13/4/22.
//  Copyright (c) 2013年 TaiwanMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TWMTAMediaViewDelegate;

@interface TWMTAMediaView : UIView
{
    id <TWMTAMediaViewDelegate> delegate;
}

@property (nonatomic, retain) NSString *slotId;

// The banner view delegate is notified when advertisements are loaded, when errors occur in
// getting ads, and when banner actions begin and end.
// Applications built against the iOS 5.0 or later SDK and when running on iOS 5.0 or later
// may treat the delegate as if it was 'weak' instead of 'assign' (aka _unsafe_unretained).
@property (nonatomic, assign) id <TWMTAMediaViewDelegate> delegate;

// YES if an advertisement is loaded, NO otherwise.
@property (nonatomic, readonly, getter=isBannerLoaded) BOOL bannerLoaded;

- (id)initWithFrame:(CGRect)frame slotId:(NSString *)slotId;

- (id)initWithFrame:(CGRect)frame slotId:(NSString *)slotId developerID:(NSString *)developerID gpsEnabled:(BOOL)gpsEnabled testMode:(BOOL)testMode;

- (void)receiveAd;

@end

@protocol TWMTAMediaViewDelegate <NSObject>
@optional

- (void)viewWillLoadAd:(TWMTAMediaView *)view;

- (void)viewDidLoadAd:(TWMTAMediaView *)view;

- (void)view:(TWMTAMediaView *)view didFailToReceiveAdWithError:(NSError *)error;

- (BOOL)viewActionShouldBegin:(TWMTAMediaView *)view willLeaveApplication:(BOOL)willLeave;

@end
