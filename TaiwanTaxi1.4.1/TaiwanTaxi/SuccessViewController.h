//
//  SuccessViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "VponAdBannerView.h"

//edited by kiki Huang 2013.12.13
#import "TWMTAMediaView.h"

@interface SuccessViewController : BaseViewController <UIAlertViewDelegate,TWMTAMediaViewDelegate>

@property (retain, nonatomic) NSString *carNumber;
@property (retain, nonatomic) NSString *eta;

//@property (retain, nonatomic) IBOutlet VponAdBannerView *adBannerView;
@property (retain, nonatomic) IBOutlet UILabel *carNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *etaLabel;
@property (retain, nonatomic) IBOutlet UIButton *reliefButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *bonusChangeBtn;

- (IBAction)reliefButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)bonusBtnPressed:(id)sender;

@end
