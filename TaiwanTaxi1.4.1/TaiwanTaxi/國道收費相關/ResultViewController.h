//
//  ResultViewController.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/22.
//  Copyright (c) 2013年 kiki Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController<UITableViewDataSource,UITabBarDelegate>
@property (retain, nonatomic) IBOutlet UITableView *myResultTableView;
@property (retain, nonatomic) IBOutlet UIView *resultView;
@property (retain, nonatomic) IBOutlet UILabel *resultLabel;
@property (retain, nonatomic) NSMutableArray *routeArray;
@property (retain, nonatomic) NSString *totalPrice;
@end
