//
//  RootViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewController;

@interface RootViewController : UITabBarController
{    
}

@property (nonatomic, retain) HomeViewController *homeViewController;

//-(void)removeIntroView;
@end
