//
//  IntroductionViewController.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/22.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TaxiManager.h"

@protocol introDelegate
-(void)changeToLoginView;
@end

@interface IntroductionViewController : UIViewController<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (retain ,nonatomic)id<introDelegate> delegate;
@property (retain, nonatomic)UITapGestureRecognizer *tapGesture;
@property (retain, nonatomic) IBOutlet UIImageView *introImageView;
@property (retain, nonatomic) TaxiManager *manager;
@property (retain, nonatomic) IBOutlet UILabel *currentVersionLabel;
@end
