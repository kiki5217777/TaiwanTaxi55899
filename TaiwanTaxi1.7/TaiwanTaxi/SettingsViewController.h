//
//  SettingsViewController.h
//  TaiwanTaxi
//
//  Created by jason on 9/15/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UIView *buttonsView;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIButton *editAccountBtn;
@property (retain, nonatomic) IBOutlet UIButton *otherSettingsBtn;

- (IBAction)btnPressed:(id)sender;

@end
