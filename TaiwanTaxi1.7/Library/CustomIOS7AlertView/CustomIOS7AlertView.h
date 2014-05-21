//
//  CustomIOS7AlertView.h
//  CustomIOS7AlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomIOS7AlertView : UIView

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray *buttonTitles;

- (id)initWithParentView: (UIView *)_parentView;
- (void)show:(NSInteger)tag;//modified by kiki Huang 2013.12.25
- (void)close;
- (void)setButtonTitles: (NSMutableArray *)buttonTitles;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;

- (void)customIOS7FreewayDialogButtonTouchUpInside:(id)sender;//edited by kiki Huang 2013.12.25
@end
