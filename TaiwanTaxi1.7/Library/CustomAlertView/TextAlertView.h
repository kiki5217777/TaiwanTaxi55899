//
//  TextAlertView.h
//  TaiwanTaxi
//
//  Created by jason on 3/11/13.
//
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface TextAlertView : UIAlertView
{
    UITextView *textView;
}

- (id)initWithDefaultSetting;
- (id)initWithTitle:(NSString *)title termOfService:(NSString *)termOfService;

@end

@interface TextAlertViewiOS7 : CustomIOS7AlertView

- (id)initWithTitle:(NSString *)title termOfService:(NSString *)termOfService parentView:(UIView *)parentView;
- (id)initWithTitle:(NSString *)title precautionOfService:(NSString *)termOfService parentView:(UIView *)parentView;
@end
