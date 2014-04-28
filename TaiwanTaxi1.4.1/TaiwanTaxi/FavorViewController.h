//
//  FavorViewController.h
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
#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			6.0
#define kTextFieldHeight		30.0
#define favoriteBtnTag          70
#define cm5BtnTag               71
//----------------------------------------------
@interface FavorViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CustomAdBannerViewDelegate,TWMTAMediaViewDelegate>
{
    NSInteger buttontag;
}

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) NSFetchedResultsController *frc;
@property (retain, nonatomic) IBOutlet UIView *myHeaderView;

@property (retain, nonatomic) IBOutlet UIView *myFooterView;
@property (retain, nonatomic) IBOutlet UIButton *addFavoriteBtn;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;

- (IBAction)addFavoriteBtnPressed:(id)sender;

//edited by kiki Huang 2013.12.12---------------------
@property (retain, nonatomic) NSArray *cm5Array;
@property (retain, nonatomic) NSMutableArray *cm5filterArray;
@property (retain, nonatomic) NSMutableArray *cm5AddressArray;
@property (retain, nonatomic) IBOutlet UIButton *cm5Btn;
- (IBAction)cm5ButtonPressed:(id)sender;
- (IBAction)myFavoriteBtnPressed:(id)sender;


@end
