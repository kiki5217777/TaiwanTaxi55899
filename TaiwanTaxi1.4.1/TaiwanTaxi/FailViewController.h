//
//  FailViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface FailViewController : BaseViewController <CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *retyButton;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

- (IBAction)retyButtonPressed:(id)sender;

@end
