//
//  Constants.h
//  TaiwanTaxi
//
//  Created by jason on 8/14/12.
//
//
#import <Foundation/Foundation.h>

// JSON backend API related

extern NSString * const BACKEND_URL_KEY_TW_JSON;
extern NSString * const BACKEND_URL_KEY_TW_XML;
extern NSString * const BACKEND_URL_KEY_CITY_JSON;
extern NSString * const BACKEND_URL_KEY_CITY_XML;
extern NSString * const BACKEND_URL_KEY_BONUS;

extern NSString * const JSON_API_KEY_ok;
extern NSString * const JSON_API_KEY_msg;
extern NSString * const JSON_API_KEY_rsp;
extern NSString * const JSON_API_KEY_code;

extern NSString * const REGISTER_API_PATH;
extern NSString * const REGISTER_API_CUSTACCT;
extern NSString * const REGISTER_API_CUSTPIN;
extern NSString * const REGISTER_API_CUSTNAME;
extern NSString * const REGISTER_API_CUSTTITLE;
extern NSString * const REGISTER_API_BIRTHDAY;
extern NSString * const REGISTER_API_EMAIL;
extern NSString * const REGISTER_API_CAREER;
extern NSString * const REGISTER_API_AGES;
extern NSString * const REGISTER_API_PHONETYPE;
extern NSString * const REGISTER_API_PHONEMODEL;
extern NSString * const REGISTER_API_CUSTTEL1; //市話
extern NSString * const REGISTER_API_CUSTTEL2; //手機
extern NSString * const REGISTER_API_CREDIT;

extern NSString * const UPDATE_USER_API_PATH;
extern NSString * const UPDATE_USER_API_CUSTACCT;
extern NSString * const UPDATE_USER_API_CUSTPIN;
extern NSString * const UPDATE_USER_API_NEWCUSTPIN;
extern NSString * const UPDATE_USER_API_CUSTNAME;
extern NSString * const UPDATE_USER_API_CUSTTITLE;
extern NSString * const UPDATE_USER_API_BIRTHDAY;
extern NSString * const UPDATE_USER_API_EMAIL;
extern NSString * const UPDATE_USER_API_CAREER;
extern NSString * const UPDATE_USER_API_AGES;
extern NSString * const UPDATE_USER_API_PHONETYPE;
extern NSString * const UPDATE_USER_API_PHONEMODEL;
extern NSString * const UPDATE_USER_API_CUSTTEL1; //市話
extern NSString * const UPDATE_USER_API_CUSTTEL2; //手機
extern NSString * const UPDATE_USER_API_CREDIT;

extern NSString * const CHECKAUTH_API_PATH;
extern NSString * const CHECKAUTH_API_username;
extern NSString * const CHECKAUTH_API_authcode;

extern NSString * const REAUTHCODE_API_PATH;
extern NSString * const REAUTHCODE_API_username;

extern NSString * const LOG_IN_API_PATH;
extern NSString * const LOG_IN_API_KEY_username;
extern NSString * const LOG_IN_API_KEY_password;
extern NSString * const LOG_IN_API_KEY_CUSTNAME;
extern NSString * const LOG_IN_API_KEY_CUSTTITLE;
extern NSString * const LOG_IN_API_KEY_BIRTHDAY;
extern NSString * const LOG_IN_API_KEY_EMAIL;
extern NSString * const LOG_IN_API_KEY_CAREER;
extern NSString * const LOG_IN_API_KEY_CARD;
extern NSString * const LOG_IN_API_KEY_TIMEOUT;

extern NSString * const FORGET_PASSWORD_API_PATH;
extern NSString * const FORGET_PASSWORD_KEY_account;

extern NSString * const PUSH_API_PATH;
extern NSString * const PUSH_API_KEY_imei;
extern NSString * const PUSH_API_KEY_platform;
extern NSString * const PUSH_API_KEY_osversion;
extern NSString * const PUSH_API_KEY_appversion;
extern NSString * const PUSH_API_KEY_phone;
extern NSString * const PUSH_API_KEY_token;
extern NSString * const PUSH_API_KEY_enable;
extern NSString * const PUSH_API_KEY_career;
extern NSString * const PUSH_API_KEY_credit;
extern NSString * const PUSH_API_KEY_update;
extern NSString * const PUSH_API_KEY_ver;

extern NSString * const EVALUATE_API_PATH;
extern NSString * const EVALUATE_API_KEY_address;
extern NSString * const EVALUATE_API_KEY_teamid;
extern NSString * const EVALUATE_API_KEY_rate;
extern NSString * const EVALUATE_API_KEY_note;
extern NSString * const EVALUATE_API_KEY_takenDate;

extern NSString * const SUGGESTION_API_PATH;
extern NSString * const SUGGESTION_API_KEY_name;
extern NSString * const SUGGESTION_API_KEY_phone;
extern NSString * const SUGGESTION_API_KEY_email;
extern NSString * const SUGGESTION_API_KEY_context;

extern NSString * const FBINFO_API_PATH;
extern NSString * const FBINFO_API_KEY_title;
extern NSString * const FBINFO_API_KEY_description;
extern NSString * const FBINFO_API_KEY_link;
extern NSString * const FBINFO_API_KEY_image;

extern NSString * const ADINFO_API_PATH;
extern NSString * const ADINFO_API_KEY_id;
extern NSString * const ADINFO_API_KEY_link;
extern NSString * const ADINFO_API_KEY_image;
extern NSString * const ADINFO_API_KEY_expire;

// account status
extern int const API_CODE_ACCOUNT_CREATE_ACTIVATED;
extern int const API_CODE_ACCOUNT_CREATE_NEED_ACTIVATION;
extern int const API_CODE_ACCOUNT_LOGIN_INVALID;
extern int const API_CODE_ACCOUNT_CREATE_ID_ALREADY_EXISTED;
extern int const API_CODE_ACCOUNT_CREATE_INCOMPLETE_INFO;
extern int const API_CODE_ACCOUNT_ACTIVATION_INVALID_CODE;
extern int const API_CODE_ACCOUNT_ACTIVATION_INVALID_ACCOUNT;
extern int const API_CODE_ACCOUNT_UNSPECIFY_ERROR;

// order status
extern int const ORDER_STATUS_UNSET;
extern int const ORDER_STATUS_SUCCESS;
extern int const ORDER_STATUS_FAILURE_UNABLE_TO_GEOCODE;
extern int const ORDER_STATUS_FAILURE_NO_CAR;
extern int const ORDER_STATUS_FAILURE_CANCEL_BEFORE_DISPATCH;
extern int const ORDER_STATUS_FAILURE_CANCEL_AFTER_DISPATCH;
extern int const ORDER_STATUS_FAILURE_TIMEOUT;

// user default
extern NSString * const USER_DEFAULT_KEY_BACKEND_URLS;
extern NSString * const USER_DEFAULT_KEY_IS_LOG_IN;
extern NSString * const USER_DEFAULT_KEY_AUTO_LOG_IN;
extern NSString * const USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN;
extern NSString * const USER_DEFAULT_KEY_APP_MODE;

extern NSString * const USER_DEFAULT_KEY_USER_ID;
extern NSString * const USER_DEFAULT_KEY_USER_PWD;
extern NSString * const USER_DEFAULT_KEY_USER_NAME;
extern NSString * const USER_DEFAULT_KEY_USER_TITLE;
extern NSString * const USER_DEFAULT_KEY_USER_EMAIL;
extern NSString * const USER_DEFAULT_KEY_USER_JOB;
extern NSString * const USER_DEFAULT_KEY_USER_BIRTHDAY;
extern NSString * const USER_DEFAULT_KEY_USER_CARD;
extern NSString * const USER_DEFAULT_KEY_USER_IS_MALE;

extern NSString * const USER_DEFAULT_KEY_FB_TITLE;
extern NSString * const USER_DEFAULT_KEY_FB_DESCRIPTION;
extern NSString * const USER_DEFAULT_KEY_FB_LINK;
extern NSString * const USER_DEFAULT_KEY_FB_IMAGE;

extern NSString * const USER_DEFAULT_KEY_BANNER_TOP;
extern NSString * const USER_DEFAULT_KEY_BANNER_BOT;
extern NSString * const USER_DEFAULT_KEY_BANNER_INNER;
extern NSString * const USER_DEFAULT_KEY_MVPN;
extern NSString * const USER_DEFAULT_KEY_USE_MVPN;

// fb
extern NSString * const FBSessionStateChangedNotification;
extern NSString * const SHOW_FB_SHARE_FEED_DIALOG;

// ad
extern NSString * const HOME_VIEW_TOP_BANNER_DEFAULT_AD_ID;
extern NSString * const HOME_VIEW_BOT_BANNER_DEFAULT_AD_ID;
extern NSString * const VIEW_BANNER_DEFAULT_AD_ID;

// notifications
extern NSString * const SHOW_HOME_PAGE_NOTIFICATION;
extern NSString * const HIDE_HOME_PAGE_NOTIFICATION;
extern NSString * const CHANGE_TAB_NOTIFICATION;
extern NSString * const SHOW_MEMBER_RIDE_HISTORY_VIEW;
extern NSString * const SHOW_MEMBER_TRACKING_VIEW;
extern NSString * const SHOW_MEMBER_CONTACT_VIEW;
extern NSString * const REFRESH_AD_NOTIFICATION;
extern NSString * const ORDER_CANCELLED_NOTIFICATION;
extern NSString * const ORDER_SUCCEEDED_NOTIFICATION;
extern NSString * const SIGN_IN_SUCCESS_NOTIFICATION;
extern NSString * const RECEIVED_AD_INFO;

// files
extern NSString * const FILE_AD_INFO;

// others
extern NSString * const MEMBER_MINI_SITE_URL;
extern int        const TAXI_ORDER_VALID_DURATION;
extern NSString * const DISTRICT_AUTO_DETECT_TEXT;
extern BOOL       const IS_DEBUG_MODE;
extern NSString * const DEFAULT_APP_STORE_LINK;
extern BOOL       const FORWARD_GEOCODE_ALLOW_PARTIAL_MATCH;

// test flight
extern NSString * const TF_CHECKPOINT_ORDER_BY_INTERNET;
extern NSString * const TF_CHECKPOINT_ORDER_BY_PHONE;
extern NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS;
extern NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_SUBMIT_ORDER;
extern NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_ADD_FAVORITE;
extern NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS;
extern NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_MANUAL_EDIT;
extern NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_SUBMIT_ORDER;
extern NSString * const TF_CHECKPOINT_ORDER_BY_FAVORITE;
extern NSString * const TF_CHECKPOINT_ORDER_BY_FAVORITE_PICK_ONE;
extern NSString * const TF_CHECKPOINT_ORDER_BY_HISTORY;
extern NSString * const TF_CHECKPOINT_ORDER_BY_HISTORY_PICK_ONE;
extern NSString * const TF_CHECKPOINT_ORDER_BY_LANDMARK;
extern NSString * const TF_CHECKPOINT_ORDER_BY_LANDMARK_PICK_ONE;
extern NSString * const TF_CHECKPOINT_ORDER_MANUAL_CANCEL;

extern NSString * const TF_CHECKPOINT_MEMBER_PAST_RECORDS;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_GET_TAXI_POS;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_SMS;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_CANCEL_ORDER;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_SHOW_TRACK;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_START_RECORDING;
extern NSString * const TF_CHECKPOINT_MEMBER_TRACKING_CLEAR_TRACK;
extern NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION;
extern NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION_SUBMIT;
extern NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION_CLEAR;

extern NSString * const TF_CHECKPOINT_HOMEPAGE_INTERNET;
extern NSString * const TF_CHECKPOINT_HOMEPAGE_MEMBER;
extern NSString * const TF_CHECKPOINT_HOMEPAGE_MESSAGE;
extern NSString * const TF_CHECKPOINT_HOMEPAGE_PHONE;
extern NSString * const TF_CHECKPOINT_HOMEPAGE_RATING;
extern NSString * const TF_CHECKPOINT_HOMEPAGE_SHARE;

extern NSString * const TF_CHECKPOINT_RATING_ADD_FAVORITE;
extern NSString * const TF_CHECKPOINT_RATING_STAR_CHANGED;
extern NSString * const TF_CHECKPOINT_RATING_SUBMIT;
extern NSString * const TF_CHECKPOINT_RATING_CLEAR;

extern NSString * const TF_CHECKPOINT_SHARE_SUBMIT;
extern NSString * const TF_CHECKPOINT_SHOW_HOME_PAGE;
extern NSString * const TF_CHECKPOINT_AD_INNER_BANNER_PRESSED;




//edited by kiki Huang 2013.12.19
extern NSString * const TAXI_PLAYGAME_SESSION;
extern NSString * const TAXI_TICKET_SESSION;
extern NSString * const TAXI_CM5_SESSION;
extern NSString * const TAXI_FREEWAY_SESSION;
extern NSString * const TAXI_INTRO_UI_SESSION;
extern NSString * const TAXI_MENU_UI_BUTTONIMG_SESSION;
extern NSString * const TAXI_PUSH_URL_SESSION;
extern NSString * const RELIEVE_HOME_PRESENT;
extern NSString * const TAXI_MENU_UI_BUTTONIMG_DOWNLOAD_ERROR_VERSION;
extern NSString * const TAXI_MENU_UI_BUTTONIMG_I5_DEFAULT_VERSION;
extern NSString * const TAXI_MENU_UI_BUTTONIMG_I4_DEFAULT_VERSION;
extern NSString * const TAXI_TABBAR_DISABLE;
extern NSString * const TAXI_TABBAR_ENABLE;

//edited by kiki Huang 2013.12.30 add more if need
typedef enum {
    CALLNETWORK,
    CALL55688,
    MEMBER,
    FREEWAYCOST,
    CARCREADIT,
    MESSAGE,
    TAXIPLAYER,
    TAXITICKET
} TaxiButtonTag;
//#define TaxiButtonTagArray @"網路叫車", @"55688叫車", @"會員專區", @"國道收費試算", @"乘車紅利兌換", @"訊息快遞" ,@"大玩家", @"酬賓卷",nil
#define TaxiButtonTagArray @"A_1", @"A_2", @"A_3", @"A_4", @"A_5", @"A_6" ,@"A_7" ,@"A_8" ,nil


#define TaxiMenuDefaultTag @"menuButton0.png", @"menuButton7.png", @"menuButton2.png", @"menuButton1.png", @"menuButton3.png", @"menuButton6.png" ,@"menuButton4.png" ,@"menuButton5.png" ,nil
