//
//  CustomAlertViewWithAD.h
//  TaiwanTaxi
//
//  Created by kiki Huang Huang on 13/12/16.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomIOS7AlertView.h"
#import "TWMTAMediaView.h"

@interface CustomAlertViewWithAD : UIView<TWMTAMediaViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, retain) UIView *buttonView;    // Buttons on the bottom of the dialog
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray *buttonTitles;

- (id)initWithParentView: (UIView *)_parentView;
- (void)show;
- (void)close;
- (void)setButtonTitles: (NSMutableArray *)buttonTitles;
//-(UIView*)setupInterstitialView:(CGSize)_size;
//- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;

@end
