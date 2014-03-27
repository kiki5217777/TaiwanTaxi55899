//
//  CallMenuViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface CallMenuViewController : BaseViewController <CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *addressBtn;
@property (retain, nonatomic) IBOutlet UIButton *GPSBtn;
@property (retain, nonatomic) IBOutlet UIButton *favorBtn;
@property (retain, nonatomic) IBOutlet UIButton *historyBtn;
@property (retain, nonatomic) IBOutlet UIButton *landmarkBtn;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

- (IBAction)useWrite:(id)sender;
- (IBAction)uesGPS:(id)sender;
- (IBAction)useFavorite:(id)sender;
- (IBAction)useHistory:(id)sender;
- (IBAction)useLandmark:(id)sender;

@end
