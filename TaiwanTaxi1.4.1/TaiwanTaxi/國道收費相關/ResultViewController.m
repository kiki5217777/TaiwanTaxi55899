//
//  ResultViewController.m
//  TaiwanTaxi
//
//  Created by kiki Huang on 13/12/22.
//  Copyright (c) 2013年 kiki Huang. All rights reserved.
//

#import "ResultViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"

@interface ResultViewController ()

@end

@implementation ResultViewController
@synthesize routeArray,totalPrice;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
#ifdef __IPHONE_7_0
        if([[UIDevice currentDevice].systemVersion hasPrefix:@"7"])
        {
            self.extendedLayoutIncludesOpaqueBars = YES;
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"國道收費試算結果";
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"返回"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(close)];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    self.myResultTableView.tableFooterView = self.resultView;
    self.resultLabel.text = [NSString stringWithFormat:@"通行費用：NT$ %@",totalPrice];

}
-(void)viewWillAppear:(BOOL)animated{
//    NSLog(@"route array %d", [routeArray count]);
//    NSLog(@"price %@",totalPrice);
    [super viewWillAppear:YES];
    if (self.myResultTableView.contentSize.height > self.myResultTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.myResultTableView.contentSize.height - self.myResultTableView.frame.size.height);
        [self.myResultTableView setContentOffset:offset animated:YES];
    }
    
}
-(void)viewDidUnload{
    self.myResultTableView = nil;
    self.resultView = nil;
    self.resultLabel = nil;
    self.routeArray = nil;
    self.totalPrice = nil;
    [super viewDidUnload];
}
-(void)dealloc{
    
    [self.myResultTableView release];
    [self.resultView release];
    [self.resultLabel release];
    [self.routeArray release];
    [self.totalPrice release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user interaction

-(void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [routeArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"CustomTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else{
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView *customCellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 59)];
    
    UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 59)];
    [backgroundImage setImage:[UIImage imageNamed:@"calculate_cell.png"]];
    [customCellView addSubview:backgroundImage];
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 50, 30)];
    [numberLabel setBackgroundColor:[UIColor clearColor]];
    numberLabel.text = [NSString stringWithFormat:@"%d.",indexPath.row+1];
    numberLabel.textColor =[UIColor colorWithRed:34.0f/255 green:100.0f/255 blue:166.0f/255 alpha:1.0f];
    numberLabel.font = [UIFont fontWithName:@"Arial" size:20];
    [customCellView addSubview:numberLabel];
    
    UILabel *routeLabel = [[UILabel alloc]initWithFrame:CGRectMake(62, 1.5,200, 30)];
    [routeLabel setBackgroundColor:[UIColor clearColor]];
    routeLabel.text = [NSString stringWithFormat:@"從 %@ 到 %@",[[routeArray objectAtIndex:indexPath.row] objectForKey:@"StartRoad"],[[routeArray objectAtIndex:indexPath.row] objectForKey:@"EndRoad"]];
    routeLabel.textColor =[UIColor blackColor];
    routeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [customCellView addSubview:routeLabel];
    
    UILabel *feeLabel = [[UILabel alloc]initWithFrame:CGRectMake(62, 29.5, 150, 30)];
    [feeLabel setBackgroundColor:[UIColor clearColor]];
    feeLabel.text = [NSString stringWithFormat:@"通行費：NT$ %@",[[routeArray objectAtIndex:indexPath.row] objectForKey:@"PRICE"]] ;
    feeLabel.textColor =[UIColor blackColor];
    feeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [customCellView addSubview:feeLabel];
    
    UILabel *kmLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 8.5, 80, 40)];
    [kmLabel setBackgroundColor:[UIColor clearColor]];
    kmLabel.text = [NSString stringWithFormat:@"%@ km",[[routeArray objectAtIndex:indexPath.row] objectForKey:@"KM"]];
    kmLabel.textAlignment = NSTextAlignmentCenter;
    kmLabel.textColor =[UIColor whiteColor];
    kmLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [customCellView addSubview:kmLabel];

    [cell.contentView addSubview:customCellView];
    
    return cell;
}
@end
