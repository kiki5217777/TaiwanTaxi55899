//
//  WaitCarAlertView.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

//edited by kiki Huang 2013.12.17
#import "CustomAlertViewWithAD.h"

typedef enum {
    AlertViewModeProgress           = 0,
    AlertViewModeTableView,
    AlertViewModeWaitCard,
} AlertViewMode;

@interface WaitCarAlertView : UIAlertView
{
    UIImageView *imgView;
    UIActivityIndicatorView *indView;
}

@property (nonatomic, assign) AlertViewMode mode;

- (id)initWithDefaultSetting;
- (id)initWithAddress:(NSString *)address;

@end

@interface WaitCarAlertViewiOS7 : CustomIOS7AlertView

- (id)initWithAddress:(NSString *)address parentView:(UIView *)parentView;

@end

//added by kiki Huang 2013.12.17
@interface WaitCarAlertViewWithAD : CustomAlertViewWithAD

- (id)initWithAddress:(NSString *)address parentView:(UIView *)parentView;

@end