//
//  TaxiMananger.h
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/25/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TaxiOrderObj.h"

extern NSString * const UPDATE_LOCATION_NOTIF;
extern NSString * const LOCATION_TRACKING_NOT_AVAIL_NOTIF;
extern NSString * const ERROR_UPDATE_LOCATION_NOTIF;
extern NSString * const LOAD_SAVED_TRACK_NOTIF;

typedef enum {
    AppModeTWTaxi           = 0,
    AppModeCityTaxi         = 1,
} AppMode;

@interface TaxiManager : NSObject <CLLocationManagerDelegate>
{
    BOOL isTrackingPath;
    BOOL isGettingLandmarks;
    BOOL isSearchingLandmarks;
    BOOL isPreparingForBonus;

}

+ (TaxiManager *)sharedInstance;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *userPwd;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userTitle;
@property (nonatomic, retain) NSString *userTel;
@property (nonatomic, retain) NSString *userEmail;
@property (nonatomic, retain) NSString *userJob;
@property (nonatomic, retain) NSString *userBirthDay;
@property (nonatomic, retain) NSString *userCard;
@property (nonatomic, retain) NSString *devicePushToken;
@property (nonatomic, assign) BOOL userIsMale;
@property (nonatomic, copy) NSString *currentOrderID;
@property (nonatomic, copy) NSString *currentOrderCarNumber;
@property (nonatomic, copy) NSString *currentOrderXML;
@property (nonatomic, copy) NSString *currentOrderInputAddress;
@property (nonatomic, copy) NSString *currentOrderGeocodedAddress;
@property (nonatomic, retain) NSNumber *currentOrderAddressMatched;
@property (nonatomic, assign) CFAbsoluteTime currentOrderStartTime;
@property (nonatomic, retain) NSNumber *currentOrderLat;
@property (nonatomic, retain) NSNumber *currentOrderLon;
@property (nonatomic, copy) NSString *currentOrderKey;
@property (nonatomic, copy) NSDate *currentOrderDate;
@property (nonatomic, copy) NSString *currentOrderETA;
@property (nonatomic, assign) BOOL isLogIn;
@property (nonatomic, assign) BOOL autoLogIn;
@property (nonatomic, retain) NSArray *adsDict;
@property (nonatomic, retain) NSCache *adImageCache;
@property (nonatomic, assign) int currentAppMode;
@property (nonatomic, assign) int backendTimeout;

@property (nonatomic, retain) NSString *json_base_url;
@property (nonatomic, retain) NSString *xml_base_url;
@property (nonatomic, retain) NSString *mini_site_url;
@property (nonatomic, retain) NSDictionary *backendURLsInfo;
@property (nonatomic, assign) int currentAdImageIndex;
@property (nonatomic, retain) NSDictionary *occpuationChoices;
@property (nonatomic, retain) NSDictionary *creditCardChoices;
@property (nonatomic, assign) BOOL forceUpdate;
@property (nonatomic, retain) NSString *serverVersion;
@property (nonatomic, retain) NSString *appStoreLink;
@property (nonatomic, retain) NSString *bonusValue;

//edited by kiki Huang 2013.12.09
@property (nonatomic, retain) NSString *bonusOverDate;
@property (nonatomic, retain) NSString *overDate;

#pragma mark - user default related

- (void)saveUserInfo;

#pragma mark - taxi order xml API

- (void)submitTaxiOrder:(NSString *)orderID 
                success:(void (^)())success 
                failure:(void (^)())failure;

//modified by kiki Huang 2014.01.12
- (void)cancelTaxiOrderWithBlock:(NSString *)orderID success:(void(^)())success failure:(void(^)())failure;

- (void)getTaxiPositionForTaxiOrder:(NSString *)orderID
                            success:(void (^)(double lat, double lon))success
                            failure:(void (^)(NSString *errorMessage, NSError *error))failure;

#pragma mark - taiwan taxi json API

- (void)logInWithUserID:(NSString *)uID
                    pwd:(NSString *)pwd
                success:(void (^)())success
                failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)getBonusWithUserID:(NSString *)uID
                   success:(void (^)())success
                   failure:(void (^)(NSString *errorMessage, NSError *error))failure;

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
                      failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure;

- (void)updateAccountWithID:(NSString *)uID
                        pwd:(NSString *)pwd
                       name:(NSString *)name
                      title:(NSString *)title
                   birthday:(NSString *)birthday
                      email:(NSString *)email
                     career:(NSString *)career
                       ages:(NSString *)ages
                       card:(NSString *)card
                     isMale:(BOOL)isMale
                    success:(void (^)(int code))success
                    failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure;

- (void)performOTPWith:(NSString *)uID
                  code:(NSString *)code
               success:(void (^)(int code))success
               failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure;

- (void)requestOTPCode:(NSString *)uID
               success:(void (^)(int code))success
               failure:(void (^)(int code, NSString *errorMessage, NSError *error))failure;

- (void)forgetPassword:(NSString *)uID
               success:(void (^)())success
               failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)registerPushNotificationWithToken:(NSString *)token
                              pushEnabled:(BOOL)isEnabled
                                  success:(void (^)())success
                                  failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)sendTaxiOrderEvaluation:(NSString *)orderID
                        success:(void (^)())success
                        failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)sendSuggestionWithName:(NSString *)name
                           tel:(NSString *)tel
                         email:(NSString *)email
                       context:(NSString *)context
                       success:(void (^)())success
                       failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)retrieveFBInfoSuccess:(void (^)())success
                      failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)retrieveAdsInfoSuccess:(void (^)(NSArray *info))success
                       failure:(void (^)(NSString *errorMessage, NSError *error))failure;

#pragma mark - google API

- (void)forwardGeocodeAddress:(NSString *)address
                         road:(NSString *)road
                       region:(NSString *)region
                     district:(NSString *)district
                 partialMatch:(BOOL)allowPartialMatch
                      success:(void (^)(NSNumber *lat, NSNumber *lon, NSString *district, NSString *geocodedAddress, BOOL fullyMatched))success
                      failure:(void (^)(NSString *message))failure;

- (void)nearbyLandmarksSuccess:(void (^)(NSArray *places))success 
                       failure:(void (^)(NSString *reason, NSError *error))failure;

- (void)searchLandmarks:(NSString *)searchTerm
                success:(void (^)(NSArray *places))success
                failure:(void (^)(NSString *reason, NSError *error))failure;

- (void)getGooglePlaceDetail:(NSString *)reference
                     success:(void (^)(NSDictionary *placeInfo))success 
                     failure:(void (^)(NSString *message, NSError *error))failure;

- (void)googleMapReverseGeocodeWithLat:(NSNumber *)lat
                                   lon:(NSNumber *)lon
                               success:(void (^)(NSDictionary *placeInfo))success
                               failure:(void (^)(NSString *message, NSError *error))failure;

#pragma mark - GPS tracking

- (void)startTracking;
- (void)stopTracking;

#pragma mark - misc

- (void)generateBonusLink:(void (^)(NSString *urlLink, NSString *msg, NSError *error))callback;

- (void)getAdImage:(NSDictionary *)adInfo
           success:(void (^)(UIImage *newImage))success;

- (NSDictionary *)getRandomAdInfo;

- (void)configAppMode;
- (void)changeAppModeSuccess:(void (^)(NSString *message))success
                     failure:(void (^)(NSString *errorMessage, NSError *error))failure;

- (void)processOrderXML:(NSString *)submittedXML
           inputAddress:(NSString *)inputAddress
        geocodedAddress:(NSString *)geocodedAddress
         addressMatched:(NSNumber *)addressMatched
                    lat:(NSNumber *)lat
                    lon:(NSNumber *)lon
                 result:(int)result
                 cardNo:(NSString *)cardNo
               estimate:(NSString *)estimate
               duration:(CFAbsoluteTime)duration;

- (void)updateProcessOrderWithKey:(NSString *)key
                           result:(int)result
                         cancelOn:(NSDate *)cancelOn;
- (void)recordAppEventWithUser:(NSString *)uid
                           msg:(NSString *)msg
                          sent:(NSString *)sent
                      received:(NSString *)received
                        parent:(NSString *)parent;

- (void)saveAdInfoToDisk;
- (NSArray *)loadAdInfoFromDisk;




#pragma mark - Taxi Server API
//edited by kiki Huang 2013.12.09
- (void)taxiPlayToken:(NSString *)uesrNum
              success:(void (^)(id JSON))success
              failure:(void (^)(NSString *errorMessage, NSError *error))failure;
//- (void)generatePlayWithToken:(NSString *)token
//                     playLink:(void (^)(NSString *urlLink, NSString *msg, NSError *error))callback;

//edited by kiki Huang 2013.12.10
-(void)taxiTicketTokenWithCookie:(NSString *)path para:(NSDictionary *)paramters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
//-(void)taxiCM5doMode:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
-(void)taxiFreeway:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
//-(void)taxiIntroUI:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
-(void)taxiIntroUI:(NSDictionary *)parameters;
-(void)taxiMenuUIButton:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
//-(void)taxiGetPushUrl:(NSDictionary *)parameters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;
-(void)taxiCM5doModeWithCookie:(NSString *)path para:(NSDictionary *)paramters success:(void (^)(id JSON))success failure:(void (^)(NSString *errorMessage , NSError *error))failure;

-(void)showOrderCancelErrorAlert;

- (void)taxiTicketToken:(NSString *)uesrNum
                success:(void (^)(id JSON))success
                failure:(void (^)(NSString *errorMessage, NSError *error))failure;
@end
