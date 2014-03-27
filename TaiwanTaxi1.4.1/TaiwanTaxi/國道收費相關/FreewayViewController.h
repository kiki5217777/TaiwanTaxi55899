//
//  FreewayViewController.h
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/17.
//  Copyright (c) 2013年 kiki Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBManager.h"
#import "BaseViewController.h"

@interface FreewayViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
    
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) IBOutlet UIView *morebtnView;
@property (retain, nonatomic) FMDBManager *fmdbManager;
@property (retain ,nonatomic) NSMutableArray *cellArray;
@property (retain ,nonatomic) NSMutableArray *freewayArray;
@property (retain ,nonatomic) NSMutableArray *startRoadArray;
@property (retain ,nonatomic) NSArray *tempRoadArray;
@property (retain ,nonatomic) NSArray *roadArray;
@property (retain, nonatomic) NSArray *filterExitOnlyArray;
@property (retain ,nonatomic) UIActionSheet *actionSheet;
@property (retain ,nonatomic) NSString *pickerViewSelectRowTitle;

@property (nonatomic, strong) UITextField *pickerViewTextField;
- (IBAction)addMoreBtnPressed:(id)sender;
- (IBAction)calculateTotalRate:(id)sender;
@end
