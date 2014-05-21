//
//  LandmarkViewController.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 8/1/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "LandmarkViewController.h"
#import "AddressViewController.h"
#import "UINavigationController+Customize.h"

@interface LandmarkViewController ()

@end

@implementation LandmarkViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize myTableView;
@synthesize places;
@synthesize mySearchBar;

#pragma mark - dealloc

- (void)dealloc 
{
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
    [myTableView release];
    [places release];
    mySearchBar.delegate = nil;
    [mySearchBar release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release]; _adBannerView = nil;
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"附近地標";
    
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"搜尋"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(searchLandmark)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"Landmark Screen";
    
    mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.placeholder = @"請輸入一個地標名稱...";
    
    // the purpose is to remove the styled chrome, but it would no longer work under
    // ios7
    if([self isRunningiOS7] == NO)
        [[mySearchBar.subviews objectAtIndex:0] removeFromSuperview];
    
    [mySearchBar setBackgroundColor:[UIColor clearColor]];
    mySearchBar.delegate = self;
    [mySearchBar sizeToFit];
    bSearchIsOn = NO;
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    
    // show warning message
    [self executeBlock:^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"提醒您，附近地標功能所顯示地址，會與實際地址有些許誤差，建議可確認完整地址後，再按「確定叫車」"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        [alertView release];
    } withDelay:1.0];
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    // -------------------- table view data --------------------
    
    [self loadData];
    
    //edited by kiki Huang 2013.12.13
    //---------------------TWMTA ad-------------------
     TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                                  slotId:@"Dg1386570971882Nso"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.view addSubview:_upperAdView];
    [_upperAdView release];
    //-------------------------------------------------
}

- (void)viewDidUnload
{
//    self.adBannerView.delegate = nil;
    [self setMyTableView:nil];
    [self setPlaces:nil];
    [self setMySearchBar:nil];
//    [self setAdBannerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.minimumFontSize = 10.0f;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *p = [self.places objectAtIndex:indexPath.row];
    
    AddressViewController *address = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    address.fromLandmark = p;
    address.title = @"附近地標";
    [self.navigationController pushViewController:address 
                                         animated:YES];
    [address release];
}

#pragma mark - configure cell

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *l = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = [l objectForKey:@"name"];
    cell.detailTextLabel.text = [l objectForKey:@"vicinity"];
}

#pragma mark - load data

- (void)loadData
{
    [SVProgressHUD showWithStatus:@"搜尋中"];
    
    [self.manager nearbyLandmarksSuccess:^(NSArray *results) {
        
        self.places = results;
        [self.myTableView reloadData];
        
        [SVProgressHUD dismiss];
        
    } failure:^(NSString *reason, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:reason];
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar*)theSearchBar
{
    int len = [[mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    
    if (len > 2)
    {
        [self searchLandmark];
        
        [SVProgressHUD showWithStatus:@"搜尋中"];
        [self.manager searchLandmarks:mySearchBar.text success:^(NSArray *results) {
            self.places = results;
            [self.myTableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSString *reason, NSError *error) {
            [SVProgressHUD showErrorWithStatus:reason];
        }];
    }
    else
    {
        [mySearchBar resignFirstResponder];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"請至少輸入兩個字以上..."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
/*
#pragma mark - CustomAdBannerViewDelegate

- (void)bannerButtonPressed:(NSString *)url
{
    if([url isKindOfClass:[NSNull class]] == NO)
    {
        [self handleClickAd:url];
    }
}
*/
#pragma mark - user interaction

- (void)searchLandmark
{
    bSearchIsOn = ! bSearchIsOn;
    
    if (bSearchIsOn)
    {
        self.myTableView.tableHeaderView = mySearchBar;
    }
    else
    {
        self.myTableView.tableHeaderView = nil;
        [mySearchBar resignFirstResponder ];
    }
    
    [self.myTableView scrollRectToVisible:[[self.myTableView tableHeaderView] bounds] animated:NO];
}

@end
