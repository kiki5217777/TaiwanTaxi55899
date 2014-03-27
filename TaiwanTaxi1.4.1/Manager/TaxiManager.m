//
//  TaxiMananger.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "TaxiManager.h"
#import "AFNetworking.h"
#import "AFKissXMLRequestOperation.h"
#import "AFTaiwanTaxiAPIClient.h"
#import "AFCityTaxiAPIClient.h"

#import "DDXMLDocument.h"
#import "DDXMLElement.h"
#import "DDXMLElementAdditions.h"
#import "DDLog.h"

#import "NSString+helper.h"
#import "UIImage+Resize.h"

#import "OrderManager.h"
#import "Constants.h"
#import "UIImage+helper.h"
#import "ServiceManager.h"
#import "SVProgressHUD.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#import "AutoButtonManager.h"//kiki Huang
#import "AFHTTPRequestOperation.h"//kiki Huang

typedef void (^TaxiManagerGooglePlaceSuccessBlock)(NSArray *places);
typedef void (^TaxiManagerGooglePlaceFailureBlock)(NSString *reason, NSError *error);

NSString * const UPDATE_LOCATION_NOTIF = @"UPDATE_LOCATION_NOTIF";
NSString * const LOCATION_TRACKING_NOT_AVAIL_NOTIF = @"LOCATION_TRACKING_NOT_AVAIL_NOTIF";
NSString * const ERROR_UPDATE_LOCATION_NOTIF = @"ERROR_UPDATE_LOCATION_NOTIF";
NSString * const LOAD_SAVED_TRACK_NOTIF = @"LOAD_SAVED_TRACK_NOTIF";


static TaxiManager *singletonManager = nil;

@interface TaxiManager ()

@property (nonatomic, retain) AFHTTPClient                  * myClient;
@property (nonatomic, retain) NSDateFormatter               * dateFormatter;
@property (nonatomic, retain) OrderManager                  * orderManager;
@property (nonatomic, retain) NSString                      * landmarkSearchTerm;
@property (readwrite, nonatomic, copy) TaxiManagerGooglePlaceSuccessBlock placeSearchSuccess;
@property (readwrite, nonatomic, copy) TaxiManagerGooglePlaceFailureBlock placeSearchFailure;
@property (nonatomic, retain) AFHTTPClient                  * logClient;
@property (nonatomic, retain) NSNotificationCenter          * center;
@end

@implementation TaxiManager

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

// 訂車 Request 參數
#define XML_ROOT_STRING_TaxiOrder               @"<CoordinateSyncDispatchReq/>"
#define XML_ROOT_STRING_CancelOrder             @"<CancelJobReq/>"
#define XML_ROOT_STRING_Query                   @"<VehLocationReq/>"
#define XML_ROOT_STRING_Feedback                @"<SuccessFeedbackReq/>"
#define XML_KEY_DISID                           @"DISID"
#define XML_KEY_OCSType                         @"OCSType"
#define XML_KEY_OrderID                         @"OrderID"
#define XML_KEY_Phone                           @"Phone"
#define XML_KEY_CustName                        @"CustName"
#define XML_KEY_CustTitle                       @"CustTitle"
#define XML_KEY_CallType                        @"CallType"
#define XML_KEY_BookTime                        @"BookTime"
#define XML_KEY_Address                         @"Address"
#define XML_KEY_Lng_X                           @"Lng_X"
#define XML_KEY_Lat_Y                           @"Lat_Y"
#define XML_KEY_Landmark                        @"Landmark"
#define XML_KEY_Memo                            @"Memo"
#define XML_KEY_PaidType                        @"PaidType"
#define XML_KEY_SpecOrder                       @"SpecOrder"
#define XML_KEY_JobID                           @"JobID"
#define XML_KEY_CarNo                           @"CarNo"

#define XML_KEY_DISID_VALUE                     @"DIP"
#define XML_KEY_OCSType_VALUE                   @"DIP"
#define XML_KEY_CallType_VALUE                  @"0"

// 訂車 Response 參數
#define XML_KEY_RES_ReturnCode                  @"ReturnCode"
#define XML_KEY_RES_Exception                   @"Exception"
#define XML_KEY_RES_JobID                       @"JobID"
#define XML_KEY_RES_BookTime                    @"BookTime"
#define XML_KEY_RES_Effect                      @"Effect"
#define XML_KEY_RES_CarNo                       @"CarNo"
#define XML_KEY_RES_ETA                         @"ETA"

#define XML_KEY_RES_Lat_Y                       @"Lat_Y"
#define XML_KEY_RES_Lng_X                       @"Lng_X"


// 代碼表
#define XML_VALUE_ACTION_SUCCESSFUL             @"0000"
#define XML_VALUE_ACCOUNT_NOT_FOUND             @"0001"
#define XML_VALUE_INVALID_ACCOUNT               @"0002"
#define XML_VALUE_INVALID_XML                   @"0003"
#define XML_VALUE_INVALID_LOCATION_CODE         @"0004"
#define XML_VALUE_EXCEED_MAX_RSVP               @"0005"
#define XML_VALUE_IP_BANNED                     @"0006"
#define XML_VALUE_TIME_OUT                      @"0007"
#define XML_VALUE_CREATE_FAILED                 @"0008"
#define XML_VALUE_INVALID_ID                    @"0009"
#define XML_VALUE_ID_ALREADY_EXISTED            @"0010"
#define XML_VALUE_INVALID_TIME                  @"0011"
#define XML_VALUE_OTHER_ERROR                   @"9999"

#define XML_VALUE_EFFECT_SUCCESSFUL             @"0"
#define XML_VALUE_EFFECT_NO_CAR                 @"1"

// google map API return value
#define GOOGLE_API_CODE_OK                      @"OK"
#define GOOGLE_API_CODE_ZERO_RESULTS            @"ZERO_RESULTS"
#define GOOGLE_API_CODE_OVER_QUERY_LIMIT        @"OVER_QUERY_LIMIT"
#define GOOGLE_API_CODE_REQUEST_DENIED          @"REQUEST_DENIED"
#define GOOGLE_API_CODE_INVALID_REQUEST         @"INVALID_REQUEST"

#define BACK_END_API_TIMEOUT                    120
#define FEEDBACK_API_TIMEOUT                    10
#define FEEDBACK_API_RETRY_COUNT                3
#define TIMEOUT_MESSAGE                         @"連線逾時, 請稍後再試"
#define NO_CONNECTION_MESSAGE                   @"無法連線, 請稍後再試"

#define GOOGLE_API_KEY_OLD                      @"AIzaSyBaqfRt6-8Njxg9TNUa2jibU1a8gub2v5Q"
#define GOOGLE_API_KEY                          @"AIzaSyDQS5e3udWnep0364XgmNyaVzrCZ5Yx3dQ"

#pragma mark - synthesize

@synthesize myClient;
@synthesize dateFormatter;
@synthesize orderManager;
@synthesize locationManager;
@synthesize placeSearchSuccess;
@synthesize placeSearchFailure;
@synthesize userID;
@synthesize userPwd;
@synthesize userName;
@synthesize userTitle;
@synthesize userTel;
@synthesize userEmail;
@synthesize userJob;
@synthesize userBirthDay;
@synthesize userCard;
@synthesize currentOrderID;
@synthesize currentOrderCarNumber;
@synthesize currentOrderDate;
@synthesize adsDict;
@synthesize adImageCache;
@synthesize autoLogIn;
@synthesize landmarkSearchTerm;
@synthesize userIsMale;
@synthesize currentAppMode;
@synthesize json_base_url;
@synthesize xml_base_url;
@synthesize mini_site_url;
@synthesize currentAdImageIndex;
@synthesize logClient;
@synthesize devicePushToken;


- (OrderManager *)orderManager
{
    if(orderManager == nil){
        orderManager = [[OrderManager sharedInstance] retain];
    }
    
    return orderManager;
}

#pragma mark - dealloc

- (void)dealloc
{
    [myClient release];
    [dateFormatter release];
    [orderManager release];
    [locationManager release];
    [placeSearchSuccess release];
    [placeSearchFailure release];
    [userID release];
    [userPwd release];
    [userName release];
    [userTitle release];
    [userTel release];
    [userEmail release];
    [userJob release];
    [userBirthDay release];
    [userCard release];
    [currentOrderID release];
    [currentOrderCarNumber release];
    [_currentOrderXML release];
    [currentOrderDate release];
    [adImageCache release];
    [adsDict release];
    [landmarkSearchTerm release];
    [json_base_url release];
    [mini_site_url release];
    [xml_base_url release];
    [logClient release];
    [devicePushToken release];
    
    [super dealloc];
}

#pragma mark - init and setup

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setupBackendURLs
{
    self.backendURLsInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_BACKEND_URLS];
    NSLog(@"backendURL %@",self.backendURLsInfo);
    
    // production:http://124.219.2.114/proxy/config.aspx dev:http://124.219.2.117/proxy/config.aspx
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://124.219.2.114/proxy/config.aspx"]];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://124.219.2.117/proxy/config_test.aspx"]];
    
    if(data)
    {
        NSError *error = nil;
        NSDictionary *urls = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if(error == nil && urls)
        {
            self.backendURLsInfo = urls;
            [[NSUserDefaults standardUserDefaults] setObject:self.backendURLsInfo forKey:USER_DEFAULT_KEY_BACKEND_URLS];
        }
    }
}

- (void)setup
{
    [self setupBackendURLs];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.delegate = self;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.userID = [d stringForKey:USER_DEFAULT_KEY_USER_ID];
    self.userPwd = [d stringForKey:USER_DEFAULT_KEY_USER_PWD];
    self.isLogIn = [d boolForKey:USER_DEFAULT_KEY_IS_LOG_IN];
    self.autoLogIn = [d boolForKey:USER_DEFAULT_KEY_AUTO_LOG_IN];
    self.userName = [d stringForKey:USER_DEFAULT_KEY_USER_NAME];
    self.userTitle = [d stringForKey:USER_DEFAULT_KEY_USER_TITLE];
    self.userEmail = [d stringForKey:USER_DEFAULT_KEY_USER_EMAIL];
    self.userJob = [d stringForKey:USER_DEFAULT_KEY_USER_JOB];
    self.userBirthDay = [d stringForKey:USER_DEFAULT_KEY_USER_BIRTHDAY];
    self.userCard = [d stringForKey:USER_DEFAULT_KEY_USER_CARD];
    self.userIsMale = [d boolForKey:USER_DEFAULT_KEY_USER_IS_MALE];
    
    // we use the macro preprocessor in conjunction with target to set the app mode
#ifdef TAIWAN_TAXI_MODE
    self.currentAppMode = AppModeTWTaxi;
#endif
    
#ifdef CITY_TAXI_MODE
    self.currentAppMode = AppModeCityTaxi;
#endif
    
    self.devicePushToken = [d stringForKey:USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN];
    
    self.backendTimeout = BACK_END_API_TIMEOUT;
    
    [self configAppMode]; // important method
    
    isTrackingPath = NO;
    isGettingLandmarks = NO;
    isSearchingLandmarks = NO;
    isPreparingForBonus = NO;
    
    _center = [NSNotificationCenter defaultCenter];
    
    // setup the current taxi order to be the newest in db
    TaxiOrder *order = [self.orderManager getLastTaxiOrderIfExists];
    if(order)
    {
        self.currentOrderDate = order.createdDate;
        int status = order.orderStatus.intValue;
        double timeDiff = ABS([currentOrderDate timeIntervalSinceNow]);
        if(status == OrderStatusSubmittedSuccessful && timeDiff < TAXI_ORDER_VALID_DURATION)
        {
            self.currentOrderID = order.orderID;
            self.currentOrderCarNumber = order.carNumber;
            self.currentOrderETA = order.eta;
        }
    }
    
    // ads
    adImageCache = [[NSCache alloc] init];
    self.adsDict = [self loadAdInfoFromDisk];
    
    // log
    logClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://twtaxi-debug.appspot.com"]];
    
    // store link
    self.appStoreLink = DEFAULT_APP_STORE_LINK;
}

#pragma mark - user default related

- (void)saveUserInfo
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    if(self.userID.length)
        [df setObject:self.userID forKey:USER_DEFAULT_KEY_USER_ID];
    
    if(self.userPwd.length)
        [df setObject:self.userPwd forKey:USER_DEFAULT_KEY_USER_PWD];
    
    if(self.userName.length)
        [df setObject:self.userName forKey:USER_DEFAULT_KEY_USER_NAME];
    
    if(self.userTitle.length)
        [df setObject:self.userTitle forKey:USER_DEFAULT_KEY_USER_TITLE];
    
    if(self.userEmail.length)
        [df setObject:self.userEmail forKey:USER_DEFAULT_KEY_USER_EMAIL];
    
    if(self.userJob.length)
        [df setObject:self.userJob forKey:USER_DEFAULT_KEY_USER_JOB];
    
    if(self.userBirthDay.length)
        [df setObject:self.userBirthDay forKey:USER_DEFAULT_KEY_USER_BIRTHDAY];
    
    if(self.userCard.length)
        [df setObject:self.userCard forKey:USER_DEFAULT_KEY_USER_CARD];
    
    [df setBool:self.userIsMale forKey:USER_DEFAULT_KEY_USER_IS_MALE];
    [df setBool:self.isLogIn forKey:USER_DEFAULT_KEY_IS_LOG_IN];
    [df setBool:self.autoLogIn forKey:USER_DEFAULT_KEY_AUTO_LOG_IN];
    
    [df synchronize];
}

#pragma mark - taxi backend API

- (void)confirmTaxiOrder:(NSString *)orderID
                   count:(int)count
                 success:(void (^)())success
                 failure:(void (^)())failure
{
    TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
    
    if(order == nil)
    {
        if(failure)
            failure();
        
        return;
    }
    
    if(order.orderStatus.intValue == OrderStatusUserCancelled)
    {
        return;
    }
    
    // -------------------- preparing request object --------------------
    
    /*
     <?xml version="1.0" encoding="utf-8" ?>
     <SuccessFeedbackReq>
        <DISID>TaiwanTaxi</DISID>
        <OCSType>OCS</OCSType>
        <JobID>C110805ABCDE</JobID>
     </SuccessFeedbackReq>
     */
    
    // creating xml document
    DDXMLDocument* document = [[[DDXMLDocument alloc] initWithXMLString:XML_ROOT_STRING_Feedback options:0 error:nil] autorelease];
    DDXMLElement* root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_DISID         stringValue:XML_KEY_DISID_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_OCSType       stringValue:XML_KEY_OCSType_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_JobID         stringValue:order.jobID]];
    
    NSString *xmlString =[document.XMLString urlEncodedVersion];
    
    // creating request object
    NSString *baseURL = [NSString stringWithFormat:@"%@/Dispatch",self.xml_base_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:FEEDBACK_API_TIMEOUT];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"xml=%@", xmlString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    // -------------------- sending the request --------------------
    
    [self recordAppEventWithUser:self.userID
                             msg:@"Feedback send"
                            sent:[document.rootElement prettyXMLString]
                        received:nil
                          parent:nil];
	
    AFKissXMLRequestOperation *op = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             DDXMLElement *resultRoot = [XMLDocument rootElement];
                                             
                                             /*
                                              <?xml version="1.0" encoding="utf-8" ?> 
                                              <SuccessFeedbackRes>
                                                <ReturnCode>0000</ReturnCode>
                                              </SuccessFeedbackRes>
                                              */
                                             
                                             DDLogInfo(@"confirmTaxiOrder: %@", [resultRoot prettyXMLString]);
                                             [self recordAppEventWithUser:self.userID
                                                                      msg:@"Feedback received"
                                                                     sent:nil
                                                                 received:[resultRoot prettyXMLString]
                                                                   parent:nil];
                                             
                                             DDXMLElement *returnCode = [resultRoot elementForName:XML_KEY_RES_ReturnCode];
                                             
                                             if([returnCode.stringValue isEqualToString:XML_VALUE_ACTION_SUCCESSFUL] == YES)
                                             {
                                                 if(success)
                                                     success();
                                             }
                                             else
                                             {
                                                 if(count <= FEEDBACK_API_RETRY_COUNT)
                                                 {
                                                     [self confirmTaxiOrder:orderID
                                                                      count:count + 1
                                                                    success:success
                                                                    failure:failure];
                                                 }
                                                 else
                                                 {
                                                     if(failure)
                                                         failure();
                                                 }
                                             }
                                         });
                                         
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
                                         
                                         if(count <= FEEDBACK_API_RETRY_COUNT)
                                         {
                                             [self confirmTaxiOrder:orderID
                                                              count:count + 1
                                                            success:success
                                                            failure:failure];
                                         }
                                         else
                                         {
                                             if(failure)
                                                 failure();
                                         }
                                     }];
    [op start];
}

- (void)submitTaxiOrder:(NSString *)orderID
                success:(void (^)())success 
                failure:(void (^)())failure
{
    TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
    
    if(order == nil)
    {
        if(failure)
            failure();
        
        return;
    }
    
    if(order.orderStatus.intValue == OrderStatusUserCancelled)
    {
        return;
    }
    
    // -------------------- preparing request object --------------------
    
    // creating xml document
    DDXMLDocument* document = [[[DDXMLDocument alloc] initWithXMLString:XML_ROOT_STRING_TaxiOrder options:0 error:nil] autorelease];
    DDXMLElement* root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_DISID         stringValue:XML_KEY_DISID_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_OCSType       stringValue:XML_KEY_OCSType_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_OrderID       stringValue:order.orderID]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Phone         stringValue:order.customerInfo.tel]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_CustName      stringValue:order.customerInfo.name]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_CustTitle     stringValue:order.customerInfo.title]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_CallType      stringValue:order.callType.stringValue]];
    
    NSString *formattedTimeString=[dateFormatter stringFromDate:order.bookTime];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_BookTime      stringValue:formattedTimeString]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Address       stringValue:order.pickupInfo.formattedAddress]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Lng_X         stringValue:order.pickupInfo.lon.stringValue]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Lat_Y         stringValue:order.pickupInfo.lat.stringValue]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Landmark      stringValue:order.pickupInfo.landmark]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Memo          stringValue:order.orderInfo.memo]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_PaidType      stringValue:order.orderInfo.paidType.stringValue]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_SpecOrder     stringValue:order.orderInfo.specOrder]];
    
    // we are going to change to status just before the actual submission
    order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmitted];
    self.currentOrderID = orderID;
    self.currentOrderDate = [NSDate date];
    [self.orderManager save];
    
    NSString *xmlString =[document.XMLString urlEncodedVersion];
    
    // creating request object
    NSString *baseURL = [NSString stringWithFormat:@"%@/Dispatch",self.xml_base_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:self.backendTimeout];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"xml=%@", xmlString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    // -------------------- sending the request --------------------
    
    self.currentOrderKey = nil;
    self.currentOrderXML = [document.rootElement prettyXMLString];
    
    [self recordAppEventWithUser:self.userID
                             msg:@"Dispatch send"
                            sent:self.currentOrderXML
                        received:nil
                          parent:nil];
	
    AFKissXMLRequestOperation *op = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
            
            DDXMLElement *resultRoot = [XMLDocument rootElement];
            
            /*
             <ReturnCode>0000</ReturnCode>
             <JobID>C120912A000O</JobID>
             <Effect>0</Effect>
             <CarNo>55555</CarNo>
             <ETA>3</ETA>
             */
            
            DDLogInfo(@"submitTaxiOrder: %@", [resultRoot prettyXMLString]);
            [self recordAppEventWithUser:self.userID
                                     msg:@"Dispatch received"
                                    sent:nil
                                received:[resultRoot prettyXMLString]
                                  parent:nil];
            
            DDXMLElement *returnCode =      [resultRoot elementForName:XML_KEY_RES_ReturnCode];
            DDXMLElement *exception =       [resultRoot elementForName:XML_KEY_RES_Exception];
            DDXMLElement *jobID =           [resultRoot elementForName:XML_KEY_RES_JobID];
            DDXMLElement *bookTime =        [resultRoot elementForName:XML_KEY_RES_BookTime];
            DDXMLElement *effect =          [resultRoot elementForName:XML_KEY_RES_Effect];
            DDXMLElement *carNo =           [resultRoot elementForName:XML_KEY_RES_CarNo];
            DDXMLElement *ETA =             [resultRoot elementForName:XML_KEY_RES_ETA];
            
            if(order.orderStatus.intValue == OrderStatusUserCancelled)
            {
                DDLogInfo(@"submitTaxiOrder: user canceled");
                
                //modified by kiki Huang 2014.01.12
                if (![[NSUserDefaults standardUserDefaults]valueForKey:@"currentOrderID"]) {
                    self.currentOrderID = nil;
                    self.currentOrderDate = nil;
                    self.currentOrderCarNumber = nil;
                    self.currentOrderETA = nil;
                }
                [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                return;
            }
            
            if([returnCode.stringValue isEqualToString:XML_VALUE_ACTION_SUCCESSFUL] == YES)
            {
                if([effect.stringValue isEqualToString:XML_VALUE_EFFECT_SUCCESSFUL] == YES)
                {
                    
                    //modified by kiki Huang 2014.01.12
                    [self.center postNotificationName:@"order process" object:nil];
                    
                    
                    order.effect = [NSNumber numberWithInt:0];
                    order.jobID = jobID.stringValue;
                    order.bookTime = [dateFormatter dateFromString:bookTime.stringValue];
                    order.carNumber = carNo.stringValue;
                    order.eta = ETA.stringValue;
                    [self.orderManager save];
                    
                    [self confirmTaxiOrder:orderID count:1 success:^{
                        
                        TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
                        order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedSuccessful];
                        self.currentOrderDate = [NSDate date];
                        self.currentOrderCarNumber = carNo.stringValue;
                        self.currentOrderETA = ETA.stringValue;
                        [self.orderManager save];
                        
                        [self.center postNotificationName:ORDER_SUCCEEDED_NOTIFICATION
                                                   object:nil
                                                 userInfo:nil];
                        
                        if(success)
                            success();
                        
                    } failure:^{
                        
                        TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
                        order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedFailure];
                        order.effect = [NSNumber numberWithInt:1];
                        order.jobID = jobID.stringValue;
                        order.exception = exception.stringValue;
                        
                        //modified by kiki Huang 2014.01.12
                        if (![[NSUserDefaults standardUserDefaults]valueForKey:@"currentOrderID"]) {
                            self.currentOrderID = nil;
                            self.currentOrderDate = nil;
                            self.currentOrderCarNumber = nil;
                            self.currentOrderETA = nil;
                        }
                       
                        [self.orderManager save];
                        
                        if(failure)
                            failure();
                    }]; 
                }
                else
                {
                    order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedFailure];
                    order.effect = [NSNumber numberWithInt:1];
                    order.jobID = jobID.stringValue;
                    order.exception = exception.stringValue;
                    
                    //modified by kiki Huang 2014.01.12
                    if (![[NSUserDefaults standardUserDefaults]valueForKey:@"currentOrderID"]) {
                        self.currentOrderID = nil;
                        self.currentOrderDate = nil;
                        self.currentOrderCarNumber = nil;
                        self.currentOrderETA = nil;
                        
                    }
                    [self.orderManager save];
                    if(failure)
                        failure();
                }
            }
            else
            {
                order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedFailure];
                order.jobID = jobID.stringValue;
                order.exception = exception.stringValue;
                
                //modified by kiki Huang 2014.01.12
                if (![[NSUserDefaults standardUserDefaults]valueForKey:@"currentOrderID"]) {
                    self.currentOrderID = nil;
                    self.currentOrderDate = nil;
                    self.currentOrderCarNumber = nil;
                    self.currentOrderETA = nil;
                }
               
                [self.orderManager save];
                
                if(failure)
                    failure();
            }
        });
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        
        TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
        order.orderStatus = [NSNumber numberWithInt:OrderStatusSubmittedFailure];
        order.exception = error.description;
        
        //modified by kiki Huang 2014.01.12
        if (![[NSUserDefaults standardUserDefaults]valueForKey:@"currentOrderID"]){
            self.currentOrderID = nil;
            self.currentOrderDate = nil;
            self.currentOrderCarNumber = nil;
            self.currentOrderETA = nil;
        }
       
        [self.orderManager save];
        
        [self recordAppEventWithUser:self.userID
                                 msg:[NSString stringWithFormat:@"Dispatch sent failed: %@", error.description]
                                sent:nil
                            received:nil
                              parent:nil];
        if(failure)
            failure();
    }];
    
    [op setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    [op start];
}

//modified by kiki Huang 2014.01.12
- (void)cancelTaxiOrderWithBlock:(NSString *)orderID success:(void(^)())success failure:(void(^)())failure
{
//    [self.center postNotificationName:ORDER_CANCELLED_NOTIFICATION
//                               object:nil
//                             userInfo:nil];
    
    
    TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
    NSLog(@"order %@",order.orderID);
    
    if(order == nil)
    {
        return;
    }
    
//    self.currentOrderID = nil;
//    self.currentOrderCarNumber = nil;
//    self.currentOrderDate = nil;
//    self.currentOrderETA = nil;
    
    order.orderStatus = [NSNumber numberWithInt:OrderStatusUserCancelled];
    [self.orderManager save];
    
    if(order.jobID.length == 0)
    {
        return;
    }
    
    // -------------------- preparing request object --------------------
    
    /*
     <CancelJobReq>
        <DISID>DIP</DISID>
        <OCSType>DIP</OCSType>
        <JobID>C110805ABCDE</JobID>
     </CancelJobReq>
     */
    
    // creating xml document
    DDXMLDocument* document = [[[DDXMLDocument alloc] initWithXMLString:XML_ROOT_STRING_CancelOrder options:0 error:nil] autorelease];
    DDXMLElement* root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_DISID         stringValue:XML_KEY_DISID_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_OCSType       stringValue:XML_KEY_OCSType_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_JobID         stringValue:order.jobID]];
    
    NSString *xmlString =[document.XMLString urlEncodedVersion];
    
    // creating request object
    NSString *baseURL = [NSString stringWithFormat:@"%@/Dispatch",self.xml_base_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:self.backendTimeout];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"xml=%@", xmlString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    // -------------------- sending the request --------------------
    
    
    [self recordAppEventWithUser:self.userID
                             msg:@"Dispatch cancel sent"
                            sent:[root prettyXMLString]
                        received:nil
                          parent:nil];
    
    AFKissXMLRequestOperation *op = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
    
        TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
        
        DDXMLElement *resultRoot = [XMLDocument rootElement];
        
        DDLogInfo(@"cancelTaxiOrder: %@", [resultRoot prettyXMLString]);
        [self recordAppEventWithUser:self.userID
                                 msg:@"Dispatch cancel received"
                                sent:nil
                            received:[resultRoot prettyXMLString]
                              parent:nil];
         NSLog(@"%@", [resultRoot prettyXMLString]);
        // successful
        /*
         <?xml version="1.0" encoding="utf-8" ?>
         <CancelJobRes>
            <JobID>C110805ABCDE</JobIDID>
            <ReturnCode>0000</ReturnCode> 
         </CancelJobRes>
         */
        
        // failure
        /*
         <?xml version="1.0" encoding="utf-8" ?> 
         <CancelJobRes>
            <JobID>C110805ABCDE</JobIDID>
            <ReturnCode>0009</ReturnCode> 
         </CancelJobRes>
         */
        
        DDXMLElement *returnCode =      [resultRoot elementForName:XML_KEY_RES_ReturnCode];
        
        if([returnCode.stringValue isEqualToString:XML_VALUE_ACTION_SUCCESSFUL] == YES)
        {
            order.orderStatus = [NSNumber numberWithInt:OrderStatusUserCancelledSuccessful];
            NSLog(@"%@",order.orderStatus);
            [self.orderManager save];
            
            //modified by kiki Huang 2014.01.12
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"currentOrderID"];
            
            self.currentOrderID = nil;
            self.currentOrderCarNumber = nil;
            self.currentOrderDate = nil;
            self.currentOrderETA = nil;
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_TAXI_ANNOTATION object:nil];
            
            [self.center postNotificationName:ORDER_CANCELLED_NOTIFICATION
                                       object:nil
                                     userInfo:nil];

            
            if (success) {
                success();
            }
        }
        else
        {
            NSLog(@"order %@",order.orderID);
            order.orderStatus = [NSNumber numberWithInt:OrderStatusUserCancelledFailure];
            [self.orderManager save];
            NSLog(@"order %@",order.orderID);
            if (failure) {
                failure();
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        
        TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
        NSLog(@"order %@",order.orderID);
        order.orderStatus = [NSNumber numberWithInt:OrderStatusUserCancelledFailure];
        [self.orderManager save];
        NSLog(@"order %@",order.orderID);
        if (failure) {
            failure();
        }
    }];
    
    [op start];
}

- (void)getTaxiPositionForTaxiOrder:(NSString *)orderID
                            success:(void (^)(double lat, double lon))success
                            failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
    
    if(order == nil)
    {
        if(failure)
            failure(@"目前沒有叫車記錄喔", nil);
    }
    
    // -------------------- preparing request object --------------------
    
    /*
     <VehLocationReq>
        <DISID>DIP</DISID>
        <OCSType>DIP</OCSType>
        <Phone>0912345678</Phone>
        <JobID>C110805ABCDE</JobID> 
        <CarNo>1234</CarNo>
     </VehLocationReq>
     */
    
    // creating xml document
    DDXMLDocument* document = [[[DDXMLDocument alloc] initWithXMLString:XML_ROOT_STRING_Query options:0 error:nil] autorelease];
    DDXMLElement* root = [document rootElement];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_DISID         stringValue:XML_KEY_DISID_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_OCSType       stringValue:XML_KEY_OCSType_VALUE]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_Phone         stringValue:order.customerInfo.tel]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_JobID         stringValue:order.jobID]];
    [root addChild:[DDXMLNode elementWithName:XML_KEY_CarNo         stringValue:order.carNumber]];
    
    NSString *xmlString =[document.XMLString urlEncodedVersion];
    
    // creating request object
    NSString *baseURL = [NSString stringWithFormat:@"%@/Query", self.xml_base_url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:self.backendTimeout];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"xml=%@", xmlString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    // -------------------- sending the request --------------------
    
    [self recordAppEventWithUser:self.userID
                             msg:@"Query taxi sent"
                            sent:[root prettyXMLString]
                        received:nil
                          parent:nil];
	
    AFKissXMLRequestOperation *op = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
        
        DDXMLElement *resultRoot = [XMLDocument rootElement];
        
        // successful
        /*
         <?xml version="1.0" encoding="utf-8" ?>
         <VehLocationRes>
            <Lng_X>121.46786000</Lng_X >
            <Lat_Y>25.04577600</Lat_Y >
            <ReturnCode>0000</ReturnCode>
         </VehLocationRes>
         */
        
        [self recordAppEventWithUser:self.userID
                                 msg:@"Query taxi received"
                                sent:nil
                            received:[resultRoot prettyXMLString]
                              parent:nil];
        
        DDXMLElement *returnCode = [resultRoot elementForName:XML_KEY_RES_ReturnCode];
        
        if([returnCode.stringValue isEqualToString:XML_VALUE_ACTION_SUCCESSFUL] == YES)
        {
            DDXMLElement *lat = [resultRoot elementForName:XML_KEY_RES_Lat_Y];
            DDXMLElement *lon = [resultRoot elementForName:XML_KEY_RES_Lng_X];
            
            if(success)
                success(lat.stringValue.doubleValue, lon.stringValue.doubleValue);
        }
        else
        {
            if(failure)
                failure(@"很抱歉, 目前無法提供位置", nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        
        if(failure)
            failure(@"很抱歉, 目前無法提供位置", nil);
    }];
    
    [op start];
}

#pragma mark - taiwan taxi json API

- (void)logInWithUserID:(NSString *)uID
                    pwd:(NSString *)pwd
                success:(void (^)())success
                failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0 || pwd.length == 0)
    {
        if(failure)
            failure(@"請輸入帳號/密碼", nil);
        return;
    }
    
    self.userID = uID;
    self.userPwd = pwd;
    
    [myClient postPath:LOG_IN_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys: uID, LOG_IN_API_KEY_username, pwd, LOG_IN_API_KEY_password, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
    {
        NSLog(@"login allHeader %@",[operation.response allHeaderFields]);
        NSLog(@"login Cookie %@", [[operation.response allHeaderFields] objectForKey:@"Set-Cookie"]);
        NSString *cookie = [[operation.response allHeaderFields] objectForKey:@"Set-Cookie"];
        if ([cookie rangeOfString:@";"].location !=NSNotFound) {
            cookie = [cookie substringWithRange:NSMakeRange(0, [cookie rangeOfString:@";"].location)];
        }
        NSLog(@"cookie %@",cookie);
        [[NSUserDefaults standardUserDefaults]setObject:cookie forKey:@"sessionCookies"];
//        [self saveCookies];
//        [self loadCookies];
//        [[NSUserDefaults standardUserDefaults]setObject:[[operation.response allHeaderFields] objectForKey:@"Set-Cookie"] forKey:@"Cookie"];
        DDLogInfo(@"LOG_IN_API_PATH: %@", JSON);
        
        NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
        
        // code:
        // 1 登入/驗證碼成功，且已通過驗證碼驗證。
        // 2 註冊/登入成功，但仍需驗證碼驗證。(*)
        // 3 登入失敗，會員不存在或密碼有誤。
        
        if(status.boolValue == YES)
        {
            NSDictionary *rsp = [JSON objectForKey:JSON_API_KEY_rsp];
            
            NSString *custName = @"";
            NSString *custTitle = @"";
            NSString *custEmail = @"";
            NSString *custJob = @"";
            NSString *custBirthday = @"";
            NSString *custCard = @"";
            
            if([[rsp objectForKey:LOG_IN_API_KEY_CUSTNAME] isKindOfClass:[NSNull class]] == NO)
                custName = [rsp objectForKey:LOG_IN_API_KEY_CUSTNAME];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_CUSTTITLE] isKindOfClass:[NSNull class]] == NO)
                custTitle = [rsp objectForKey:LOG_IN_API_KEY_CUSTTITLE];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_EMAIL] isKindOfClass:[NSNull class]] == NO)
                custEmail = [rsp objectForKey:LOG_IN_API_KEY_EMAIL];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_CAREER] isKindOfClass:[NSNull class]] == NO)
                custJob = [rsp objectForKey:LOG_IN_API_KEY_CAREER];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_BIRTHDAY] isKindOfClass:[NSNull class]] == NO)
                custBirthday = [rsp objectForKey:LOG_IN_API_KEY_BIRTHDAY];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_CARD] isKindOfClass:[NSNull class]] == NO)
                custCard = [rsp objectForKey:LOG_IN_API_KEY_CARD];
            
            if([[rsp objectForKey:LOG_IN_API_KEY_TIMEOUT] isKindOfClass:[NSNull class]] == NO)
                self.backendTimeout = [[rsp objectForKey:LOG_IN_API_KEY_TIMEOUT] integerValue];
            
            self.userName = custName;
            self.userTitle = custTitle;
            self.userEmail = custEmail;
            self.userBirthDay = custBirthday;
            self.userJob = custJob;
            self.isLogIn = YES;
            self.userTel = uID;
            self.userCard = custCard;
            if(self.userTitle.length)
            {
                NSRange notFound = NSMakeRange(NSNotFound, 0);
                if(NSEqualRanges([self.userTitle rangeOfString:@"先生"], notFound) == YES)
                {
                    self.userIsMale = NO;
                }
                else
                {
                    self.userIsMale = YES;
                }
            }
            
            [self saveUserInfo];
            
            [self.center postNotificationName:SIGN_IN_SUCCESS_NOTIFICATION
                                       object:self];
            
            if(success)
                success();
        }
        else
        {
            NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
            self.isLogIn = NO;
            
            if(failure)
                failure(msg, nil);
        }
        
    }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if(failure)
            failure(@"登入失敗", error);
    }];
}

- (void)getBonusWithUserID:(NSString *)uID
                   success:(void (^)())success
                   failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    
    NSString *baseURL = [NSString stringWithFormat:@"http://bonus.taiwantaxi.com.tw/Taiwantaxi/doQUERY_BONUS.do?CUSTACCT=%@", uID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:self.backendTimeout];
	[request setHTTPMethod:@"GET"];
    
    
    
    AFKissXMLRequestOperation *op = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request
                                                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument)
                                     
                                     {
                                         DDXMLElement *resultRoot = [XMLDocument rootElement];
                                         DDXMLElement *bonus = [resultRoot elementForName:@"BOUND"];
                                         self.bonusValue = bonus.stringValue;
                                         
                                         DDXMLElement *test = [resultRoot elementForName:@"OVER_DATE"];
                                         self.overDate = test.stringValue;//edited by kiki Huang 2013.12.09
//                                        NSLog(@"%@", test.stringValue);
                                         DDXMLElement *test1 = [resultRoot elementForName:@"OVER_BOUND"];
                                         self.bonusOverDate = test1.stringValue;//edited by kiki Huang 2013.12.09
//                                         NSLog(@"%@", test1.stringValue);
                                         
                                         
                                         if(success)
                                             success();
                                         
                                         
                                     }
                                                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument)
                                     {
                                         DDLogInfo(@"getBonus: 失敗");
                                         if(failure)
                                             failure(@"登入失敗", error);
                                     }];
    
    [op start];
}

- (void)registerAccountWithID:(NSString *)uID
                          pwd:(NSString *)pwd
                         name:(NSString *)name
                        title:(NSString *)title
                     birthday:(NSString *)birthday
                        email:(NSString *)email
                       career:(NSString *)career
                         ages:(NSString *)ages
                         card:(NSString *)card
                      success:(void (^)(int code))success
                      failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0 || pwd.length == 0 || name.length == 0
       || birthday.length == 0 || email.length == 0)
    {
        if(failure)
            failure(5, @"請輸入完整資訊", nil);
        
        return;
    }
    
    self.userID = uID;
    self.userPwd = pwd;
    NSString *type = @"是";
    NSString *model = @"15";
    
    [myClient postPath:REGISTER_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        uID,        REGISTER_API_CUSTACCT,
                        pwd,        REGISTER_API_CUSTPIN,
                        name,       REGISTER_API_CUSTNAME,
                        title,      REGISTER_API_CUSTTITLE,
                        birthday,   REGISTER_API_BIRTHDAY,
                        ages,       REGISTER_API_AGES,
                        email,      REGISTER_API_EMAIL,
                        career,     REGISTER_API_CAREER,
                        type,       REGISTER_API_PHONETYPE,
                        model,      REGISTER_API_PHONEMODEL,
                        uID,        REGISTER_API_CUSTTEL1,
                        uID,        REGISTER_API_CUSTTEL2,
                        card,       REGISTER_API_CREDIT, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"REGISTER_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         NSNumber *code = [JSON objectForKey:JSON_API_KEY_code];
         
         if(status.boolValue == YES)
         {
             if(success)
                 success(code.intValue);
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(code.intValue, msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(-1, @"後台發生錯誤", error);
     }];
}

- (void)updateAccountWithID:(NSString *)uID
                        pwd:(NSString *)newPwd
                       name:(NSString *)name
                      title:(NSString *)title
                   birthday:(NSString *)birthday
                      email:(NSString *)email
                     career:(NSString *)career
                       ages:(NSString *)ages
                       card:(NSString *)card
                     isMale:(BOOL)isMale
                    success:(void (^)(int code))success
                    failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0 || newPwd.length == 0 || name.length == 0
       || birthday.length == 0 || email.length == 0)
    {
        if(failure)
            failure(5, @"請輸入完整資訊", nil);
        
        return;
    }
    
    [self logInWithUserID:self.userID pwd:self.userPwd success:^{
        
        NSString *pwd = self.userPwd;
        
        NSString *type = @"Y";
        NSString *model = @"15";
        
        [myClient postPath:UPDATE_USER_API_PATH
                parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                            uID,        UPDATE_USER_API_CUSTACCT,
                            pwd,        UPDATE_USER_API_CUSTPIN,
                            newPwd,     UPDATE_USER_API_NEWCUSTPIN,
                            name,       UPDATE_USER_API_CUSTNAME,
                            title,      UPDATE_USER_API_CUSTTITLE,
                            birthday,   UPDATE_USER_API_BIRTHDAY,
                            ages,       UPDATE_USER_API_AGES,
                            email,      UPDATE_USER_API_EMAIL,
                            career,     UPDATE_USER_API_CAREER,
                            type,       UPDATE_USER_API_PHONETYPE,
                            model,      UPDATE_USER_API_PHONEMODEL,
                            uID,        UPDATE_USER_API_CUSTTEL1,
                            uID,        UPDATE_USER_API_CUSTTEL2,
                            card,       UPDATE_USER_API_CREDIT, nil]
                   success:^(AFHTTPRequestOperation *operation, id JSON)
         {
             DDLogInfo(@"UPDATE_USER_API_PATH: %@", JSON);
             
             NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
             NSNumber *code = [JSON objectForKey:JSON_API_KEY_code];
             
             if(status.boolValue == YES)
             {
                 self.userID = uID;
                 self.userPwd = newPwd;
                 self.userName = name;
                 self.userTitle = title;
                 self.userBirthDay = birthday;
                 self.userEmail = email;
                 self.userJob = career;
                 self.userCard = card;
                 self.userIsMale = isMale;
                 
                 [self saveUserInfo];
                 
                 [self.center postNotificationName:ORDER_CANCELLED_NOTIFICATION
                                            object:nil
                                          userInfo:nil];
                 
                 if(success)
                     success(code.intValue);
             }
             else
             {
                 NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
                 
                 if(failure)
                     failure(code.intValue, msg, nil);
             }
             
         }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(failure)
                 failure(-1, @"系統發生錯誤, 請稍後再試", error);
         }];
        
    } failure:^(NSString *errorMessage, NSError *error) {
        if(failure)
            failure(9999, errorMessage, error);
    }];
}

- (void)performOTPWith:(NSString *)uID
                  code:(NSString *)code
               success:(void (^)(int code))success
               failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0 || code.length == 0)
    {
        if(failure)
            failure(5, @"請輸入完整資訊", nil);
        
        return;
    }
    
    [myClient postPath:CHECKAUTH_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        uID,        CHECKAUTH_API_username,
                        code,       CHECKAUTH_API_authcode, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"CHECKAUTH_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         NSNumber *code = [JSON objectForKey:JSON_API_KEY_code];
         
         if(status.boolValue == YES)
         {
             if(success)
                 success(code.intValue);
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(code.intValue, msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(-1, @"後台發生錯誤", error);
     }];
}

- (void)requestOTPCode:(NSString *)uID
               success:(void (^)(int code))success
               failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0)
    {
        if(failure)
            failure(5, @"請輸入完整資訊", nil);
        
        return;
    }
    
    [myClient postPath:REAUTHCODE_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        uID,        REAUTHCODE_API_username, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"REAUTHCODE_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         NSNumber *code = [JSON objectForKey:JSON_API_KEY_code];
         
         if(status.boolValue == YES)
         {
             if(success)
                 success(code.intValue);
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(code.intValue, msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(-1, @"後台發生錯誤", error);
     }];
}

- (void)forgetPassword:(NSString *)uID
               success:(void (^)())success
               failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    if(uID.length == 0)
    {
        if(failure)
            failure(@"請輸入完整資訊", nil);
        
        return;
    }
    
    [myClient postPath:FORGET_PASSWORD_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        uID,        FORGET_PASSWORD_KEY_account
                        , nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"FORGET_PASSWORD_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         if(status.boolValue == YES)
         {
             if(success)
                 success();
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"後台發生錯誤", error);
     }];
}

- (void)registerPushNotificationWithToken:(NSString *)token
                              pushEnabled:(BOOL)isEnabled
                                  success:(void (^)())success
                                  failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    if(token.length == 0)
    {
        if(failure)
            failure(@"device token 不得為空白", nil);
        
        return;
    }else
        NSLog(@"token get%@",token);
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *systemVerion = [[UIDevice currentDevice] systemVersion];
    NSString *enableFlag = isEnabled ? @"true" : @"false";
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_USER_ID];
    
    // in case user has not logged in before
//    if(userId.length == 0)
//        userId = token;
    
    NSString *imei = @"123";
    if(token.length > 50)
        imei = [token substringToIndex:50];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           imei,                                       PUSH_API_KEY_imei,
                           @"2",                                       PUSH_API_KEY_platform,
                           systemVerion,                               PUSH_API_KEY_osversion,
                           appVersion,                                 PUSH_API_KEY_appversion,
                           userId,                                     PUSH_API_KEY_phone,
                           token,                                      PUSH_API_KEY_token,
                           enableFlag,                                 PUSH_API_KEY_enable,nil];
    NSLog(@"para %@",param);

//    [AFTaiwanTaxiAPIClient sharedClient:self.json_base_url];
    
    //modified by kiki Huang 2014.01.17
//    AFHTTPClient *pushClent = [AFCityTaxiAPIClient sharedClient:@"http://124.219.5.40"];
    [myClient postPath:PUSH_API_PATH
            parameters:param
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"PUSH_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         if(status.boolValue == YES)
         {
             NSDictionary *rsp = [JSON objectForKey:JSON_API_KEY_rsp];
             
             if([[rsp objectForKey:PUSH_API_KEY_career] isKindOfClass:[NSNull class]] == NO)
             {
                 self.occpuationChoices = [rsp objectForKey:PUSH_API_KEY_career];
//                 NSLog(@"kkk %@",self.occpuationChoices);
                 for (NSString *str in self.occpuationChoices.allKeys) {
                     NSLog(@"qq%@",[self.occpuationChoices objectForKey:str]);
                 }
                 
             }
             if ([[rsp objectForKey:@"ages"] isKindOfClass:[NSNull class]] == NO) {
                 NSDictionary *ages = [rsp objectForKey:@"ages"];
                 for (NSString *str in ages) {
                     NSLog(@"str %@",[ages objectForKey:str]);
                 }
             }
             if([[rsp objectForKey:PUSH_API_KEY_credit] isKindOfClass:[NSNull class]] == NO)
             {
                 self.creditCardChoices = [rsp objectForKey:PUSH_API_KEY_credit];
             }
             
             if([[rsp objectForKey:PUSH_API_KEY_update] isKindOfClass:[NSNull class]] == NO)
             {
                 self.forceUpdate = [[rsp objectForKey:PUSH_API_KEY_update] boolValue];

             }
             
             if([[rsp objectForKey:PUSH_API_KEY_ver] isKindOfClass:[NSNull class]] == NO)
             {
                 self.serverVersion = [rsp objectForKey:PUSH_API_KEY_ver];
            
             }
             
             if(success)
                 success();
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure){
                 NSLog(@"error:%@",msg);
                 failure(msg, nil);
             }
             
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"傳送失敗", error);
     }];
    
    
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
//    NSString *baseUrl;
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
//        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
//    }else
//        baseUrl = nil;
    
//    AFHTTPClient *pushClient;
//    pushClient = [AFCityTaxiAPIClient sharedPushClient:nil];
//    NSDictionary* _registerData = [NSDictionary dictionaryWithObjectsAndKeys:[UIDevice currentDevice].name, @"name", token, @"token", @"i", @"type",nil];
//    NSLog(@"_registerData%@",_registerData);
//    
//    [pushClient getPath:TAXI_PUSH_URL_SESSION parameters:_registerData success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"push_return %@",[[[NSString alloc] initWithData:responseObject
//                                                       encoding:NSUTF8StringEncoding] autorelease]);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"push error %@",error);
//    }];
    
}

- (void)sendTaxiOrderEvaluation:(NSString *)orderID
                        success:(void (^)())success
                        failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
    
    if(order == nil)
    {
        if(failure)
            failure(@"找不到乘車記錄", nil);
        
        return;
    }
    
    order.reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusSubmitted];
    [orderManager save];
    
    NSString *address = order.pickupInfo.fullAddress;
    NSString *teamid = order.carNumber;
    NSNumber *rate = order.reviewInfo.rating;
    NSString *note = order.reviewInfo.note;
    NSString *takenDate = [self.dateFormatter stringFromDate:order.createdDate];
    
    if(teamid.length == 0)
        teamid = @"1234";
    
    [myClient postPath:EVALUATE_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        address, EVALUATE_API_KEY_address,
                        teamid, EVALUATE_API_KEY_teamid,
                        rate, EVALUATE_API_KEY_rate,
                        note, EVALUATE_API_KEY_note,
                        takenDate, EVALUATE_API_KEY_takenDate, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"EVALUATE_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         TaxiOrder *order = [self.orderManager getOrderIfExistWithOrderID:orderID];
         
         
         if(status.boolValue == YES)
         {
             order.reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusSubmittedSuccessful];
             [orderManager save];
             
             if(success)
                 success();
         }
         else
         {
             order.reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusSubmittedFailure];
             [orderManager save];
             
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         order.reviewInfo.submitStatus = [NSNumber numberWithInt:ReviewStatusSubmittedFailure];
         [orderManager save];
         
         if(failure)
             failure(@"傳送失敗, 請稍後再試", error);
     }];
}

- (void)sendSuggestionWithName:(NSString *)name
                           tel:(NSString *)tel
                         email:(NSString *)email
                       context:(NSString *)context
                       success:(void (^)())success
                       failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    if(context.length == 0)
    {
        if(failure)
            failure(@"請輸入意見內容", nil);
    }
    
    if(name.length == 0)
        name = @"匿名";
    
    if(tel.length == 0)
        tel = @"沒有提供";
    
    if(email.length == 0)
        email = @"沒有提供";
    
    [myClient postPath:SUGGESTION_API_PATH
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        name, SUGGESTION_API_KEY_name,
                        tel, SUGGESTION_API_KEY_phone,
                        email, SUGGESTION_API_KEY_email,
                        context, SUGGESTION_API_KEY_context, nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"SUGGESTION_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         if(status.boolValue == YES)
         {
             if(success)
                 success();
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(msg, nil);
         }
         
     }
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"傳送失敗", error);
     }];
}



- (void)retrieveFBInfoSuccess:(void (^)())success
                      failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    [myClient getPath:FBINFO_API_PATH
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"FBINFO_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         if(status.boolValue == YES)
         {
             NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
             
             NSDictionary *rsp = [JSON objectForKey:JSON_API_KEY_rsp];
             
             NSString *title = [rsp objectForKey:FBINFO_API_KEY_title];
             if(title.length)
                 [df setObject:title forKey:USER_DEFAULT_KEY_FB_TITLE];
             
             NSString *description = [rsp objectForKey:FBINFO_API_KEY_description];
             if(description.length)
                 [df setObject:description forKey:USER_DEFAULT_KEY_FB_DESCRIPTION];
             
             NSString *link = [rsp objectForKey:FBINFO_API_KEY_link];
             if(link.length)
                 [df setObject:link forKey:USER_DEFAULT_KEY_FB_LINK];
             
             NSString *image = [rsp objectForKey:FBINFO_API_KEY_image];
             if(image.length)
                 [df setObject:image forKey:USER_DEFAULT_KEY_FB_IMAGE];
             
             if(success)
                 success();
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(msg, nil);
         }
         
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"取得FB Info失敗", error);
     }];
}

- (void)retrieveAdsInfoSuccess:(void (^)(NSArray *info))success
                       failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    [myClient getPath:ADINFO_API_PATH
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         DDLogInfo(@"ADINFO_API_PATH: %@", JSON);
         
         NSNumber *status = [JSON objectForKey:JSON_API_KEY_ok];
         
         if(status.boolValue == YES)
         {
             NSArray *rsp = [JSON objectForKey:JSON_API_KEY_rsp];
             
             if(success)
                 success(rsp);
         }
         else
         {
             NSString *msg = [JSON objectForKey:JSON_API_KEY_msg];
             
             if(failure)
                 failure(msg, nil);
         }
         
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"取得AD Info失敗", error);
     }];
}

#pragma mark - google related API

- (void)forwardGeocodeAddress:(NSString *)address
                         road:(NSString *)road
                       region:(NSString *)region
                     district:(NSString *)district
                 partialMatch:(BOOL)allowPartialMatch
                      success:(void (^)(NSNumber *lat, NSNumber *lon, NSString *district, NSString *geocodedAddress, BOOL fullyMatched))success
                      failure:(void (^)(NSString *message))failure
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&language=zh-TW&sensor=true", 
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSArray *results = [JSON objectForKey:@"results"];
            for(NSDictionary *result in results)
            {
                NSDictionary *geometry = [result objectForKey:@"geometry"];
                NSArray *addressComponents = [result objectForKey:@"address_components"];
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                NSNumber *lng = [location objectForKey:@"lng"];
                
                NSArray *types = [result objectForKey:@"types"];
                NSString *address = [result objectForKey:@"formatted_address"];
                
                DDLogInfo(@"Address from Google: %@", address);
                
                if(types.count == 0)
                    continue;
                
                NSString *type = [types objectAtIndex:0];
                
                if(allowPartialMatch || [type isEqualToString:@"street_address"])
                {
                    NSString *locality = @"";
                    
                    // filter: check if administrative_area_level_2 matches
                    // check if the administrtive area matches with the input address
                    // one of the small caveat of google map api
                    BOOL regionMatched = NO;
                    
                    for(NSDictionary *component in addressComponents)
                    {
                        NSArray *types = [component objectForKey:@"types"];
                        if([types isKindOfClass:[NSNull class]] == NO)
                        {
                            NSUInteger index = [types indexOfObject:@"administrative_area_level_2"];
                            if(index != NSNotFound)
                            {
                                if([[component objectForKey:@"long_name"] isEqualToString:region])
                                {
                                    regionMatched = YES;
                                    break;
                                }
                            }
                        }
                    }
                    
                    BOOL localityMatched = district.length == 0 ? YES : NO;
                    
                    for(NSDictionary *component in addressComponents)
                    {
                        NSArray *types = [component objectForKey:@"types"];
                        if([types isKindOfClass:[NSNull class]] == NO)
                        {
                            NSUInteger index = [types indexOfObject:@"locality"];
                            if(index != NSNotFound)
                            {
                                locality = [component objectForKey:@"long_name"];
                                if([district isEqualToString:locality] == YES)
                                {
                                    localityMatched = YES;
                                    break;
                                }
                            }
                        }
                    }
                    
                    BOOL roadMatched = NO;
                    NSRange notFound = NSMakeRange(NSNotFound, 0);
                    
                    for(NSDictionary *component in addressComponents)
                    {
                        NSArray *types = [component objectForKey:@"types"];
                        if([types isKindOfClass:[NSNull class]] == NO)
                        {
                            NSUInteger index = [types indexOfObject:@"route"];
                            if(index != NSNotFound)
                            {
                                NSRange roadRange = [[component objectForKey:@"long_name"] rangeOfString:road];
                                
                                if(NSEqualRanges(roadRange, notFound) == NO)
                                {
                                    roadMatched = YES;
                                    break;
                                }
                            }
                        }
                    }
                    
                    BOOL isFullyMatched = (regionMatched && localityMatched && roadMatched);
                    
                    if(regionMatched && localityMatched && (roadMatched || allowPartialMatch))
                    {
                        if(success)
                            success(lat, lng, locality, address, isFullyMatched);
                        
                        return;
                    }
                }
            }
            
            NSString *message = [NSString stringWithFormat:@"無法解析地址: %@", address];
            
            if(failure)
                failure(message);
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"無法解析地址: %@", status];
            
            if(failure)
                failure(message);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        NSString *message = @"無法連線到Google Map API";
        
        if(failure)
            failure(message);
    }];
    
    [operation start];
}

- (void)nearbyLandmarksSuccess:(void (^)(NSArray *places))success 
                       failure:(void (^)(NSString *reason, NSError *error))failure
{
    // start the location service
    [self.locationManager startUpdatingLocation];
    
    self.placeSearchSuccess = success;
    self.placeSearchFailure = failure;
    
    self.locationManager.delegate = self;
    isGettingLandmarks = YES;
}

- (void)searchLandmarks:(NSString *)searchTerm
                success:(void (^)(NSArray *places))success
                failure:(void (^)(NSString *reason, NSError *error))failure
{
    self.landmarkSearchTerm = searchTerm;
    
    // start the location service
    [self.locationManager startUpdatingLocation];
    
    self.placeSearchSuccess = success;
    self.placeSearchFailure = failure;
    
    self.locationManager.delegate = self;
    isSearchingLandmarks = YES;
}

- (void)googlePlaceSearchKeyword:(NSString *)keyword location:(CLLocation *)location
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[NSString stringWithFormat:@"location=%f,%f",
                           location.coordinate.latitude, location.coordinate.longitude]];
    [parameters addObject:[NSString stringWithFormat:@"types=%@", @"establishment%7Cstreet_address"]]; // escape for | is %7C
    [parameters addObject:[NSString stringWithFormat:@"language=%@", @"zh-TW"]];
    [parameters addObject:[NSString stringWithFormat:@"keyword=%@",
                           [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [parameters addObject:[NSString stringWithFormat:@"radius=%d", 50000]]; //max radius
    [parameters addObject:[NSString stringWithFormat:@"key=%@", GOOGLE_API_KEY]];
    [parameters addObject:@"sensor=true"];
    
    NSString *paramString = [parameters componentsJoinedByString:@"&"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?%@", paramString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSArray *results = [JSON objectForKey:@"results"];
            if(results.count)
            {
                NSDictionary *firstResult = [results objectAtIndex:0];
                NSDictionary *geometry = [firstResult objectForKey:@"geometry"];
                NSDictionary *location = [geometry objectForKey:@"location"];
                NSNumber *lat = [location objectForKey:@"lat"];
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lng.doubleValue];
                [self googlePlaceSearchAroundLocation:newCenter];
                
                [newCenter release];
            }
            else
            {
                if(self.placeSearchFailure)
                {
                    self.placeSearchFailure(@"找不到地標", nil);
                    
                    self.placeSearchSuccess = nil;
                    self.placeSearchFailure = nil;
                    self.landmarkSearchTerm = nil;
                }
            }
        }
        else
        {
            if(self.placeSearchFailure)
            {
                self.placeSearchFailure(@"找不到地標", nil);
                
                self.placeSearchSuccess = nil;
                self.placeSearchFailure = nil;
                self.landmarkSearchTerm = nil;
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        if(self.placeSearchFailure)
        {
            self.placeSearchFailure(@"連線失敗", error);
            
            self.placeSearchSuccess = nil;
            self.placeSearchFailure = nil;
            self.landmarkSearchTerm = nil;
        }
    }];
    
    [operation start];
}

- (void)googlePlaceSearchAroundLocation:(CLLocation *)location
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[NSString stringWithFormat:@"location=%f,%f", 
                           location.coordinate.latitude, location.coordinate.longitude]];
    [parameters addObject:[NSString stringWithFormat:@"types=%@", @"establishment%7Cstreet_address"]]; // escape for | is %7C
    [parameters addObject:[NSString stringWithFormat:@"radius=%d", 300]];
    [parameters addObject:[NSString stringWithFormat:@"language=%@", @"zh-TW"]];
    [parameters addObject:[NSString stringWithFormat:@"key=%@", GOOGLE_API_KEY]];
    [parameters addObject:@"sensor=true"];
        
    NSString *paramString = [parameters componentsJoinedByString:@"&"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?%@", paramString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSArray *results = [JSON objectForKey:@"results"];
            
            if(self.placeSearchSuccess)
            {
                self.placeSearchSuccess(results);
                
                self.placeSearchSuccess = nil;
                self.placeSearchFailure = nil;
                self.landmarkSearchTerm = nil;
            }
        }
        else
        {
            if(self.placeSearchFailure)
            {
                self.placeSearchFailure(@"找不到附近地標", nil);
                
                self.placeSearchSuccess = nil;
                self.placeSearchFailure = nil;
                self.landmarkSearchTerm = nil;
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        if(self.placeSearchFailure)
        {
            self.placeSearchFailure(@"連線失敗", error);
            
            self.placeSearchSuccess = nil;
            self.placeSearchFailure = nil;
            self.landmarkSearchTerm = nil;
        }
    }];
    
    [operation start];
}

- (void)getGooglePlaceDetail:(NSString *)reference 
                     success:(void (^)(NSDictionary *placeInfo))success 
                     failure:(void (^)(NSString *message, NSError *error))failure
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[NSString stringWithFormat:@"reference=%@", reference]];
    [parameters addObject:[NSString stringWithFormat:@"language=%@", @"zh-TW"]];
    [parameters addObject:[NSString stringWithFormat:@"key=%@", GOOGLE_API_KEY]];
    [parameters addObject:@"sensor=true"];
    
    NSString *paramString = [parameters componentsJoinedByString:@"&"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?%@", paramString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            if(success)
                success(result);
        }
        else
        {
            if(failure)
                failure(@"無法解析地標地址", nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        if(failure)
            failure(@"連線失敗", error);
    }];
    
    [operation start];
}

- (void)googleMapReverseGeocodeWithLat:(NSNumber *)lat
                                   lon:(NSNumber *)lon
                               success:(void (^)(NSDictionary *placeInfo))success
                               failure:(void (^)(NSString *message, NSError *error))failure
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[NSString stringWithFormat:@"latlng=%f,%f", lat.doubleValue, lon.doubleValue]];
    [parameters addObject:[NSString stringWithFormat:@"language=%@", @"zh-TW"]];
    [parameters addObject:@"sensor=true"];
    
    NSString *paramString = [parameters componentsJoinedByString:@"&"];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?%@", paramString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON objectForKey:@"status"];
        if([status isEqualToString:GOOGLE_API_CODE_OK] == YES)
        {
            NSArray *results = [JSON objectForKey:@"results"];
            
            for(NSDictionary *result in results)
            {
                NSArray *types = [result objectForKey:@"types"];
                
                if([types isKindOfClass:[NSArray class]] == YES)
                {
                    for(NSString *type in types)
                    {
                        if([type isEqualToString:@"street_address"])
                        {
                            if(success)
                            {
                                success(result);
                            }
                            return;
                        }
                    }
                }
            }
            
            if(failure)
                failure(@"無法解析地標地址", nil);
            return;
        }
        else
        {
            if(failure)
                failure(@"無法解析地標地址", nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        if(failure)
            failure(@"連線失敗", error);
    }];
    
    [operation start];
}

#pragma mark - gps methods

- (void)startTracking
{
    if([CLLocationManager locationServicesEnabled] == NO)
    {
        [self.center postNotificationName:LOCATION_TRACKING_NOT_AVAIL_NOTIF object:self];
    }
    
    [locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    isTrackingPath = YES;
}

- (void)stopTracking
{
    [locationManager stopUpdatingLocation];
    isTrackingPath = NO;
}

#pragma mark - misc

- (void)generateBonusLink:(void (^)(NSString *urlLink, NSString *msg, NSError *error))callback
{
    // start the location service
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    isPreparingForBonus = YES;
    
    int64_t delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        isPreparingForBonus = NO;
        CLLocation *loc = self.locationManager.location;
        
        double lat = 0;
        double lon = 0;
        
        // 9-23-2013 changes: lat lon is no longer required
        if(loc && loc.horizontalAccuracy > 0)
        {
            lat = loc.coordinate.latitude;
            lon = loc.coordinate.longitude;
        }
        
        NSString *url = [NSString stringWithFormat:@"%@?CUSTACCT=%@&CUSTNAME=%@&SEX=%@&ADDR=%@&LOC_LAT=%f&LOC_LNG=%f",
                         [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_BONUS],
                         [self.userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [self.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         self.userIsMale ? @"M" :@"F",
                         @"",
                         lat, lon];
        if(callback)
            callback(url, @"準備完成", nil);
        
        /*
        if(loc == nil || loc.horizontalAccuracy < 0)
        {
            if(callback)
                callback(nil, @"無法定位", nil);
        }
        else
        {
            double lat = loc.coordinate.latitude;
            double lon = loc.coordinate.longitude;
            
            NSString *url = [NSString stringWithFormat:@"%@?CUSTACCT=%@&CUSTNAME=%@&SEX=%@&ADDR=%@&LOC_LAT=%f&LOC_LNG=%f",
                             [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_BONUS],
                             [self.userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             [self.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             self.userIsMale ? @"M" :@"F",
                             @"",
                             lat, lon];
            if(callback)
                callback(url, @"準備完成", nil);
        }
        */
    });
}

- (void)getAdImage:(NSDictionary *)adInfo
           success:(void (^)(UIImage *newImage))success
{
    NSString *imageName = [adInfo objectForKey:ADINFO_API_KEY_id];
    NSString *imagePath = [adInfo objectForKey:ADINFO_API_KEY_image];
    
    // return the image if we have it at moment
    UIImage *newImage = [self.adImageCache objectForKey:imageName];
    
    if(newImage)
    {
        if(success)
            success(newImage);
    }
    else
    {
        if(imageName && imagePath)
        {
            NSString *imageURL = [NSString stringWithFormat:@"%@%@", self.json_base_url, imagePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            
            
            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
                return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(304, 68) interpolationQuality:kCGInterpolationDefault];
            } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                [self.adImageCache setObject:image forKey:imageName];
                
                if(success)
                    success(image);
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                DDLogError(@"downloading inner banner ad image failed: %@", error.description);
            }];
            
            [operation start];
        }
    }
}

/*
- (UIImage *)getAdImage:(NSDictionary *)adInfo
                success:(void (^)(UIImage *newImage))success
{
    NSString *imageName = [adInfo objectForKey:ADINFO_API_KEY_id];
    NSString *imagePath = [adInfo objectForKey:ADINFO_API_KEY_image];
    
    // return the image if we have it at moment
    UIImage *img = [self.adImageCache objectForKey:imageName];
    if(img == nil)
    {
        //see if we can load it from the disc
        if(imageName && imagePath)
        {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            img = [UIImage loadImage:imageName
                              ofType:[imagePath pathExtension]
                         inDirectory:docsPath];
            if(img)
                [self.adImageCache setObject:img forKey:imageName];
        }
    }
    
    if(imageName && imagePath)
    {
        NSString *imageURL = [NSString stringWithFormat:@"%@%@", self.json_base_url, imagePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        
        
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
            return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(304, 68) interpolationQuality:kCGInterpolationDefault];
        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            
            [UIImage saveImage:image
                  withFileName:imageName
                        ofType:[imagePath pathExtension]
                   inDirectory:docsPath];
            
            [self.adImageCache setObject:image forKey:imageName];
            
            if(success)
                success(image);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            DDLogError(@"downloading inner banner ad image failed: %@", error.description);
        }];
        
        [operation start];
    }
    
    return img;
}
 */

- (void)saveAdInfoToDisk
{
    if(self.adsDict == nil)
        return;
    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [docsPath stringByAppendingPathComponent:FILE_AD_INFO];
    
    if([self.adsDict writeToFile:filename atomically:YES] == YES)
    {
        DDLogInfo(@"ads info saved to disk successfully");
    }
    else
    {
        DDLogError(@"ads info saved to disk failed");
    }
}

- (NSArray *)loadAdInfoFromDisk
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [docsPath stringByAppendingPathComponent:FILE_AD_INFO];
    
    NSArray *saved = [NSArray arrayWithContentsOfFile:filename];
    
    return saved;
}

- (NSDictionary *)getRandomAdInfo
{
    if(self.adsDict == nil)
        return nil;
    
    if(self.adsDict.count)
    {
        self.currentAdImageIndex = self.currentAdImageIndex % self.adsDict.count;
        
        NSString *key = [[self.adsDict objectAtIndex:self.currentAdImageIndex] objectForKey:ADINFO_API_KEY_id];
        UIImage *image = [self.adImageCache objectForKey:key];
        NSString *link = [[self.adsDict objectAtIndex:self.currentAdImageIndex] objectForKey:ADINFO_API_KEY_link];
        if(!link)
            link = @"";
        
        self.currentAdImageIndex++;
        
        return [NSDictionary dictionaryWithObjectsAndKeys:
                image, @"image",
                link, @"url", nil];
    }
    
    return nil;
}

- (void)configAppMode
{
    if(self.currentAppMode == AppModeTWTaxi)
    {
        self.json_base_url = [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_TW_JSON];
        self.xml_base_url = [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_TW_XML];
        
        //self.json_base_url
        self.myClient = [AFTaiwanTaxiAPIClient sharedClient:self.json_base_url];
    }
    else
    {
        self.json_base_url = [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_CITY_JSON];
        self.xml_base_url = [self.backendURLsInfo objectForKey:BACKEND_URL_KEY_CITY_XML];
        self.myClient = [AFCityTaxiAPIClient sharedClient:self.json_base_url];
    }
    
    NSURL *url = [NSURL URLWithString:MEMBER_MINI_SITE_URL
                        relativeToURL:[NSURL URLWithString:self.json_base_url]];
    self.mini_site_url = url.absoluteString;
    
    [self.myClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable)
        {
            [SVProgressHUD showWithStatus:@"無法連上後台, 請確認網路是否正常"
                                 maskType:SVProgressHUDMaskTypeBlack];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
    }];
    
    self.currentAdImageIndex = 0;
}

- (void)changeAppModeSuccess:(void (^)(NSString *message))success
                     failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    NSString *message = @"";
    if(self.currentAppMode == AppModeTWTaxi)
    {
        message = @"已切換成城市衛星";
        self.currentAppMode = AppModeCityTaxi;
    }
    else
    {
        message = @"已切換成台灣大車隊";
        self.currentAppMode = AppModeTWTaxi;
    }
    
    [self configAppMode];
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentAppMode forKey:USER_DEFAULT_KEY_APP_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[ServiceManager sharedInstance] updateAdInfo];
    
    if(success)
    {
        success(message);
    }
}

- (void)processOrderXML:(NSString *)submittedXML
           inputAddress:(NSString *)inputAddress
        geocodedAddress:(NSString *)geocodedAddress
         addressMatched:(NSNumber *)addressMatched
                    lat:(NSNumber *)lat
                    lon:(NSNumber *)lon
                 result:(int)result
                 cardNo:(NSString *)cardNo
               estimate:(NSString *)estimate
               duration:(CFAbsoluteTime)duration
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"KyDB6aU6kv"                             forKey:@"token"];
    [params setObject:self.userID                               forKey:@"uid"];
    [params setObject:[self platformString]                     forKey:@"device"];
    [params setObject:[[UIDevice currentDevice] systemVersion]  forKey:@"osver"];
    if(self.devicePushToken.length)
        [params setObject:self.devicePushToken      forKey:@"deviceId"];
    
    if(submittedXML.length) [params setObject:submittedXML forKey:@"submittedXML"];
    if(inputAddress.length) [params setObject:inputAddress forKey:@"inputAddress"];
    if(geocodedAddress.length) [params setObject:geocodedAddress forKey:@"geocodedAddress"];
    if(addressMatched) [params setObject:addressMatched forKey:@"addressMatched"];
    if(lat) [params setObject:lat forKey:@"lat"];
    if(lon) [params setObject:lon forKey:@"lon"];
    if(result) [params setObject:@(result) forKey:@"result"];
    if(cardNo.length) [params setObject:cardNo forKey:@"carNumber"];
    if(estimate.length) [params setObject:estimate forKey:@"estimateArrival"];
    if(duration) [params setObject:@(duration) forKey:@"duration"];
    
    [self.logClient postPath:@"secure/api/addOrderLog"
                  parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         DDLogInfo(@"processOrderXML successful");
                         NSError *error = nil;
                         NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                         if(error == nil){
                             self.currentOrderKey = [result objectForKey:@"key"];
                             
                         }
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         DDLogError(@"processOrderXML failed: %@", error.description);
                    }];
}

- (void)updateProcessOrderWithKey:(NSString *)key
                           result:(int)result
                         cancelOn:(NSDate *)cancelOn
{    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"KyDB6aU6kv" forKey:@"token"];
    
    if(key.length) [params setObject:key forKey:@"key"];
    if(result) [params setObject:@(result) forKey:@"result"];
    if(cancelOn) [params setObject:@([cancelOn timeIntervalSince1970]) forKey:@"cancelOn"];
    
    [self.logClient postPath:@"secure/api/updateOrderLog"
                  parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         DDLogInfo(@"updateProcessOrderWithKey successful");
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         DDLogError(@"updateProcessOrderWithKey failed: %@", error.description);
                     }];
    
}

- (void)recordAppEventWithUser:(NSString *)uid
                           msg:(NSString *)msg
                          sent:(NSString *)sent
                      received:(NSString *)received
                        parent:(NSString *)parent
{
    if(IS_DEBUG_MODE == YES)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"iphone" forKey:@"device"];
        if(self.devicePushToken.length)
            [params setObject:self.devicePushToken forKey:@"deviceId"];
        if(uid.length)
            [params setObject:uid forKey:@"uid"];
        if(msg.length)
            [params setObject:msg forKey:@"msg"];
        if(sent.length)
            [params setObject:sent forKey:@"sent"];
        if(received.length)
            [params setObject:received forKey:@"received"];
        if(parent.length)
            [params setObject:parent forKey:@"parent"];
        
        [self.logClient postPath:@"api/addLog"
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             DDLogInfo(@"Sent app log successful");
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             DDLogError(@"sending app event log failed: %@", error.description);
                         }];
    }
}

- (NSString *)platformString
{
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

#pragma mark - CLLocationManagerDelegate

// deprecated for iOS 6
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateLocations:[NSArray arrayWithObject:newLocation]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    if(isGettingLandmarks == YES)
    {
        [self googlePlaceSearchAroundLocation:newLocation];
        isGettingLandmarks = NO;
    }
    else if(isSearchingLandmarks == YES)
    {
        [self googlePlaceSearchKeyword:self.landmarkSearchTerm location:newLocation];
        isSearchingLandmarks = NO;
    }
    
    if(isTrackingPath == YES)
    {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                              newLocation, @"newLocation", nil];
        
        [self.center postNotificationName:UPDATE_LOCATION_NOTIF object:self userInfo:info];
    }
    
    if(isGettingLandmarks == NO && isTrackingPath == NO && isSearchingLandmarks == NO && isPreparingForBonus == NO)
    {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(isGettingLandmarks == YES)
    {
        if(self.placeSearchFailure)
        {
            self.placeSearchFailure(@"無法定位", error);
            
            self.placeSearchSuccess = nil;
            self.placeSearchFailure = nil;
        }
        
        isGettingLandmarks = NO;
    }
    
    if(isTrackingPath == YES)
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:error forKey:@"error"];
        [self.center postNotificationName:ERROR_UPDATE_LOCATION_NOTIF
                                   object:self
                                 userInfo:info];
        
        isTrackingPath = NO;
    }
    
    if(isGettingLandmarks == NO && isTrackingPath == NO)
    {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
}

#pragma mark - singleton implementation code

+ (TaxiManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static TaxiManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}






#pragma mark - More functions added on 2013.11.25
//edited by kiki Huang 2013.12.09
- (void)taxiPlayToken:(NSString *)uesrNum
                      success:(void (^)(id JSON))success
            failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    
    [myClient postPath:TAXI_PLAYGAME_SESSION
            parameters:[NSDictionary dictionaryWithObjectsAndKeys: uesrNum,@"memberAccount", nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
//         NSLog(@"%@", [operation.response allHeaderFields]);
         if(success)
             success(JSON);
         NSLog(@"player success%@",JSON);
         
     }
     
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"failure", error);
     }];
}


- (void)taxiTicketToken:(NSString *)uesrNum
              success:(void (^)(id JSON))success
              failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    
    AFHTTPClient *ticketClient;
    ticketClient =[AFCityTaxiAPIClient sharedBaseURLClient:nil];
    [ticketClient getPath:@"api/phone/getTICKET_TOKEN.aspx"
            parameters:[NSDictionary dictionaryWithObjectsAndKeys: uesrNum,@"CUSTACCT", nil]
               success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         NSLog(@"player success%@",JSON);
         if(success)
             success(JSON);
         
         
     }
     
               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(failure)
             failure(@"failure", error);
     }];
}

-(void)taxiTicketTokenWithCookie:(NSString *)path para:(NSDictionary *)paramters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure{
    
    
    NSURL *dataUrl = [NSURL URLWithString:path];
    
//    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
//    NSArray *temp = [NSArray arrayWithObject:[cookies lastObject]];
    
    
    
//    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:temp];
//    NSDictionary *costomHeaders =[NSDictionary dictionaryWithObjectsAndKeys:@".ASPXAUTH=B32C9CD1AE75A75E98BE96C84826D3427027794D9E6E60739204E6C9402BF477AF544F5DD1B54344CBE0F7A3061125CF1061A77A02EA1073F6CD189E7A4BF7232FC2FC0F7ED9E34C53DCB3D2E0192FE170526F61A7E8B5868912A84FA3797FB3E41FC42B7BCA071C0FBF0899E68F3E787506354110421A4F40750B6FD543DC08E7B677CD384F51324DBF9F7A1EDEABF906DB4193E8C9330132F7D146AF72F385A01A9EFDF5E280B17FD4103D2BAA2012C4403A4C08840C42DE1B440EE48FE2B6",@"Cookie", nil];
    
     NSDictionary *costomHeaders =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"],@"Cookie", nil];
    NSLog(@"%@", dataUrl);
    NSLog(@"cookieStorage %@",costomHeaders);

    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    __strong NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.f];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(paramters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
    [request setAllHTTPHeaderFields:costomHeaders];
    
    NSLog(@"ticket reguest %@",request.allHTTPHeaderFields);
    
    
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSLog(@"allHeader%@",operation.response.allHeaderFields);
            success(responseObject);
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(@"failure ",error);
        }
    }];
    
    [operation start];
}
/*
- (void)saveCookies{
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
//    NSLog(@"cookie save %@",[[[NSString alloc] initWithData:cookiesData
//                                                   encoding:NSUTF8StringEncoding] autorelease]);
    NSLog(@"cookie save %@",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
    
}

- (void)loadCookies{
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSLog(@"%@", cookies);
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}
 */
-(void)taxiCM5doModeWithCookie:(NSString *)path para:(NSDictionary *)paramters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure {
    
    NSURL *dataUrl = [NSURL URLWithString:path];
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:dataUrl];
//    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    
//    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
//    NSLog(@"sheaders %@",sheaders);
    NSDictionary *costomHeaders =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"],@"Cookie", nil];
    //    NSLog(@"%@", headers);
    NSLog(@"cookieStorage %@",costomHeaders);
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    __strong NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.f];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(paramters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
    [request setAllHTTPHeaderFields:costomHeaders];
    NSLog(@"cm5dataurl %@",request.URL);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSLog(@"allHeader%@",operation.response.allHeaderFields);
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(@"failure ",error);
        }
    }];
    
    [operation start];
}
/*
-(void)taxiCM5doMode:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure{
    NSLog(@"cm5 parameter %@",parameters);
    AFHTTPClient *ticketClient;
    ticketClient =[AFCityTaxiAPIClient sharedTicketClient:nil];
    [ticketClient postPath:TAXI_CM5_SESSION parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (success) {
             NSLog(@"allHeader%@",operation.response.allHeaderFields);
             success(responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
             failure(@"failure ",error);
         }
     }];
}
 */
-(void)taxiFreeway:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure{
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    }else
        baseUrl = nil;
    
    AFHTTPClient *freewayClient;
    freewayClient = [AFCityTaxiAPIClient sharedBaseURLClient:baseUrl];
    [freewayClient postPath:TAXI_FREEWAY_SESSION parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            NSLog(@"success %@",responseObject);
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(@"failure ",error);
        }
    }];
}
//-(void)taxiIntroUI:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure{
-(void)taxiIntroUI:(NSDictionary *)parameters{
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    }else
        baseUrl = nil;
    
    AFHTTPClient *introUIClient;
    introUIClient = [AFCityTaxiAPIClient sharedBaseURLClient:baseUrl];
    [introUIClient getPath:TAXI_INTRO_UI_SESSION parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id resultObject;
        NSLog(@"%@",responseObject);
        
      if ([responseObject isKindOfClass:[NSArray class]]) {
          resultObject = [responseObject objectAtIndex:0];
      }else{
          resultObject = responseObject;
      }
        
        NSLog(@"introUI object: %@", resultObject);
//        [[NSUserDefaults standardUserDefaults]setObject:[[resultObject  objectForKey:@"PicPath"] pathExtension] forKey:@"fileType"];
        [self didFinishedPost:resultObject];
        
//        if (success) {
//            success(responseObject);
//        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"operation%@",operation.response);
        NSLog(@"error :%@",error);
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"getLocalImage" object:self];
    }];
}
-(void)didFinishedPost:(NSDictionary *)json{
    NSLog(@"type array %@",json);
    
    if (json!=nil && [json objectForKey:@"PicPath"]!=nil && [json objectForKey:@"CreateDate"]!=nil) {
        
//        NSLog(@"jack intro image %@",[json objectForKey:@"PicPath"]);
//        NSLog(@"jack intro version %@",[json  objectForKey:@"CreateDate"]);
         NSString *baseUrl =[[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
        
        NSString *url = [NSString stringWithFormat:@"%@stark/images/lead/%@",baseUrl,[json  objectForKey:@"PicPath"]];
        NSString* _escapedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"url %@",_escapedUrlString);
        
        
        if (![self checkFolder:INTRO_IMG_FILENAME]) {
            [[NSUserDefaults standardUserDefaults]setValue:[self StringToDate:[json objectForKey:@"CreateDate"]] forKey:INTRO_IMG_VERSION];
            [self updateIntroImage:_escapedUrlString];
        }else{
            
            NSDate *date1 = [[NSUserDefaults standardUserDefaults]valueForKey:INTRO_IMG_VERSION];
            NSLog(@"%@",date1);
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:INTRO_IMG_VERSION]isKindOfClass:[NSString class]]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:INTRO_IMG_VERSION];
                [[NSFileManager defaultManager]removeItemAtPath:[self getFilePath:INTRO_IMG_FILENAME] error:nil];
                return;
            }
            
            NSDate *date2 =[self StringToDate:[json objectForKey:@"CreateDate"]];
            NSLog(@"%@",date2);
            
            if (![self CompareVersionDate:date1 :date2]) {
                [[NSUserDefaults standardUserDefaults]setValue:[self StringToDate:[json objectForKey:@"CreateDate"]] forKey:INTRO_IMG_VERSION];
                
                [self updateIntroImage:_escapedUrlString];
            }
           
        }
        
    }
}
-(NSDate*)StringToDate:(NSString *)str{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSLog(@"stringToDate %@", [formatter dateFromString:str]);
    return [formatter dateFromString:str];
}
-(BOOL)CompareVersionDate:(NSDate*)date1 :(NSDate*)date2{
    NSLog(@"date1:%@ date2:%@",date1,date2);
    if ([date1 compare:date2] == NSOrderedDescending) {
        return NO;
        
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        return NO;
        
    } else {
        return YES;
        
    }
}
-(void)updateIntroImage:(NSString *)url{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:INTRO_IMG_FILENAME] stringByAppendingPathExtension:[url pathExtension]];
    NSLog(@"introimage_update_path : %@", path);
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    //    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    //    {
    //        progressBarView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
    //
    //    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[NSUserDefaults standardUserDefaults]setObject:[url pathExtension] forKey:@"fileType"];
        NSLog(@"Successfully downloaded file");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"introIMG update Error: %@", error);
        [[NSUserDefaults standardUserDefaults] setObject:@"1997-01-17 16:25:03" forKey:INTRO_IMG_VERSION];
    }];
    
    [operation start];
    
}

-(BOOL)checkFolder:(NSString*) _name {
    
    NSString *filetype = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"];
    if (filetype !=nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:_name] stringByAppendingPathExtension:filetype];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            return NO;
        }
        else
            return YES;
        
    }
    return NO;
    
}
-(NSString *)getFilePath:(NSString*) _name{
    NSString *filetype = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileType"];
    if (filetype !=nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:_name] stringByAppendingPathExtension:filetype];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            return @"file not exit";
        }
        else
            return dataPath;
    }else
        NSLog(@"server return error");
}
-(void)taxiMenuUIButton:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure {
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
        NSLog(@"menu baseUrl %@",baseUrl);
    }else
        baseUrl = nil;

    
    AFHTTPClient *menuUIClient;
    menuUIClient = [AFCityTaxiAPIClient sharedBaseURLClient:baseUrl];
    [menuUIClient getPath:TAXI_MENU_UI_BUTTONIMG_SESSION parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"button UI response object: %@", responseObject);

        if (success) {
            
            success(responseObject);
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.response);
        if (failure) {
            NSLog(@"%@",operation.response);
            failure(@"failure ",error);
        }
    }];
}
-(void)showOrderCancelErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"伺服器連結發生錯誤" message:@"取消叫車失敗" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    alert = nil;
}
/*
-(void)taxiGetPushUrl:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure {
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]);
    NSString *baseUrl;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS]) {
        baseUrl= [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_KEY_BACKEND_URLS] objectForKey:@"API"];
    }else
        baseUrl = nil;
    
    
    AFHTTPClient *menuUIClient;
    menuUIClient = [AFCityTaxiAPIClient sharedBaseURLClient:baseUrl];
    [menuUIClient getPath:TAXI_MENU_UI_BUTTONIMG_SESSION parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"push url object: %@", responseObject);
        if (success) {
            success(responseObject);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.response);
        if (failure) {
            NSLog(@"%@",operation.response);
            failure(@"failure ",error);
        }
    }];
}
*/
@end
