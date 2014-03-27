//
//  FavorViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FavorViewController.h"
#import "AddressViewController.h"
#import "UINavigationController+Customize.h"

@interface FavorViewController ()

@end

@implementation FavorViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize myTableView,cm5Array,cm5AddressArray,cm5filterArray;
@synthesize frc;

#pragma mark - dealloc

- (void)dealloc 
{
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
    [myTableView release];
    frc.delegate = nil;
    [frc release];
    [_myFooterView release];
    [_addFavoriteBtn release];
//    _adBannerView.delegate = nil;
//    [_adBannerView release]; _adBannerView = nil;
    
    //edited by kiki Huang 2013.12.13
    [_cm5Btn release];
    [_myHeaderView release];
    [super dealloc];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"我的最愛";
    self.addFavoriteBtn.selected= YES;
    buttontag = favoriteBtnTag;
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"Favorite Screen";
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    // -------------------- table view data ----------edited by kiki Huang 2013.12.13
    
    self.myTableView.tableFooterView = self.myFooterView;
    self.myTableView.tableHeaderView = self.myHeaderView;
    
    
    //---------------------TWMTA ad-------------------edited by kiki Huang 2013.12.13
    TWMTAMediaView *_upperAdView = [[TWMTAMediaView alloc] initWithFrame:CGRectMake(0, 10, 320, 50)
                                                  slotId:@"Dg1386570971882Nso"
                                             developerID:@""
                                              gpsEnabled:YES
                                                testMode:NO];
//    _upperAdView.delegate = self;
    [_upperAdView receiveAd];
    [self.view addSubview:_upperAdView];
    [_upperAdView release];
    
    //-------------------CM5--------------------------edited by kiki Huang 2014.01.04
    cm5Array = [[NSArray alloc]init];
    cm5filterArray = [[NSMutableArray alloc]init];
    cm5AddressArray = [[NSMutableArray alloc]init];
    NSString *CM5Version;
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"CM5Version"]) {
        CM5Version = @"0";
    }else{
        CM5Version = [[NSUserDefaults standardUserDefaults]objectForKey:@"CM5Version"];
    }
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    }else
        baseUrl = @"http://124.219.2.122/";
    NSLog(@"cm5 baseURL %@",baseUrl);

    
//    NSLog(@"CM5Version %@",CM5Version);
    //@"http://web55688.55688.com.tw/TII_FRONTSTAGE/API/PHONE/doCM5.aspx"
    NSDictionary *paremeter = [NSDictionary dictionaryWithObjectsAndKeys:@"doQUERY",@"DOMODE",CM5Version,@"VER",self.manager.userID,@"CUSTACCT", nil];
    NSLog(@"cm5 dict %@",paremeter);
    
    [self.manager taxiCM5doModeWithCookie:[NSString stringWithFormat:@"%@API/PHONE/doCM5.aspx",baseUrl] para:paremeter success:^(id JSON) {
        if (JSON!=nil && JSON !=[NSNull null]) {
            NSDictionary *jsonObject=[NSJSONSerialization
                                      JSONObjectWithData:JSON
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
            NSLog(@"cm5 success %@",jsonObject);
            
            if (jsonObject != nil) {
                if ([jsonObject objectForKey:@"ok"]) {
                    
                    if ([jsonObject objectForKey:@"rsp"] !=[NSNull null] && [jsonObject objectForKey:@"rsp"] !=nil) {
                        
                        if ([[jsonObject objectForKey:@"rsp"]  objectForKey:@"ROWS"] !=[NSNull null] && [[jsonObject objectForKey:@"rsp"]  objectForKey:@"ROWS"] !=nil) {
                            
                            
                            [self didFinishedPost:jsonObject];
                            //                        NSLog(@"kk : %@\n ww: %@", cm5AddressArray, cm5filterArray);
                            //                        for (NSDictionary *d in cm5filterArray) {
                            //                            NSLog(@"-------------------------------------------------------------");
                            //                            for (NSString *s in [d allKeys]) {
                            //                                NSLog(@" key : %@, value : %@",s, [d objectForKey:s]);
                            //                            }
                            //                        }
                            
                        }else{
                            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cm5AddressArray"]!=nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"cm5filterArray"] !=nil) {
                                cm5AddressArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5AddressArray"] copy];
                                cm5filterArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5filterArray"] copy];
                            }else
                                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，資料錯誤"];
                        }
                        
                    }else{
                        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cm5AddressArray"]!=nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"cm5filterArray"] !=nil) {
                            cm5AddressArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5AddressArray"] copy];
                            cm5filterArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5filterArray"] copy];
                        }
                        else
                           [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤，資料錯誤"];
                        //                    NSLog(@"kk : %@\n ww: %@", cm5AddressArray, cm5filterArray);
                        //                    for (NSDictionary *d in cm5filterArray) {
                        //                        NSLog(@"-------------------------------------------------------------");
                        //                        for (NSString *s in [d allKeys]) {
                        //                            NSLog(@" key : %@, value : %@",s, [d objectForKey:s]);
                        //                        }
                        //                    }
                    }
                    
                    
                }
                else{
                        
                    if ([jsonObject objectForKey:@"msg"]!=nil && [jsonObject objectForKey:@"msg"]!=[NSNull null]) {
                        [self showAlert:[jsonObject objectForKey:@"msg"]];
                    }else
                        [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
            }

        }else{
            [SVProgressHUD showErrorWithStatus:@"伺服器發生錯誤"];
        }
        
        
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"cm5 error %@",error);

    }];
    
    
    [self loadData];
}

- (void)viewDidUnload
{
//    self.adBannerView.delegate = nil;
    NSLog(@"Favor_viewDidUnload");
    [self setMyTableView:nil];
    self.frc.delegate = nil;
    [self setFrc:nil];
    
    [self setMyFooterView:nil];
    [self setAddFavoriteBtn:nil];
//    [self setAdBannerView:nil];
    
    //edited by kiki Huang 2013.12.13
    [self setCm5Btn:nil];
    [self setMyHeaderView:nil];
    [super viewDidUnload];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(buttontag == favoriteBtnTag){
        
        UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"編輯"
                                                                                   icon:nil
                                                                          iconPlacement:CustomizeButtonIconPlacementLeft
                                                                                 target:self
                                                                                 action:@selector(editList)];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
        [self.myTableView reloadData];
    }
    else
        [self.myTableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(buttontag == cm5BtnTag){
        
        self.frc.delegate = nil;
    }
        
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (buttontag == cm5BtnTag) {
        return 1;
    }
    int count = [[self.frc sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (buttontag == cm5BtnTag) {
        NSLog(@"%d",[cm5AddressArray count]);
        return [cm5AddressArray count];
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (buttontag == favoriteBtnTag) {
       
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.minimumFontSize = 10.0f;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    if (buttontag == cm5BtnTag) {
        NSString * cm5CellIdentifier = @"CM5Cell";
        UITableViewCell *cm5cell = [tableView dequeueReusableCellWithIdentifier:cm5CellIdentifier];
        if (cm5cell ==nil) {
            cm5cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cm5CellIdentifier] autorelease];
            cm5cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cm5cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cm5cell.textLabel.minimumFontSize = 10.0f;
            cm5cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cm5cell.textLabel.text = [cm5AddressArray objectAtIndex:indexPath.row];
            cm5cell.detailTextLabel.text = [cm5AddressArray objectAtIndex:indexPath.row];
        }
        return cm5cell;
    }
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
    if (buttontag ==cm5BtnTag) {
        return NO;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    if (buttontag ==cm5BtnTag) {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (buttontag == favoriteBtnTag) {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            Favorite *f = [self.frc objectAtIndexPath:indexPath];
            [self.context deleteObject:f];
            [self.orderManager save];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (buttontag == favoriteBtnTag) {
        self.frc.delegate = nil;
        
        // -------------------- update the order value --------------------
        
        NSMutableArray *reorderingRows = [NSMutableArray arrayWithArray:self.frc.fetchedObjects];
        
        Favorite *toMove = [reorderingRows objectAtIndex:fromIndexPath.row];
        [reorderingRows removeObjectAtIndex:fromIndexPath.row];
        [reorderingRows insertObject:toMove atIndex:toIndexPath.row];
        
        for(int i = 0; i < reorderingRows.count ; i++)
        {
            Favorite *f = reorderingRows[i];
            f.displayOrder = @(i);
        }
        
        [self.orderManager save];
        
        NSLog(@"fromIndexPath: %d", fromIndexPath.row);
        NSLog(@"toIndexPath: %d", toIndexPath.row);
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressViewController *address = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    
    if (buttontag == favoriteBtnTag) {
         Favorite *f = [self.frc objectAtIndexPath:indexPath];
        address.fromFavorite = f.objectID;
        address.buttonTag = favoriteBtnTag;
        address.title = @"我的最愛";

    }else{
        address.title = @"CM5";
        address.buttonTag = cm5BtnTag;
        NSLog(@"cm5dict %@",[cm5filterArray objectAtIndex:indexPath.row]);
        address.cm5Dict = [[cm5filterArray objectAtIndex:indexPath.row] mutableCopy];
    }
    [self.navigationController pushViewController:address
                                         animated:YES];
    [address release];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"刪除";
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    [self.myTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type 
{
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    
    UITableView *tableView = self.myTableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    [self.myTableView endUpdates];
}

#pragma mark - configure cell

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Favorite *f = [self.frc objectAtIndexPath:indexPath];
    
    cell.textLabel.text = f.displayName.length ? f.displayName : f.fullAddress;
    cell.detailTextLabel.text = f.fullAddress;
}

#pragma mark - load data

- (void)loadData
{
    self.frc.delegate = nil;
    self.frc = nil;
    
    
    // setup fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
    
    // setup predicate
    if(self.manager.userTel)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tel == %@", self.manager.userTel];
        [fetchRequest setPredicate:predicate];
    }
	
	// setup sorting
    NSSortDescriptor *sort1 = [[[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES] autorelease];
    NSSortDescriptor *sort2 = [[[NSSortDescriptor alloc] initWithKey:@"addedDate" ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
	[fetchRequest setFetchBatchSize:20];
	
	// setup fetched result controller
    //modified by kiki Huang 2014.01.06
//	NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
//																				 managedObjectContext:self.context 
//																				   sectionNameKeyPath:nil 
//																							cacheName:nil];
//	controller.delegate = self;
	self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                   managedObjectContext:self.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    self.frc.delegate = self;
	[fetchRequest release];
//	[controller release];
	
	NSError *error;
	if (![self.frc performFetch:&error]) 
    {
		// Update to handle the error appropriately.
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	else 
    {
		// load the table
		[self.myTableView reloadData];
	}
}

#pragma mark - user interaction

- (IBAction)addFavoriteBtnPressed:(id)sender
{
    AddressViewController *address = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    address.fromFavorite_create = YES;
    address.title = @"新增我的最愛";
    [self.navigationController pushViewController:address
                                         animated:YES];
    [address release];
}

- (void)editList
{
    
    if (buttontag == favoriteBtnTag) {
        BOOL isEditing = self.myTableView.editing;
        if(isEditing == NO)
        {
            UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"完成"
                                                                                       icon:nil
                                                                              iconPlacement:CustomizeButtonIconPlacementLeft
                                                                                     target:self
                                                                                     action:@selector(editList)];
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
        }
        else
        {
            UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"編輯"
                                                                                       icon:nil
                                                                              iconPlacement:CustomizeButtonIconPlacementLeft
                                                                                     target:self
                                                                                     action:@selector(editList)];
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
        }
        
        [self.myTableView setEditing:!isEditing animated:YES];
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
#pragma mark - notif

- (void)handleSignInSuccessful:(NSNotification *)notif
{
    [super handleSignInSuccessful:notif];
//    [self loadData];
}

#pragma mark- Button Event methods
//edited by kiki Huang 2014.01.04
- (IBAction)cm5ButtonPressed:(id)sender {
//    NSMutableArray *array=[[NSMutableArray alloc]init];
//    for (int i=0; i<1000000; i++) {
//        NSString *str = @"123";
//        [array addObject:str];
//    }
    buttontag = cm5BtnTag;
     self.title=@"CM5";
    self.frc.delegate = nil;
    self.myTableView.tableFooterView = nil;
    self.addFavoriteBtn.selected = NO;
    self.cm5Btn.selected = YES;
    self.navigationItem.rightBarButtonItem=nil;
    [self.myTableView setEditing:NO animated:YES];
    [self.myTableView reloadData];

   }

- (IBAction)myFavoriteBtnPressed:(id)sender {
    buttontag = favoriteBtnTag;
     self.title=@"我的最愛";
    self.myTableView.tableFooterView = self.myFooterView;
    self.cm5Btn.selected = NO;
    self.addFavoriteBtn.selected = YES;
    [self loadData];
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"編輯"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(editList)];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
}

#pragma mark - Show Alert
-(void)showAlert:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles: nil];
    [alert show];
    alert = nil;
}

#pragma mark - Response data handle
-(void)didFinishedPost:(NSDictionary *)jsonObject{
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"CM5Version"]) {
        cm5Array = [[[jsonObject objectForKey:@"rsp"]  objectForKey:@"ROWS"]  copy];
        [self responseDataHandler:cm5Array];
        [[NSUserDefaults standardUserDefaults]setObject:[[[jsonObject objectForKey:@"rsp"] objectForKey:@"VER"] stringValue] forKey:@"CM5Version"];

    }else{
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"CM5Version"] isEqualToString:[[[jsonObject objectForKey:@"rsp"] objectForKey:@"VER"] stringValue]]) {
            cm5Array = [[[jsonObject objectForKey:@"rsp"]  objectForKey:@"ROWS"]  copy];
            [self responseDataHandler:cm5Array];
            [[NSUserDefaults standardUserDefaults]setObject:[[[jsonObject objectForKey:@"rsp"] objectForKey:@"VER"] stringValue] forKey:@"CM5Version"];
        }else{
            cm5AddressArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5AddressArray"] copy];
            cm5filterArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"cm5filterArray"] copy];
        }
    }
    
    
    
    
}
-(void)responseDataHandler:(NSArray *)array{
    for (NSDictionary *dict in array) {
        NSMutableDictionary *cm5TempDict = [[NSMutableDictionary alloc]init];
        NSLog(@"cm5Array %@",dict);
        NSString *city=@"";
        NSString *dist = @"";
        NSString *street = @"";
        NSString *seg = @"";
        NSString *lane = @"";
        NSString *alley = @"";
        NSString *block = @"";
        NSString *memo = @"";
        
        if ([dict objectForKey:@"ADDRCITY"]!=[NSNull null]) {
            city = [dict objectForKey:@"ADDRCITY"];
            [cm5TempDict setObject:city forKey:@"ADDRCITY"];
        }else{
            [cm5TempDict setObject:city forKey:@"ADDRCITY"];
        }
        
        
        if ([dict objectForKey:@"ADDRDIST"]!=[NSNull null]) {
            dist = [dict objectForKey:@"ADDRDIST"];
            [cm5TempDict setObject:dist forKey:@"ADDRDIST"];
        }else{
            [cm5TempDict setObject:dist forKey:@"ADDRDIST"];
        }
        
        if ( [dict objectForKey:@"ADDRSTREET"] != [NSNull null]) {
            street = [dict objectForKey:@"ADDRSTREET"];
            [cm5TempDict setObject:street forKey:@"ADDRSTREET"];
        }else{
            [cm5TempDict setObject:street forKey:@"ADDRSTREET"];
        }
        
        if ([dict objectForKey:@"ADDRSEG"] !=[NSNull null]) {
            seg = [dict objectForKey:@"ADDRSEG"];
            if (seg ) {
                NSLog(@"%@",[seg substringFromIndex:seg.length-1]);
                
                if (seg.length>0) {
                    [cm5TempDict setObject:seg forKey:@"ADDRSEG"];
                    
                    if (![[seg substringFromIndex:seg.length-1] isEqualToString:@"段"]) {
                        seg = [NSString stringWithFormat:@"%@段",seg];
                        
                    }
                }
                else{
                    NSLog(@"org seg %@",seg);
                    [cm5TempDict setObject:seg forKey:@"ADDRSEG"];
                    
                }
                
            }
        }else{
            NSLog(@"org seg %@",seg);
            [cm5TempDict setObject:seg forKey:@"ADDRSEG"];
            
        }
        
        
        if ([dict objectForKey:@"ADDRLANE"] != [NSNull null]) {
            lane = [dict objectForKey:@"ADDRLANE"];
            if (lane) {
                if (lane.length>0) {
                    
                    
                    if (![[lane substringFromIndex:lane.length-1] isEqualToString:@"巷"]) {
                        [cm5TempDict setObject:lane forKey:@"ADDRLANE"];
                        lane = [NSString stringWithFormat:@"%@巷",lane];
                        NSLog(@"lane巷%@",lane);
                        
                        
                    }else{
                        lane = [lane substringToIndex:lane.length-1];
                        NSLog(@"lan %@",lane);
                        [cm5TempDict setObject:lane forKey:@"ADDRLANE"];
                    }
                    
                }else
                    [cm5TempDict setObject:lane forKey:@"ADDRLANE"];
                
                
            }
        }
        else
            [cm5TempDict setObject:lane forKey:@"ADDRLANE"];
        
        if ([dict objectForKey:@"ADDRALLEY"] !=[NSNull null]) {
            alley = [dict objectForKey:@"ADDRALLEY"];
            if (alley ) {
                if (alley.length>0) {
                    
                    if (![[alley substringFromIndex:alley.length-1] isEqualToString:@"弄"]) {
                        [cm5TempDict setObject:alley forKey:@"ADDRALLEY"];
                        alley = [NSString stringWithFormat:@"%@弄",alley];
                        
                        
                    }else{
                        alley = [alley substringToIndex:alley.length-1];
                        [cm5TempDict setObject:alley forKey:@"ADDRALLEY"];
                    }
                }else
                    [cm5TempDict setObject:alley forKey:@"ADDRALLEY"];

                
            }
        }else
            [cm5TempDict setObject:alley forKey:@"ADDRALLEY"];
        
        if ([dict objectForKey:@"ADDRBLK"] !=[NSNull null]) {
            block = [dict objectForKey:@"ADDRBLK"];
            if (block ) {
                if (block.length>0) {
                    
                    if (![[block substringFromIndex:block.length-1] isEqualToString:@"號"]) {
                         [cm5TempDict setObject:block forKey:@"ADDRBLK"];
                        block = [NSString stringWithFormat:@"%@號",block];
                       
                    }
                    else{
                        block = [block substringToIndex:block.length-1];
                        [cm5TempDict setObject:block forKey:@"ADDRBLK"];
                    }
                    
                } else
                    [cm5TempDict setObject:block forKey:@"ADDRBLK"];
                
            }
            
        }
        else
            [cm5TempDict setObject:block forKey:@"ADDRBLK"];
        
        
        if ([dict objectForKey:@"ADDRMORE"] !=[NSNull null]) {
            memo = [dict objectForKey:@"ADDRMORE"];
            [cm5TempDict setObject:memo forKey:@"ADDRMORE"];
        }else{
            [cm5TempDict setObject:memo forKey:@"ADDRMORE"];
        }
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",city,dist,street,seg,lane,alley,block];
        [cm5AddressArray addObject:address];
        [[NSUserDefaults standardUserDefaults]setObject:cm5AddressArray forKey:@"cm5AddressArray"];
        address = nil;
        
        [cm5filterArray addObject:cm5TempDict];
        [[NSUserDefaults standardUserDefaults]setObject:cm5filterArray forKey:@"cm5filterArray"];
        cm5TempDict = nil;
        
    }

}
@end
