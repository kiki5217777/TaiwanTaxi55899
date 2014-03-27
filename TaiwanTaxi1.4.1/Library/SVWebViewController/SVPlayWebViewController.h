//
//  SVPlayWebViewController.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 14/1/16.
//
//

#import <UIKit/UIKit.h>

#import "SVModalWebViewController.h"

@interface SVPlayWebViewController : UIViewController
- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (id)initWithPOST:(NSDictionary*)dict;

@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;
@property (nonatomic, assign) BOOL showPageTitle;
@property (nonatomic, assign) BOOL manualToolBar;
@end
