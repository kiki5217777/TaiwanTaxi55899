//
//  HistoryViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "AddressViewController.h"
#import "UINavigationController+Customize.h"
#import "AddressCell.h"

@interface HistoryViewController ()
@property (retain, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation HistoryViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize myTableView;
@synthesize frc;

#pragma mark - dealloc

- (void)dealloc 
{
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
    [myTableView release];
    frc.delegate = nil;
    [frc release];
    [_dateFormatter release];
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
    
    self.title=@"記錄訂車";
    
    // -------------------- navigation bar buttons --------------------
    
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    UIButton* rightButton = [self.navigationController setUpCustomizeButtonWithText:@"編輯"
                                                                               icon:nil
                                                                      iconPlacement:CustomizeButtonIconPlacementLeft
                                                                             target:self
                                                                             action:@selector(editList)];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightButton] autorelease];
    
    // -------------------- view related --------------------
    
    self.trackedViewName = @"History Screen";
    
    // -------------------- ad --------------------
    
//    self.adBannerView.delegate = self;
    
    // -------------------- date formatter --------------------
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // -------------------- table view --------------------
    
    UINib *nib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:@"AddressCell"];
    self.myTableView.rowHeight = 60;
    
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
    [self setMyTableView:nil];
    self.frc.delegate = nil;
    [self setFrc:nil];
    [self setDateFormatter:nil];
    
//    [self setAdBannerView:nil];
//    self.adBannerView.delegate = nil;
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
    int count = [[self.frc sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:(AddressCell *)cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        TaxiOrder *f = [self.frc objectAtIndexPath:indexPath];
        f.markDelete = [NSNumber numberWithBool:YES];
        [self.orderManager save];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaxiOrder *order = [self.frc objectAtIndexPath:indexPath];
    
    AddressViewController *address = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    address.fromHistory = order.objectID;
    address.title = @"記錄訂車";
    [self.navigationController pushViewController:address animated:YES];
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
            [self configureCell:(AddressCell *)[tableView cellForRowAtIndexPath:indexPath]
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

- (void)configureCell:(AddressCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TaxiOrder *order = [self.frc objectAtIndexPath:indexPath];
    cell.addressLabel.text = order.pickupInfo.fullAddress;
    
    if(order.orderStatus.intValue == OrderStatusSubmittedSuccessful)
    {
        cell.resultLabel.textColor = [UIColor colorWithRed:21.0/255.0 green:146.0/255.0 blue:81.0/255.0 alpha:1.0];
        cell.resultLabel.text = @"成功";
        cell.infoLabel.text = [NSString stringWithFormat:@"車輛編號：%@  %@",
                               order.carNumber,
                               [self.dateFormatter stringFromDate:order.createdDate]];
    }
    else if(order.orderStatus.intValue == OrderStatusUserCancelled || order.orderStatus.intValue == OrderStatusUserCancelledSuccessful || order.orderStatus.intValue == OrderStatusUserCancelledFailure)
    {
        cell.resultLabel.textColor = [UIColor redColor];
        cell.resultLabel.text = @"取消";
        cell.infoLabel.text = [NSString stringWithFormat:@"時間：%@",
                               [self.dateFormatter stringFromDate:order.createdDate]];
    }
    else
    {
        cell.resultLabel.textColor = [UIColor redColor];
        cell.resultLabel.text = @"失敗";
        cell.infoLabel.text = [NSString stringWithFormat:@"時間：%@",
                               [self.dateFormatter stringFromDate:order.createdDate]];
    }
}

#pragma mark - load data

- (void)loadData
{
    // setup fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaxiOrder" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
	
	// setup sorting
    NSSortDescriptor *sort1 = [[[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, nil]];
	[fetchRequest setFetchBatchSize:20];
    
    // setup predicate
    NSMutableArray *predArray = [NSMutableArray array];
    [predArray addObject:[NSPredicate predicateWithFormat:@"markDelete = nil or markDelete = 0"]];
    [predArray addObject:[NSPredicate predicateWithFormat:@"customerInfo.tel = %@", self.manager.userTel]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predArray];
    
	
	// setup fetched result controller
	NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																				 managedObjectContext:self.context 
																				   sectionNameKeyPath:nil 
																							cacheName:nil];
	controller.delegate = self;
	self.frc = controller;
	[fetchRequest release];
	[controller release];
	
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

- (void)editList
{
    
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
    [self loadData];
}

@end
