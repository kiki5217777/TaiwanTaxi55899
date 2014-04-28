//
//  NewsMessageViewController.h
//  TaiwanTaxi
//
//  Created by jason on 2/7/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"
#import "UINavigationController+Customize.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface NewsMessageViewController : BaseViewController <CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>

//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

@end
