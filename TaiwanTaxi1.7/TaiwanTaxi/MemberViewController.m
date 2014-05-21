//
//  MemberViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemberViewController.h"
#import "RatingViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Customize.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "AddressCell.h"


@implementation MemberViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#pragma mark - synthesize

@synthesize myTableView;
@synthesize contactBtn;
@synthesize relievedBtn;
@synthesize frc;
@synthesize dateFormatter;

#pragma mark - dealloc

- (void)dealloc
{
    [relievedBtn release];
    [contactBtn release];
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
    [myTableView release];
    frc.delegate = nil;
    [frc release];
    [dateFormatter release];
    
    [_bonusBtn release];
    [_contentView release];
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
    
    // -------------------- view --------------------
    
    if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        self.bonusBtn.hidden = YES;
        
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.y = self.bonusBtn.frame.origin.y;
        contentFrame.size.height += self.bonusBtn.frame.size.height;
        self.contentView.frame = contentFrame;
    }
    
    // -------------------- date formatter --------------------
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // -------------------- table view --------------------
    
    UINib *nib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:@"AddressCell"];
    
    // -------------------- table view data --------------------
    
    [self loadData];
}

- (void)viewDidUnload
{
    [self setRelievedBtn:nil];
    [self setContactBtn:nil];
    [self setMyTableView:nil];
    self.frc.delegate = nil;
    [self setFrc:nil];
    [self setDateFormatter:nil];
    
    [self setBonusBtn:nil];
    [self setContentView:nil];
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
    AddressCell* cell = (AddressCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
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
    // test purpose
    /*
    TaxiOrder *order = [self.frc objectAtIndexPath:indexPath];
    order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedSuccessful];
    [self.orderManager save];
    [SVProgressHUD showSuccessWithStatus:@"已改完"];
    */
    // ---------

    TaxiOrder *order = [self.frc objectAtIndexPath:indexPath];
    
    if(order.orderStatus.intValue != OrderStatusSubmittedSuccessful)
    {
        [SVProgressHUD showErrorWithStatus:@"並不是成功搭車記錄喔"];
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RatingViewController *ratingViewController = [[[RatingViewController alloc] initWithNibName:@"RatingViewController"
                                                                                         bundle:nil] autorelease];
    ratingViewController.orderID = order.objectID;
    
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:ratingViewController] autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [delegate presentModalViewController:nav animated:YES];
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

- (IBAction)bonusBannerPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"準備中"];
    [self.manager generateBonusLink:^(NSString *urlLink, NSString *msg, NSError *error) {
        
        button.enabled = YES;
        
        if(urlLink.length)
        {
            SVModalWebViewController *swc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:urlLink]];
            swc.availableActions = SVWebViewControllerAvailableActionsNone;
            swc.navigationBar.barStyle = UIBarStyleBlackOpaque;
            swc.toolbar.barStyle = UIBarStyleBlackOpaque;
            swc.webViewController.navigationItem.title = @"紅利大積點";
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.window.rootViewController presentViewController:swc
                                                             animated:YES
                                                           completion:^{
                                                               
                                                               int64_t delayInSeconds = 2.0;
                                                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                   [SVProgressHUD showSuccessWithStatus:msg];
                                                               });
                                                               
                                                               
                                                           }];
            [swc release];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:msg];
        }
        
    }];
}

- (IBAction)relievedService:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_TRACKING_VIEW
                                    object:self];
    
    [self passCheckpoint:TF_CHECKPOINT_MEMBER_TRACKING];
}

- (IBAction)contactUs:(id)sender
{
    [self.notifCenter postNotificationName:SHOW_MEMBER_CONTACT_VIEW
                                    object:self];
    
    [self passCheckpoint:TF_CHECKPOINT_MEMBER_SUGGESTION];
}

#pragma mark - notif

- (void)handleSignInSuccessful:(NSNotification *)notif
{
    [super handleSignInSuccessful:notif];
    [self loadData];
}

@end
