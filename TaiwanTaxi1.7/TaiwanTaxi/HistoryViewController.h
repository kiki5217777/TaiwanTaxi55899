//
//  HistoryViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface HistoryViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) NSFetchedResultsController *frc;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

@end
