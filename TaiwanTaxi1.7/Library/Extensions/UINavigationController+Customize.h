//
//  UINavigationController+Customize.h
//  testNaviWithCommonBG
//
//  Created by jason on 2011/8/4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    CustomizeButtonIconPlacementLeft,
    CustomizeButtonIconPlacementRight
} CustomizeButtonIconPlacement;

@interface UINavigationController (Customize)
- (UIButton*)setUpCustomizeBackButton;
- (UIButton*)setUpCustomizeBackButtonWithText:(NSString *)aString;
- (NSString *)checkForInvalidText:(NSString *)aText;
- (UIButton*)setUpCustomizeButtonWithText:(NSString *)aString icon:(UIImage *)anIcon iconPlacement:(CustomizeButtonIconPlacement)placement target:(id)target action:(SEL)action;
- (void)setUpCustomizeAppearence;
@end

