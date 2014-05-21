//
//  MemberViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
//#import "AddressCell.h"

@interface MemberViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIButton *relievedBtn;
@property (retain, nonatomic) IBOutlet UIButton *contactBtn;
@property (retain, nonatomic) IBOutlet UIButton *bonusBtn;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) NSFetchedResultsController *frc;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

- (IBAction)bonusBannerPressed:(id)sender;
- (IBAction)relievedService:(id)sender;
- (IBAction)contactUs:(id)sender;

@end
