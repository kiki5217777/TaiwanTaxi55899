//
//  AppDelegate.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SignInViewController.h"

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "NSData+helper.h"
#import "TaxiManager.h"
#import "Constants.h"
#import "ServiceManager.h"

//#import "TestFlight.h"
#import "GAI.h"

//edited by kiki Huang 2013.12.22
#import "IntroductionViewController.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
//edited by kiki Huang 2014.01.16
#define PUSH_MSG_ALERT          110

@interface AppDelegate () {
    BOOL isalertShow;
}

@property (nonatomic, retain) NSString *remoteNotifMsg;
@end


#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define TEST_FLIGHT_TOKEN @"85e8d0a59837fe25965ab618e6e51e23_MTE2OTEwMjAxMi0wOC0xNSAxMzo1ODoyOS43NTQxNTI"

#define VERSION_CHECK_ALERT     102



@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

//edited by kiki Huang 2014.01.16
@synthesize pushUrl;

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    isalertShow = false;
    NSLog(@"%@", NSStringFromCGRect(self.window.frame));
    
    //  ---------- Override point for customization after application launch. ----------
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    //modified by kiki Huang 2014.02.10
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"newVersionMenuSetup"])
    {
        // This is the first launch ever
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newVersionMenuSetup"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ImageIsDownload"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"MenuObject"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"ButtonObject"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(payload)
    {
        NSDictionary *aps = [payload objectForKey:@"aps"];

        if ([[payload objectForKey:@"srv"] length]>0) {
            NSLog(@"srv %@",[payload objectForKey:@"srv"]);
            
            if ([[[payload objectForKey:@"srv"] substringToIndex:1] isEqualToString:@"U"]) {
                NSInteger strlength = [[payload objectForKey:@"srv"] length];
                
                if([[aps objectForKey:@"alert"] isKindOfClass:[NSString class]] == YES)
                {
                    self.remoteNotifMsg = [aps objectForKey:@"alert"];
                    [[NSUserDefaults standardUserDefaults]setObject:self.remoteNotifMsg forKey:@"PushUrlMessage"];
                    
                }

                if (strlength>5) {
                    
                    //for test 2014.01.17
                    NSString *baseUrl;
                    
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
                        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
                    }else
                        baseUrl = @"http://124.219.2.122/";
                    
                    NSString *urlId=[[payload objectForKey:@"srv"] substringFromIndex:4];
                    pushUrl = [[NSString stringWithFormat:@"%@api/GetUrl?Id=%@",baseUrl,urlId] copy];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:pushUrl forKey:@"pushUrl"];
                    NSLog(@"pusUrl %@",pushUrl);
                    
                }
                
            }
            else{
                [[NSUserDefaults standardUserDefaults]setObject:[payload objectForKey:@"srv"] forKey:@"PushFunctionTag"];
                [[NSUserDefaults standardUserDefaults]setObject:[aps objectForKey:@"alert"] forKey:@"PushMessage"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushFuction" object:nil];
                            }
        }
        else{
            
            if([[aps objectForKey:@"alert"] isKindOfClass:[NSString class]] == YES)
            {
                self.remoteNotifMsg = [aps objectForKey:@"alert"];
                [self showPushMsg];

            }
        }
    }

    // setup logging framework
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // setup service manager
//    [[ServiceManager sharedInstance] startManageAdService];
    
    // setup the root view controller
//    RootViewController *rvc = [[RootViewController alloc] init];
//    self.window.rootViewController = rvc;
//    [rvc release];
    IntroductionViewController *rvc = [[IntroductionViewController alloc] init];
    rvc.delegate = self;
    self.window.rootViewController = rvc;
    [rvc release];

    
    // register for push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // retrieve/update for fb share info
    [[TaxiManager sharedInstance] retrieveFBInfoSuccess:^{
        DDLogInfo(@"retrieved FB info successful");
    } failure:^(NSString *errorMessage, NSError *error) {
        DDLogError(@"retrieved FB info failed: %@", errorMessage);
    } ];
    
    // setup google analytics
    [GAI sharedInstance].debug = IS_DEBUG_MODE;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-35532709-1"];
    
    // crash analytics
//    [Crashlytics startWithAPIKey:@"452147fc8d1c8cb765cd470abaf87564448ce28a"];
    [Crashlytics startWithAPIKey:@"9c29f98d878107fa70ef1f85b8f37fee55551e3a"];
    // --------------------------------------------------------------------------------
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"DBVersion"]==nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"DBVersion"];
        NSLog(@"appdelegate ver launch %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"DBVersion"]);
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeHomeButtonUI" object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    

//    if(self.remoteNotifMsg.length)
//    {
//        [self showPushMsg];
//    }
    
    // To allow proper handle of user pressed home button
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession handleDidBecomeActive];
    }
    
    // need to check if user has turned on/off the push
//    [self processPush];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    // FBSample logic
    // if the app is going away, we close the session object; this is a good idea because
    // things may be hanging off the session, that need releasing (completion block, etc.) and
    // other components in the app may be awaiting close notification in order to do cleanup
    [FBSession.activeSession close];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TaiwanTaxi" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TaiwanTaxi.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - handling URL

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - push notification delegate

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"push userInfo %@",userInfo);
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
    if ([[userInfo objectForKey:@"srv"]length]>0) {
        NSLog(@"srv %@",[userInfo objectForKey:@"srv"]);
        
        
        if ([[[userInfo objectForKey:@"srv"] substringToIndex:1] isEqualToString:@"U"]) {
            
            NSInteger strlength = [[userInfo objectForKey:@"srv"] length];
            if ([[aps objectForKey:@"alert"] isKindOfClass:[NSString class]] == YES)
            {
                self.remoteNotifMsg = [aps objectForKey:@"alert"];
                [[NSUserDefaults standardUserDefaults]setObject:self.remoteNotifMsg forKey:@"PushUrlMessage"];
            }
            if (strlength>5) {
                
                //for test 2014.01.17
                NSString *baseUrl;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
                    baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
                }else
                    baseUrl = @"http://124.219.2.122/";
                
                NSString *urlId=[[userInfo objectForKey:@"srv"] substringFromIndex:4];
                pushUrl = [[NSString stringWithFormat:@"%@api/GetUrl?Id=%@",baseUrl,urlId] copy];
                [[NSUserDefaults standardUserDefaults]setObject:pushUrl forKey:@"pushUrl"];
                NSLog(@"pusUrl %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"pushUrl"]);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PushUrl" object:nil];
            
            
        }
        else{
            [[NSUserDefaults standardUserDefaults]setObject:[userInfo objectForKey:@"srv"] forKey:@"PushFunctionTag"];
            [[NSUserDefaults standardUserDefaults]setObject:[aps objectForKey:@"alert"] forKey:@"PushMessage"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PushFuction" object:nil];
            }
        
       
    }else{
        if([[aps objectForKey:@"alert"] isKindOfClass:[NSString class]] == YES )
            self.remoteNotifMsg = [aps objectForKey:@"alert"];
        
            if(application.applicationState == UIApplicationStateActive && self.remoteNotifMsg.length)
            {
                [self showPushMsg];
            }
    }
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSString *deviceToken = [devToken hexString];
    
    DDLogInfo(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", devToken);
    
    if(deviceToken.length)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // so this is the first time we are registering for push
//        if([userDefaults stringForKey:USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN] == nil)
//        {
            [userDefaults setObject:deviceToken forKey:USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN];
            [userDefaults synchronize];
            [self processPush];
//        }
        
//        [userDefaults setObject:deviceToken forKey:USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN];
//        [userDefaults synchronize];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

#pragma mark - facebook Login Code

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    
    switch (state)
    {
        case FBSessionStateOpen:
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FB_SHARE_FEED_DIALOG
                                                                object:nil
                                                              userInfo:nil];
            break;
        case FBSessionStateClosed:
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            [SVProgressHUD showErrorWithStatus:@"fb 登入失敗"];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification
                                                        object:session];
    
    if (error)
    {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"很抱歉"
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        alertView = nil;
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", nil];
    
    return [FBSession openActiveSessionWithPublishPermissions:permissions
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                                 allowLoginUI:allowLoginUI
                                            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                [self sessionStateChanged:session state:status error:error];
                                            }];
}

#pragma mark - my addition

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    //edited by kiki Huang 2014.01.12
    [[NSNotificationCenter defaultCenter] postNotificationName:RELIEVE_HOME_PRESENT object:nil];
	[self.window.rootViewController presentModalViewController:modalViewController animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
	[self.window.rootViewController dismissModalViewControllerAnimated:animated];
}

- (void)showSignInView
{
    //edited by kiki Huang 2014.01.17
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signPresent" object:nil];
    
    SignInViewController *signIn=[[[SignInViewController alloc] initWithNibName:@"SignInViewController"
                                                                         bundle:nil] autorelease];
    UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:signIn] autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self presentModalViewController:nav animated:YES];
}

- (void)showIntroductionView
{
    IntroductionViewController *signIn=[[[IntroductionViewController alloc] initWithNibName:@"IntroductionViewController" bundle:nil] autorelease];
    UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:signIn] autorelease];
    [nav.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self presentModalViewController:signIn animated:NO];
}

- (void)checkUpdate
{
    TaxiManager *manager = [TaxiManager sharedInstance];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSLog(@"%@  %@",manager.serverVersion,currentVersion);
    if(manager.serverVersion.length && manager.forceUpdate == YES)
    {
        if([manager.serverVersion isEqualToString:currentVersion] == NO)
        {
            NSString *msg = [NSString stringWithFormat:@"必須更新到(%@)才能使用\n您目前的版本為%@",
                             manager.serverVersion,
                             currentVersion];
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"版本更新"
                                                             message:msg
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"開啟 App Store 更新", nil] autorelease];
            alert.tag = VERSION_CHECK_ALERT;
            [alert show];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *storeURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://124.219.2.114/proxy/appstore.aspx"] encoding:NSUTF8StringEncoding error:nil];
                if(storeURL.length)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[TaxiManager sharedInstance] setAppStoreLink:storeURL];
                    });
            });
        }
    }
}

- (void)showPushMsg
{
    if (!isalertShow) {
        
        UIAlertView *alert;
        
        alert = [[[UIAlertView alloc] initWithTitle:@"台灣大車隊"
                                                         message:self.remoteNotifMsg
                                                        delegate:self
                                               cancelButtonTitle:@"確定"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        
        
        isalertShow = true;
        self.remoteNotifMsg = nil;
        
    }
    
}

- (void)processPush
{
#if !TARGET_IPHONE_SIMULATOR
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN];
    
    if(deviceToken.length == 0)
    {
        DDLogError(@"unable to register for push notifcation because token is empty");
        deviceToken = @"123";
        //return;
    }else
        NSLog(@"able to registe %@",deviceToken);
    
    // check if notification has been enabled/disabled
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	BOOL pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? YES : NO;
    TaxiManager *manager = [TaxiManager sharedInstance]; 
    
    [manager registerPushNotificationWithToken:deviceToken
                                   pushEnabled:pushAlert
                                       success:^{
                                           DDLogInfo(@"registering for push notifcation successful");
                                           [self checkUpdate];
                                       }
                                       failure:^(NSString *errorMessage, NSError *error) {
                                           [self showAlert:@"上傳資料失敗，請檢查網路狀態"];
                                           DDLogError(@"registering for push notifcation failed: %@", errorMessage);
                                       }];
    
#endif
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == VERSION_CHECK_ALERT)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[TaxiManager sharedInstance] appStoreLink]]];
    }
    isalertShow = false;
}

#pragma mark - IntroductionView delegate
//edited by kiki Huang 2013.12.22
-(void)changeToLoginView{
    RootViewController *rvc = [[RootViewController alloc] init];
    self.window.rootViewController = rvc;
    [rvc release];

}
-(void)showAlert:(NSString*)msg{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles: nil];
    [alert show];
    alert = nil;
}

-(BOOL) doesAlertViewExist {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if (alert || action)
                return YES;
        }
    }
    return NO;
}

-(NSDate*)StringToDate:(NSString *)str{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSLog(@"stringToDate %@", [formatter dateFromString:str]);
    return [formatter dateFromString:str];
}
@end
