//
//  OtherSettingsViewController.h
//  TaiwanTaxi
//
//  Created by jason on 9/15/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.13
#import "TWMTAMediaView.h"

@interface OtherSettingsViewController : BaseViewController <UITextFieldDelegate, CustomAdBannerViewDelegate, TWMTAMediaViewDelegate>
{
    BOOL useMVNP;
}

@property (retain, nonatomic) IBOutlet UIView *contentView;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

@property (retain, nonatomic) IBOutlet UITextField *mvpnTextField;
@property (retain, nonatomic) IBOutlet UISwitch *useMVPNSwitch;
- (IBAction)switchChanged:(id)sender;
- (IBAction)textFieldChanged:(id)sender;

@end
