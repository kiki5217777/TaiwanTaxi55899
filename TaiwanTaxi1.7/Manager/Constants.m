//
//  Constants.m
//  TaiwanTaxi
//
//  Created by jason on 8/14/12.
//
//

// JSON backend API related

NSString * const BACKEND_URL_KEY_TW_JSON = @"API";
NSString * const BACKEND_URL_KEY_TW_XML = @"MDS";
NSString * const BACKEND_URL_KEY_CITY_JSON = @"API_CITY";
NSString * const BACKEND_URL_KEY_CITY_XML = @"MDS_CITY";
NSString * const BACKEND_URL_KEY_BONUS = @"BONUS_API";

NSString * const JSON_API_KEY_ok = @"ok";
NSString * const JSON_API_KEY_msg = @"msg";
NSString * const JSON_API_KEY_rsp = @"rsp";
NSString * const JSON_API_KEY_code = @"code";

NSString * const REGISTER_API_PATH = @"api/Register";
NSString * const REGISTER_API_CUSTACCT = @"CUSTACCT";
NSString * const REGISTER_API_CUSTPIN = @"CUSTPIN";
NSString * const REGISTER_API_CUSTNAME = @"CUSTNAME";
NSString * const REGISTER_API_CUSTTITLE = @"CUSTTITLE";
NSString * const REGISTER_API_BIRTHDAY = @"BIRTHDAY";
NSString * const REGISTER_API_EMAIL = @"EMAIL";
NSString * const REGISTER_API_CAREER = @"CAREER";
NSString * const REGISTER_API_AGES = @"AGES";
NSString * const REGISTER_API_PHONETYPE = @"PHONETYPE";
NSString * const REGISTER_API_PHONEMODEL = @"PHONEMODEL";
NSString * const REGISTER_API_CUSTTEL1 = @"CUSTTEL1";
NSString * const REGISTER_API_CUSTTEL2 = @"CUSTTEL2";
NSString * const REGISTER_API_CREDIT = @"CREDIT";

NSString * const UPDATE_USER_API_PATH = @"api/UpdateUser";
NSString * const UPDATE_USER_API_CUSTACCT = @"CUSTACCT";
NSString * const UPDATE_USER_API_CUSTPIN = @"CUSTPIN";
NSString * const UPDATE_USER_API_NEWCUSTPIN = @"NEWCUSTPIN";
NSString * const UPDATE_USER_API_CUSTNAME = @"CUSTNAME";
NSString * const UPDATE_USER_API_CUSTTITLE = @"CUSTTITLE";
NSString * const UPDATE_USER_API_BIRTHDAY = @"BIRTHDAY";
NSString * const UPDATE_USER_API_EMAIL = @"EMAIL";
NSString * const UPDATE_USER_API_CAREER = @"CAREER";
NSString * const UPDATE_USER_API_AGES = @"AGES";
NSString * const UPDATE_USER_API_PHONETYPE = @"PHONETYPE";
NSString * const UPDATE_USER_API_PHONEMODEL = @"PHONEMODEL";
NSString * const UPDATE_USER_API_CUSTTEL1 = @"CUSTTEL1";
NSString * const UPDATE_USER_API_CUSTTEL2 = @"CUSTTEL2";
NSString * const UPDATE_USER_API_CREDIT = @"CREDIT";

NSString * const CHECKAUTH_API_PATH = @"api/CheckAuth";
NSString * const CHECKAUTH_API_username = @"username";
NSString * const CHECKAUTH_API_authcode = @"authcode";

NSString * const REAUTHCODE_API_PATH = @"api/ReAuthCode";
NSString * const REAUTHCODE_API_username = @"username";

NSString * const LOG_IN_API_PATH = @"api/Login";
NSString * const LOG_IN_API_KEY_username = @"username";
NSString * const LOG_IN_API_KEY_password = @"password";
NSString * const LOG_IN_API_KEY_CUSTNAME = @"CUSTNAME";
NSString * const LOG_IN_API_KEY_CUSTTITLE = @"CUSTTITLE";
NSString * const LOG_IN_API_KEY_BIRTHDAY = @"BIRTHDAY";
NSString * const LOG_IN_API_KEY_EMAIL = @"EMAIL";
NSString * const LOG_IN_API_KEY_CAREER = @"CAREER";
NSString * const LOG_IN_API_KEY_CARD = @"CREDIT";
NSString * const LOG_IN_API_KEY_TIMEOUT = @"TIMEOUT";

NSString * const FORGET_PASSWORD_API_PATH = @"api/ForgetPw";
NSString * const FORGET_PASSWORD_KEY_account = @"account";

NSString * const PUSH_API_PATH = @"api/PushMessageInfo";
NSString * const PUSH_API_KEY_imei = @"imei";
NSString * const PUSH_API_KEY_platform = @"platform";
NSString * const PUSH_API_KEY_osversion = @"osversion";
NSString * const PUSH_API_KEY_appversion = @"appversion";
NSString * const PUSH_API_KEY_phone = @"phone";
NSString * const PUSH_API_KEY_token = @"token";
NSString * const PUSH_API_KEY_enable = @"enable";
NSString * const PUSH_API_KEY_career = @"career";
NSString * const PUSH_API_KEY_credit = @"credit";
NSString * const PUSH_API_KEY_update = @"update";
NSString * const PUSH_API_KEY_ver = @"ver";

NSString * const EVALUATE_API_PATH = @"api/Evaluate";
NSString * const EVALUATE_API_KEY_address = @"address";
NSString * const EVALUATE_API_KEY_teamid = @"teamid";
NSString * const EVALUATE_API_KEY_rate = @"rate";
NSString * const EVALUATE_API_KEY_note = @"note";
NSString * const EVALUATE_API_KEY_takenDate = @"takenDate";

NSString * const SUGGESTION_API_PATH = @"api/Suggestion";
NSString * const SUGGESTION_API_KEY_name = @"name";
NSString * const SUGGESTION_API_KEY_phone = @"phone";
NSString * const SUGGESTION_API_KEY_email = @"email";
NSString * const SUGGESTION_API_KEY_context = @"context";

NSString * const FBINFO_API_PATH = @"api/FbInfo";
NSString * const FBINFO_API_KEY_title = @"title";
NSString * const FBINFO_API_KEY_description = @"description";
NSString * const FBINFO_API_KEY_link = @"link";
NSString * const FBINFO_API_KEY_image = @"image";

NSString * const ADINFO_API_PATH = @"api/Ads";
NSString * const ADINFO_API_KEY_id = @"id";
NSString * const ADINFO_API_KEY_link = @"link";
NSString * const ADINFO_API_KEY_image = @"image";
NSString * const ADINFO_API_KEY_expire = @"expire";

int const API_CODE_ACCOUNT_CREATE_ACTIVATED = 1;
int const API_CODE_ACCOUNT_CREATE_NEED_ACTIVATION = 2;
int const API_CODE_ACCOUNT_LOGIN_INVALID = 3;
int const API_CODE_ACCOUNT_CREATE_ID_ALREADY_EXISTED = 4;
int const API_CODE_ACCOUNT_CREATE_INCOMPLETE_INFO = 5;
int const API_CODE_ACCOUNT_ACTIVATION_INVALID_CODE = 6;
int const API_CODE_ACCOUNT_ACTIVATION_INVALID_ACCOUNT = 7;
int const API_CODE_ACCOUNT_UNSPECIFY_ERROR = 99;

// order status
int const ORDER_STATUS_UNSET = 0;
int const ORDER_STATUS_SUCCESS = 1;
int const ORDER_STATUS_FAILURE_UNABLE_TO_GEOCODE = 2;
int const ORDER_STATUS_FAILURE_NO_CAR = 3;
int const ORDER_STATUS_FAILURE_CANCEL_BEFORE_DISPATCH = 4;
int const ORDER_STATUS_FAILURE_CANCEL_AFTER_DISPATCH = 5;
int const ORDER_STATUS_FAILURE_TIMEOUT = 6;

// user default
NSString * const USER_DEFAULT_KEY_BACKEND_URLS = @"userDefaultBackendURLS";
NSString * const USER_DEFAULT_KEY_IS_LOG_IN = @"userDefaultIsLogIn";
NSString * const USER_DEFAULT_KEY_AUTO_LOG_IN = @"userDefaultAutoLogIn";
NSString * const USER_DEFAULT_KEY_PUSH_NOTIF_DEVICE_TOKEN = @"userDefaultPushNotifDeviceToken";
NSString * const USER_DEFAULT_KEY_APP_MODE = @"userDefaultAppMode";

NSString * const USER_DEFAULT_KEY_USER_ID = @"userDefaultUserID";
NSString * const USER_DEFAULT_KEY_USER_PWD = @"userDefaultUserPwd";
NSString * const USER_DEFAULT_KEY_USER_NAME = @"userDefaultUserName";
NSString * const USER_DEFAULT_KEY_USER_TITLE = @"userDefaultUserTitle";
NSString * const USER_DEFAULT_KEY_USER_EMAIL = @"userDefaultUserEmail";
NSString * const USER_DEFAULT_KEY_USER_JOB = @"userDefaultUserJob";
NSString * const USER_DEFAULT_KEY_USER_BIRTHDAY = @"userDefaultUserBirthday";
NSString * const USER_DEFAULT_KEY_USER_CARD = @"userDefaultUserCard";
NSString * const USER_DEFAULT_KEY_USER_IS_MALE = @"userDefaultUserIsMale";

NSString * const USER_DEFAULT_KEY_FB_TITLE = @"userDefaultFBTitle";
NSString * const USER_DEFAULT_KEY_FB_DESCRIPTION = @"userDefaultFBDescription";
NSString * const USER_DEFAULT_KEY_FB_LINK = @"userDefaultFBLink";
NSString * const USER_DEFAULT_KEY_FB_IMAGE = @"userDefaultFBImage";

NSString * const USER_DEFAULT_KEY_BANNER_TOP = @"userDefaultBannerInfoTop";
NSString * const USER_DEFAULT_KEY_BANNER_BOT = @"userDefaultBannerInfoBot";
NSString * const USER_DEFAULT_KEY_BANNER_INNER = @"userDefaultBannerInfoInner";
NSString * const USER_DEFAULT_KEY_MVPN = @"userDefaultMVPN";
NSString * const USER_DEFAULT_KEY_USE_MVPN = @"userDefaultUseMVPN";

// fb
/*
NSString * const FBSessionStateChangedNotification = @"com.facebook.FBSessionStateChangedNotification";
NSString * const SHOW_FB_SHARE_FEED_DIALOG = @"showFBShareFeedDialog";
*/

// ad
NSString * const HOME_VIEW_TOP_BANNER_DEFAULT_AD_ID = @"1";
NSString * const HOME_VIEW_BOT_BANNER_DEFAULT_AD_ID = @"2";
NSString * const VIEW_BANNER_DEFAULT_AD_ID = @"1";

// notification
NSString * const SHOW_HOME_PAGE_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.showHomePage";
NSString * const HIDE_HOME_PAGE_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.hideHomePage";
NSString * const CHANGE_TAB_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.changeTab";
NSString * const SHOW_MEMBER_RIDE_HISTORY_VIEW = @"tw.com.doublex.TaiwanTaxi.rideHistory";
NSString * const SHOW_MEMBER_TRACKING_VIEW = @"tw.com.doublex.TaiwanTaxi.tracking";
NSString * const SHOW_MEMBER_CONTACT_VIEW = @"tw.com.doublex.TaiwanTaxi.contact";
NSString * const REFRESH_AD_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.refreshAds";
NSString * const ORDER_CANCELLED_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.orderCancelled";
NSString * const ORDER_SUCCEEDED_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.orderSucceeded";
NSString * const SIGN_IN_SUCCESS_NOTIFICATION = @"tw.com.doublex.TaiwanTaxi.signInSuccess";
NSString * const RECEIVED_AD_INFO = @"tw.com.doublex.TaiwanTaxi.receivedAdInfo";

// files
NSString * const FILE_AD_INFO = @"ads_info";

// others
NSString * const MEMBER_MINI_SITE_URL = @"m";
int        const TAXI_ORDER_VALID_DURATION = 1200; // 20 minutes
NSString * const DISTRICT_AUTO_DETECT_TEXT = @"區:無法判定";
BOOL       const IS_DEBUG_MODE = NO;
NSString * const DEFAULT_APP_STORE_LINK = @"https://itunes.apple.com/tw/app/55688/id579255069?mt=8&uo=4";
BOOL       const FORWARD_GEOCODE_ALLOW_PARTIAL_MATCH = YES;

// test flight
NSString * const TF_CHECKPOINT_ORDER_BY_INTERNET = @"TF_CHECKPOINT_ORDER_BY_INTERNET";
NSString * const TF_CHECKPOINT_ORDER_BY_PHONE = @"TF_CHECKPOINT_ORDER_BY_PHONE";
NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS = @"TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS";
NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_SUBMIT_ORDER = @"TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_SUBMIT_ORDER";
NSString * const TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_ADD_FAVORITE = @"TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_ADD_FAVORITE";
NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS = @"TF_CHECKPOINT_ORDER_BY_VISUAL_GPS";
NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_MANUAL_EDIT = @"TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_MANUAL_EDIT";
NSString * const TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_SUBMIT_ORDER = @"TF_CHECKPOINT_ORDER_BY_VISUAL_GPS_SUBMIT_ORDER";
NSString * const TF_CHECKPOINT_ORDER_BY_FAVORITE = @"TF_CHECKPOINT_ORDER_BY_FAVORITE";
NSString * const TF_CHECKPOINT_ORDER_BY_FAVORITE_PICK_ONE = @"TF_CHECKPOINT_ORDER_BY_FAVORITE_PICK_ONE";
NSString * const TF_CHECKPOINT_ORDER_BY_HISTORY = @"TF_CHECKPOINT_ORDER_BY_HISTORY";
NSString * const TF_CHECKPOINT_ORDER_BY_HISTORY_PICK_ONE = @"TF_CHECKPOINT_ORDER_BY_HISTORY_PICK_ONE";
NSString * const TF_CHECKPOINT_ORDER_BY_LANDMARK = @"TF_CHECKPOINT_ORDER_BY_LANDMARK";
NSString * const TF_CHECKPOINT_ORDER_BY_LANDMARK_PICK_ONE = @"TF_CHECKPOINT_ORDER_BY_LANDMARK_PICK_ONE";
NSString * const TF_CHECKPOINT_ORDER_MANUAL_CANCEL = @"TF_CHECKPOINT_ORDER_MANUAL_CANCEL";
NSString * const TF_CHECKPOINT_MEMBER_PAST_RECORDS = @"TF_CHECKPOINT_MEMBER_PAST_RECORDS";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING = @"TF_CHECKPOINT_MEMBER_TRACKING";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_GET_TAXI_POS = @"TF_CHECKPOINT_MEMBER_TRACKING_GET_TAXI_POS";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_SMS = @"TF_CHECKPOINT_MEMBER_TRACKING_SMS";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_CANCEL_ORDER = @"TF_CHECKPOINT_MEMBER_TRACKING_CANCEL_ORDER";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_SHOW_TRACK = @"TF_CHECKPOINT_MEMBER_TRACKING_SHOW_TRACK";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_START_RECORDING = @"TF_CHECKPOINT_MEMBER_TRACKING_START_RECORDING";
NSString * const TF_CHECKPOINT_MEMBER_TRACKING_CLEAR_TRACK = @"TF_CHECKPOINT_MEMBER_TRACKING_CLEAR_TRACK";
NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION = @"TF_CHECKPOINT_MEMBER_SUGGESTION";
NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION_SUBMIT = @"TF_CHECKPOINT_MEMBER_SUGGESTION_SUBMIT";
NSString * const TF_CHECKPOINT_MEMBER_SUGGESTION_CLEAR = @"TF_CHECKPOINT_MEMBER_SUGGESTION_CLEAR";
NSString * const TF_CHECKPOINT_HOMEPAGE_INTERNET = @"TF_CHECKPOINT_HOMEPAGE_INTERNET";
NSString * const TF_CHECKPOINT_HOMEPAGE_MEMBER = @"TF_CHECKPOINT_HOMEPAGE_MEMBER";
NSString * const TF_CHECKPOINT_HOMEPAGE_MESSAGE = @"TF_CHECKPOINT_HOMEPAGE_MESSAGE";
NSString * const TF_CHECKPOINT_HOMEPAGE_PHONE = @"TF_CHECKPOINT_HOMEPAGE_PHONE";
NSString * const TF_CHECKPOINT_HOMEPAGE_RATING = @"TF_CHECKPOINT_HOMEPAGE_RATING";
NSString * const TF_CHECKPOINT_HOMEPAGE_SHARE = @"TF_CHECKPOINT_HOMEPAGE_SHARE";
NSString * const TF_CHECKPOINT_RATING_ADD_FAVORITE = @"TF_CHECKPOINT_RATING_ADD_FAVORITE";
NSString * const TF_CHECKPOINT_RATING_STAR_CHANGED = @"TF_CHECKPOINT_RATING_STAR_CHANGED";
NSString * const TF_CHECKPOINT_RATING_SUBMIT = @"TF_CHECKPOINT_RATING_SUBMIT";
NSString * const TF_CHECKPOINT_RATING_CLEAR = @"TF_CHECKPOINT_RATING_CLEAR";
NSString * const TF_CHECKPOINT_SHARE_SUBMIT = @"TF_CHECKPOINT_SHARE_SUBMIT";

NSString * const TF_CHECKPOINT_SHOW_HOME_PAGE = @"TF_CHECKPOINT_SHOW_HOME_PAGE";
NSString * const TF_CHECKPOINT_AD_INNER_BANNER_PRESSED = @"TF_CHECKPOINT_AD_INNER_BANNER_PRESSED";



//edited by kiki Huang 2013.12.20
NSString * const TAXI_PLAYGAME_SESSION = @"api/E55688/doSESSION.aspx";
NSString * const TAXI_TICKET_SESSION = @"TII_FRONTSTAGE/API/TICKET/doCHECK_CONNECT.aspx"; //
NSString * const TAXI_CM5_SESSION = @"TII_FRONTSTAGE/API/PHONE/doCM5.aspx";
NSString * const TAXI_FREEWAY_SESSION = @"API/ETC/doETC_CHK_VER.aspx";
NSString * const TAXI_INTRO_UI_SESSION = @"/stark/Api/GetLeaderPic.aspx";
NSString * const TAXI_MENU_UI_BUTTONIMG_SESSION = @"/stark/Api/GetPackagePic.aspx";
NSString * const TAXI_PUSH_URL_SESSION = @"/HCT/background/api/registerAccount.php";  //api/GetUrl
NSString * const RELIEVE_HOME_PRESENT = @"homePresent";
NSString * const TAXI_MENU_UI_BUTTONIMG_I5_DEFAULT_VERSION = @"2014-06-06 10:33:26";
NSString * const TAXI_MENU_UI_BUTTONIMG_I4_DEFAULT_VERSION = @"2014-06-06 10:33:35";
NSString * const TAXI_MENU_UI_BUTTONIMG_DOWNLOAD_ERROR_VERSION = @"1990-01-17 16:31:03";
NSString * const TAXI_TABBAR_DISABLE = @"taxiTabBarDisable";
NSString * const TAXI_TABBAR_ENABLE = @"taxiTabBarEnable";


