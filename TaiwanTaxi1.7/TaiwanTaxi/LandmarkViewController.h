//
//  LandmarkViewController.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 8/1/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"

@interface LandmarkViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>
{
    BOOL    bSearchIsOn;
}

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) UISearchBar *mySearchBar;
@property (retain, nonatomic) NSArray *places;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;



@end
