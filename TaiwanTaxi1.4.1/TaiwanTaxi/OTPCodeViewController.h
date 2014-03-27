//
//  OTPCodeViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface OTPCodeViewController : BaseViewController
{
    
}

@property (retain, nonatomic) IBOutlet UITextField *codeTextField;
- (IBAction)activateButtonPressed:(id)sender;
- (IBAction)resendButtonPressed:(id)sender;

@end
