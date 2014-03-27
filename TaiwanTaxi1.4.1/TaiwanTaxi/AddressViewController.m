//
//  AddressViewController.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AddressViewController.h"
#import "SuccessViewController.h"
#import "FailViewController.h"
#import "UINavigationController+Customize.h"
#import "NSString+helper.h"
#import "WaitCarAlertView.h"


@interface AddressViewController ()

@property (nonatomic, retain) NSArray *testDataArray;
@property (nonatomic, retain) NSString *orderSource;
@property (nonatomic, retain) NSString *roadType;
@property (nonatomic, retain) WaitCarAlertViewiOS7 *waitCarAlertViewiOS7;
@property (nonatomic, retain) WaitCarAlertViewWithAD *waitCarAlertViewWithAD;

@end

@implementation AddressViewController

#pragma mark - define

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define REGION_PLIST_KEY_REGION_NAME    @"region"
#define REGION_PLIST_KEY_ZONES_ARRAY    @"zones"

#define CONTENT_VIEW_SIZE_3_5_INCH      367
#define CONTENT_VIEW_SIZE_4_INCH        455

#define REGION_PLIST                    @"tw_regions"
#define DEFAULT_ZONE_VALUE              @"(請選擇)"

#define ALERT_WAITCAR                   21
#define ALERT_FAVORITE                  22
#define ALERT_ROADTYPE                  23
#define ALERT_CUSTOMSECTION             24

#pragma mark - synthesize

@synthesize regionButton;
@synthesize zoneButton;
@synthesize sectionButton;
@synthesize regionLabel;
@synthesize zoneLabel;
@synthesize sectionLabel;
@synthesize myScrollView;
@synthesize nameTextField;
@synthesize teleTextField;
@synthesize streetTextField;
@synthesize sectionTextField;
@synthesize alleyTextField;
@synthesize laneTextField;
@synthesize streetNumberTextField;
@synthesize spLuggageButton;
@synthesize spPetButton;
@synthesize spWheelChairButton;
@synthesize spDrunkButton;
@synthesize psTextField;
@synthesize sendBtn;
@synthesize favoriteBtn;
@synthesize regionPickerView;
@synthesize zonePickerView;
@synthesize regionArray;
@synthesize testDataArray;
@synthesize waitCarAlertView;
@synthesize orderID;
@synthesize fromFavorite;
@synthesize fromHistory;
@synthesize fromLandmark;
@synthesize fromGPS;
@synthesize fromGPS_autoSubmit;
@synthesize sectionPickerView;
@synthesize roadPickerView;
@synthesize sectionArray;
@synthesize roadArray;
//edited by kiki Huang 2014.01.04
@synthesize buttonTag,cm5Dict;
#pragma mark - dealloc

- (void)dealloc {
    [sendBtn release];
    [nameTextField release];
    [teleTextField release];
    [streetTextField release];
    [sectionTextField release];
    [alleyTextField release];
    [laneTextField release];
    [streetNumberTextField release];
    [regionButton release];
    [zoneButton release];
    [spLuggageButton release];
    [spPetButton release];
    [spWheelChairButton release];
    [spDrunkButton release];
    [psTextField release];
    [favoriteBtn release];
    zonePickerView.delegate = nil;
    [zonePickerView release];
    regionPickerView.delegate = nil;
    [regionPickerView release];
    [myScrollView release];
    [regionArray release];
    [regionLabel release];
    [zoneLabel release];
    [testDataArray release];
    waitCarAlertView.delegate = nil;
    [waitCarAlertView release];
    [orderID release];
    [fromFavorite release];
    [fromHistory release];
    [fromLandmark release];
    [fromGPS release];
    
    sectionPickerView.delegate = nil;
    [sectionPickerView release];
    
    roadPickerView.delegate = nil;
    [roadPickerView release];
    
    [sectionLabel release];
    [sectionButton release];
    [sectionArray release];
    [roadArray release];
    [_myView release];
    [_streeTypeRoadButton release];
    [_streetTypeStreetButton release];
    [_paymentCashButton release];
    [_paymentCardButton release];
    [_paymentVoucherButton release];
    [_orderSource release];
    [_cashLabel release];
    [_cardLabel release];
    [_voucherLabel release];
    [_roadButton release];
    [_roadLabel release];
    [_roadType release];
    [_favoriteViewAddition release];
    [_favoriteDisplayNameTextField release];
    
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
    NSLog(@"cm5dict to address %@",self.cm5Dict);
    self.navigationItem.hidesBackButton=YES;
    UIButton* backButton = [self.navigationController setUpCustomizeBackButtonWithText:@"返回"];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [self.notifCenter addObserver:self
                         selector:@selector(taxiInOrderConfirm)
                             name:@"order process"
                           object:nil];
    // Do any additional setup after loading the view from its nib.
    
    // -------------------- navigation bar buttons --------------------
    
    /*
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"載入測試資料", nil)
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:self 
                                                                   action:@selector(loadTestData)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    */
    
    // -------------------- view related --------------------
    
    if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        self.cardLabel.hidden = YES;
        self.voucherLabel.hidden = YES;
        
        self.paymentCardButton.hidden = YES;
        self.paymentVoucherButton.hidden = YES;
        
        self.paymentCashButton.selected = YES;
    }
    
    if([self isRetina4inch] == YES)
        viewHeight = CONTENT_VIEW_SIZE_4_INCH;
    else
        viewHeight = CONTENT_VIEW_SIZE_3_5_INCH;
    
    viewWidth = 320;
    
    CGFloat contentHeight = 0;
    
    // special condition for favorite
    if(self.fromFavorite || self.fromFavorite_create)
    {
        contentHeight = self.favoriteViewAddition.frame.size.height + self.myView.frame.size.height;
        
        [self.myScrollView addSubview:self.favoriteViewAddition];
        
        CGRect frame = self.myView.frame;
        frame.origin.y = CGRectGetMaxY(self.favoriteViewAddition.frame);
        self.myView.frame = frame;
        
        [self.myScrollView addSubview:self.myView];
    }
    else
    {
        contentHeight = self.myView.frame.size.height;
        [self.myScrollView addSubview:self.myView];
    }
    
    self.myScrollView.contentSize = CGSizeMake(viewWidth, contentHeight);
    
    self.trackedViewName = @"Address Screen";
    
    // -------------------- address related --------------------
    
    regionPickerView = [[UIPickerView alloc] init];
    regionPickerView.delegate = self;
    regionPickerView.dataSource = self;
    regionPickerView.showsSelectionIndicator = YES;
    self.regionButton.inputView = self.regionPickerView;
    
    zonePickerView = [[UIPickerView alloc] init];
    zonePickerView.delegate = self;
    zonePickerView.dataSource = self;
    zonePickerView.showsSelectionIndicator = YES;
    self.zoneButton.inputView = self.zonePickerView;
    
    sectionPickerView = [[UIPickerView alloc] init];
    sectionPickerView.delegate = self;
    sectionPickerView.dataSource = self;
    sectionPickerView.showsSelectionIndicator = YES;
    self.sectionButton.inputView = self.sectionPickerView;
    
    roadPickerView = [[UIPickerView alloc] init];
    roadPickerView.delegate = self;
    roadPickerView.dataSource = self;
    roadPickerView.showsSelectionIndicator = YES;
    self.roadButton.inputView = self.roadPickerView;
    
    NSURL *regionURL = [[NSBundle mainBundle] URLForResource:REGION_PLIST withExtension:@"plist"];
    regionArray = [[NSArray alloc] initWithContentsOfURL:regionURL];
    
    currentRegionIndex = 0;
    currentZoneIndex = 0;
    currentRoadIndex = 0;
    
    self.streetTextField.text = @"";
    self.sectionTextField.text = @"";
    self.alleyTextField.text = @"";
    self.laneTextField.text = @"";
    self.streetNumberTextField.text = @"";
    self.psTextField.text = @"";
    self.roadType = @"路";
    
    // -------------------- additional info related --------------------
    
    [self.paymentCashButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.paymentCashButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.paymentCardButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.paymentCardButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.paymentVoucherButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.paymentVoucherButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.spLuggageButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.spLuggageButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.spPetButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.spPetButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.spWheelChairButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.spWheelChairButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    [self.spDrunkButton setImage:[UIImage imageNamed:@"radioOff.png"] forState:UIControlStateNormal];
    [self.spDrunkButton setImage:[UIImage imageNamed:@"radioOn.png"] forState:UIControlStateSelected];
    
    // -------------------- sound --------------------
    
    NSString *successPath = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"wav"];
    NSURL *successURL = [NSURL fileURLWithPath:successPath];
    AudioServicesCreateSystemSoundID((CFURLRef)successURL, &OKSound);
    
    NSString *failPath = [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"wav"];
    NSURL *failURL = [NSURL fileURLWithPath:failPath];
    AudioServicesCreateSystemSoundID((CFURLRef)failURL, &FAILSound);
    
    // -------------------- populate data --------------------
    
    self.orderSource = @"地址訂車";

    self.nameTextField.text = self.manager.userTitle;
    self.teleTextField.text = self.manager.userTel;
    
    self.sectionArray = [NSArray arrayWithObjects:@"(無段)",
                         @"一段",
                         @"二段",
                         @"三段",
                         @"四段",
                         @"五段",
                         @"六段",
                         @"七段",
                         @"八段",
                         @"九段",
                         @"十段",
                         @"(自定)", nil];

    self.roadArray = [NSArray arrayWithObjects:@"路",
                      @"街",
                      @"道",
                      @"自定", nil];
    
    if(self.fromFavorite)
    {
        self.orderSource = @"我的最愛";
        [self loadDataFromFavorite];
        [self.favoriteBtn setTitle:@"儲存變更" forState:UIControlStateNormal];
    }
    
    if(self.fromHistory)
    {
        self.orderSource = @"記錄訂車";
        [self loadDataFromHistory];
    }
    
    if(self.fromLandmark)
    {
        self.orderSource = @"附近地標";
        [self loadDataFromLandmark];
    }
    
    if(self.fromGPS)
    {
        self.orderSource = @"GPS訂車";
        [self loadDataFromGPS];
    }
    
    if(self.fromFavorite_create)
    {
        self.sendBtn.hidden = YES;
        CGPoint center = self.favoriteBtn.center;
        center.x = self.view.bounds.size.width / 2;
        self.favoriteBtn.center = center;
    }
    if (self.cm5Dict) {
        NSLog(@"cm5dict %@",self.cm5Dict);
        [self loadDataFromCM5];
    }
}

- (void)viewDidUnload
{
    [self setSendBtn:nil];
    [self setNameTextField:nil];
    [self setTeleTextField:nil];
    [self setStreetTextField:nil];
    [self setSectionTextField:nil];
    [self setAlleyTextField:nil];
    [self setLaneTextField:nil];
    [self setStreetNumberTextField:nil];
    [self setRegionButton:nil];
    [self setZoneButton:nil];
    [self setSpLuggageButton:nil];
    [self setSpPetButton:nil];
    [self setSpWheelChairButton:nil];
    [self setSpDrunkButton:nil];
    [self setPsTextField:nil];
    [self setFavoriteBtn:nil];
    zonePickerView.delegate = nil;
    [self setZonePickerView:nil];
    regionPickerView.delegate = nil;
    [self setRegionPickerView:nil];
    [self setMyScrollView:nil];
    [self setRegionArray:nil];
    [self setRegionLabel:nil];
    [self setZoneLabel:nil];
    [self setTestDataArray:nil];
    waitCarAlertView.delegate = nil;
    [self setWaitCarAlertView:nil];
    [self setOrderID:nil];
    [self setFromFavorite:nil];
    [self setFromHistory:nil];
    [self setFromLandmark:nil];
    [self setFromGPS:nil];
    sectionPickerView.delegate = nil;
    [self setSectionPickerView:nil];
    roadPickerView.delegate = nil;
    [self setRoadPickerView:nil];
    
    [self setSectionLabel:nil];
    [self setSectionButton:nil];
    [self setSectionArray:nil];
    [self setRoadArray:nil];
    [self setMyView:nil];
    
    AudioServicesDisposeSystemSoundID(OKSound);
    AudioServicesDisposeSystemSoundID(FAILSound);
    
    [self setStreeTypeRoadButton:nil];
    [self setStreetTypeStreetButton:nil];
    [self setPaymentCashButton:nil];
    [self setPaymentCardButton:nil];
    [self setPaymentVoucherButton:nil];
    [self setCashLabel:nil];
    [self setCardLabel:nil];
    [self setVoucherLabel:nil];
    [self setRoadButton:nil];
    [self setRoadLabel:nil];
    [self setFavoriteViewAddition:nil];
    [self setFavoriteDisplayNameTextField:nil];
    currentActiveTextField = nil;
    
    //edited by kiki Huang 2013.12.17
//    self.waitCarAlertViewWithAD.squareADView.delegate = nil;
//    [self.waitCarAlertViewWithAD.squareADView release];
//    self.waitCarAlertViewWithAD.squareADView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //edited by kiki Huang 2014.01.05
    [self subscribeForKeyboardEvents];
    self.nameTextField.text = self.manager.userTitle;
    self.teleTextField.text = self.manager.userTel;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unsubscribeFromKeyboardEvents];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - user interaction

- (IBAction)sendOrderInfo:(id)sender
{
    NSString *road = self.streetTextField.text;
    if(road.length)
    {
        NSString *lastWord = [road substringFromIndex:road.length - 1];
        if([lastWord isEqualToString:@"路"] == NO && [lastWord isEqualToString:@"街"] == NO && [lastWord isEqualToString:@"道"] == NO && currentRoadIndex == self.roadArray.count - 1)
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"您未輸入正確的「路/街/道」名稱，您是否要繼續訂車？"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"確定", nil] autorelease];
            alertView.tag = ALERT_ROADTYPE;
            [alertView show];
            
            return;
        }
    }
    
    [self submitTaxiOrder];
}

- (IBAction)addFavorite:(id)sender 
{
    Favorite *f = nil;
    
    if(self.fromFavorite)
    {
        f = (Favorite *)[self.context objectWithID:self.fromFavorite];
        
        if(f == nil)
            return;
        [SVProgressHUD showSuccessWithStatus:@"儲存成功"];
    }
    else
    {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"地址訂車"
                                                             message:@"已加入我的最愛"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"確定", nil] autorelease];
        alertView.tag = ALERT_FAVORITE;
        [alertView show];
        
        f = [self.orderManager createFavorite];
        f.addedDate = [NSDate date];
        [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_ADD_FAVORITE];
    }
    
    f.name = self.nameTextField.text;
    f.tel = self.teleTextField.text;
    f.region = self.regionLabel.text;
    f.district = [self.zoneLabel.text isEqualToString:DISTRICT_AUTO_DETECT_TEXT] == NO ? self.zoneLabel.text : @"";
    f.road = [self handleRoadType];
    f.section = self.sectionTextField.text;
    f.alley = self.alleyTextField.text;
    f.lane = self.laneTextField.text;
    f.number = self.streetNumberTextField.text;
    f.paidType = self.paymentCardButton.selected ? [NSNumber numberWithInt:OrderPaymentTypeCreditCard] : [NSNumber numberWithInt:OrderPaymentTypeCash];
    f.hasLuggage = [NSNumber numberWithBool:hasLuggage];
    f.hasPet = [NSNumber numberWithBool:hasPet];
    f.hasWheelChair = [NSNumber numberWithBool:hasWheelChair];
    f.hasVoucher = [NSNumber numberWithBool:self.paymentVoucherButton.selected];
    f.isDrunk = [NSNumber numberWithBool:isDrunk];
    f.memo = self.psTextField.text;
    f.fullAddress = [self.orderManager createFullAddressString:f];
    f.displayName = self.favoriteDisplayNameTextField.text;
    
    [self.orderManager save];
}

- (IBAction)regionButtonPressed:(id)sender
{
    [self.regionButton becomeFirstResponder];
}

- (IBAction)zoneButtonPressed:(id)sender 
{
    [self.zoneButton becomeFirstResponder];
}

- (IBAction)sectionButtonPressed:(id)sender
{
    [self.sectionButton becomeFirstResponder];
}

- (IBAction)streetTypeButtonsPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    self.streeTypeRoadButton.selected = (button == self.streeTypeRoadButton && !self.streeTypeRoadButton.selected);
    self.streetTypeStreetButton.selected = (button == self.streetTypeStreetButton && !self.streetTypeStreetButton.selected);
    
    //self.streeTypeRoadButton.selected = button == self.streeTypeRoadButton;
    //self.streetTypeStreetButton.selected = button == self.streetTypeStreetButton;
}

- (IBAction)roadButtonPressed:(id)sender
{
    [self.roadButton becomeFirstResponder];
}

- (IBAction)paymentButtonsPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.paymentCashButton.selected = button == self.paymentCashButton;
    self.paymentCardButton.selected = button == self.paymentCardButton;
    self.paymentVoucherButton.selected = button == self.paymentVoucherButton;
}

- (IBAction)spButtonPressed:(id)sender 
{
    UIButton *button = (UIButton *)sender;
    
    button.selected = !button.selected;
    
    if(button == self.spLuggageButton)
        hasLuggage = button.selected;
    
    if(button == self.spPetButton)
        hasPet = button.selected;
    
    if(button == self.spWheelChairButton)
        hasWheelChair = button.selected;
    
    if(button == self.spDrunkButton)
        isDrunk = button.selected;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == self.regionPickerView)
    {
        return self.regionArray.count;
    }
    
    if(pickerView == self.zonePickerView)
    {
        NSDictionary *dict = [self.regionArray objectAtIndex:currentRegionIndex];
        NSArray *zoneArray = [dict objectForKey:REGION_PLIST_KEY_ZONES_ARRAY];
        return zoneArray.count;
    }
    
    if(pickerView == self.sectionPickerView)
    {
        return self.sectionArray.count;
    }
    
    if(pickerView == self.roadPickerView)
    {
        return self.roadArray.count;
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if(pickerView == self.regionPickerView)
    {
        NSDictionary *dict = [self.regionArray objectAtIndex:row];
        title = [dict objectForKey:REGION_PLIST_KEY_REGION_NAME];
    }
    
    if(pickerView == self.zonePickerView)
    {
        NSDictionary *dict = [self.regionArray objectAtIndex:currentRegionIndex];
        NSArray *zoneArray = [dict objectForKey:REGION_PLIST_KEY_ZONES_ARRAY];
        title = [zoneArray objectAtIndex:row];
    }
    
    if(pickerView == self.sectionPickerView)
    {
        title = [self.sectionArray objectAtIndex:row];
    }
    
    if(pickerView == self.roadPickerView)
    {
        title = [self.roadArray objectAtIndex:row];
    }
    
    return title;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if(pickerView == self.regionPickerView)
    {
        NSDictionary *dict = [self.regionArray objectAtIndex:row];
        title = [dict objectForKey:REGION_PLIST_KEY_REGION_NAME];
        currentRegionIndex = row;
        
        // if the region is changed, we need to default associated zone to first available one
        if([self.regionLabel.text isEqualToString:title] == NO)
        {
            NSDictionary *dict = [self.regionArray objectAtIndex:row];
            NSArray *zoneArray = [dict objectForKey:REGION_PLIST_KEY_ZONES_ARRAY];
            NSString *zone = [zoneArray objectAtIndex:0];
            self.zoneLabel.text = zone;
            currentZoneIndex = 0;
            [self.zonePickerView reloadAllComponents];
            [self.zonePickerView selectRow:currentZoneIndex inComponent:0 animated:NO];
        }
        
        self.regionLabel.text = title;
    }
    
    if(pickerView == self.zonePickerView)
    {
        NSDictionary *dict = [self.regionArray objectAtIndex:currentRegionIndex];
        NSArray *zoneArray = [dict objectForKey:REGION_PLIST_KEY_ZONES_ARRAY];
        title = [zoneArray objectAtIndex:row];
        self.zoneLabel.text = title;
        currentZoneIndex = row;
    }
    
    if(pickerView == self.sectionPickerView)
    {
        title = [self.sectionArray objectAtIndex:row];
        if(row == 0)
        {
            self.sectionTextField.text = @"";
            self.sectionLabel.text = title;
        }
        else if(row == self.sectionArray.count - 1)
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"確定", nil] autorelease];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERT_CUSTOMSECTION;
            [alert show];
            
            self.sectionTextField.text = @"";
            self.sectionLabel.text = title;
        }
        else if(row > 0)
        {
            self.sectionTextField.text = [title substringToIndex:1];
            self.sectionLabel.text = title;
        }
        currentSectionIndex = row;
    }
    
    if(pickerView == self.roadPickerView)
    {
        title = [self.roadArray objectAtIndex:row];
        self.roadType = title;
        self.roadLabel.text = title;
        
        currentRoadIndex = row;
    }
    
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentActiveTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentActiveTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

//modified by kiki Huang 2013.12.17
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.waitCarAlertView)
    {
        if(self.manager.currentOrderID.length && buttonIndex == alertView.firstOtherButtonIndex)
        {
            //modified by kiki Huang 2014.01.12
            [SVProgressHUD showWithStatus:@"取消叫車中..." maskType:SVProgressHUDMaskTypeClear];
            
            [self.manager cancelTaxiOrderWithBlock:self.manager.currentOrderID success:^{
                [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                
                [self.manager processOrderXML:self.manager.currentOrderXML
                                 inputAddress:self.manager.currentOrderInputAddress
                              geocodedAddress:self.manager.currentOrderGeocodedAddress
                               addressMatched:self.manager.currentOrderAddressMatched
                                          lat:self.manager.currentOrderLat
                                          lon:self.manager.currentOrderLon
                                       result:ORDER_STATUS_FAILURE_CANCEL_BEFORE_DISPATCH
                                       cardNo:nil
                                     estimate:nil
                                     duration:CFAbsoluteTimeGetCurrent() - self.manager.currentOrderStartTime];
                
            } failure:^{
                [SVProgressHUD dismiss];
                [self.manager showOrderCancelErrorAlert];
            }];
            
            
        }
    }
    
    if(alertView.tag == ALERT_FAVORITE)
    {
        if(self.fromFavorite_create && buttonIndex == alertView.firstOtherButtonIndex)
            [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(alertView.tag == ALERT_ROADTYPE)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
            [self submitTaxiOrder];
    }
    
    if(alertView.tag == ALERT_CUSTOMSECTION)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSString *userInput = [[alertView textFieldAtIndex:0] text];
            self.sectionLabel.text = userInput;
            self.sectionTextField.text = userInput;
        }
    }
}

- (void)customADdialogButtonTouchUpInside:(CustomAlertViewWithAD *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_WAITCAR)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:TAXI_TABBAR_ENABLE object:self];
        if(self.manager.currentOrderID.length && buttonIndex == 0) // 0:cancel
        {
            //modified by kiki Huang 2014.01.12
            [SVProgressHUD showWithStatus:@"取消叫車中..." maskType:SVProgressHUDMaskTypeClear];
            
            [self.manager cancelTaxiOrderWithBlock:self.manager.currentOrderID success:^{
                [SVProgressHUD showSuccessWithStatus:@"取消叫車成功"];
                [self.manager processOrderXML:self.manager.currentOrderXML
                                 inputAddress:self.manager.currentOrderInputAddress
                              geocodedAddress:self.manager.currentOrderGeocodedAddress
                               addressMatched:self.manager.currentOrderAddressMatched
                                          lat:self.manager.currentOrderLat
                                          lon:self.manager.currentOrderLon
                                       result:ORDER_STATUS_FAILURE_CANCEL_BEFORE_DISPATCH
                                       cardNo:nil
                                     estimate:nil
                                     duration:CFAbsoluteTimeGetCurrent() - self.manager.currentOrderStartTime];

            } failure:^{
                [SVProgressHUD dismiss];
                [self.manager showOrderCancelErrorAlert];
            }];
            
                    }
    }
    
    [alertView close];
}

//edited by kiki Huang 2013.12.17---------------------------
#pragma mark - TWMTA Interstitial AD View Delegate
/*
-(void)interstitialViewWillLoadAd:(TWMTAMediaInterstitialView *)view{
    NSLog(@"%@ interstitialViewWillLoadAd", view);
}
-(void)interstitialViewDidLoadAd:(TWMTAMediaInterstitialView *)view{
    NSLog(@"%@ interstitialViewDidLoadAd", view);
    if (self.waitCarAlertViewWithAD.adInterstitialView==nil) {
        CGRect rect = self.waitCarAlertViewWithAD.dialogView.frame;
        CGFloat offset = 100;
        if (IS_IPHONE_5) {
            offset =130;
        }
        self.waitCarAlertViewWithAD.dialogView.frame = CGRectMake(rect.origin.x, rect.origin.y-offset, rect.size.width, rect.size.height);
        [self.waitCarAlertViewWithAD setupInterstitialView:CGSizeMake(_interstitialView.frame.size.width, _interstitialView.frame.size.height)];
        [_interstitialView showAd:self.waitCarAlertViewWithAD.adInterstitialView];
        self.waitCarAlertViewWithAD.adInterstitialView.userInteractionEnabled = NO;
    }
}
- (void)interstitialViewDidDisappear:(TWMTAMediaInterstitialView *)view
{
    NSLog(@"%@ interstitialViewDidDisappear", view);
    CGFloat offset = 100;
    if (IS_IPHONE_5) {
        offset =130;
    }
    [self.waitCarAlertViewWithAD.adInterstitialView removeFromSuperview];
    _interstitialView.delegate = nil;
    _interstitialView = nil;
    
    CGRect rect = self.waitCarAlertViewWithAD.dialogView.frame;
    self.waitCarAlertViewWithAD.dialogView.frame = CGRectMake(rect.origin.x, rect.origin.y + offset, rect.size.width, rect.size.height);
    self.waitCarAlertViewWithAD.adInterstitialView.userInteractionEnabled = YES;
}*/
//------------------------------------------------------
#pragma mark - keyboard

- (void)subscribeForKeyboardEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unsubscribeFromKeyboardEvents
{
    /* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.myScrollView.contentInset = contentInsets;
    self.myScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    if(currentActiveTextField)
    {
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, currentActiveTextField.frame.origin) )
        {
            [self.myScrollView scrollRectToVisible:currentActiveTextField.frame animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.myScrollView.contentInset = contentInsets;
    self.myScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - misc

- (void)submitTaxiOrder
{
    // test car waiting view
    /*
        WaitCarAlertViewiOS7 *wait = [[WaitCarAlertViewiOS7 alloc] initWithAddress:@"台北市中山區長安東路二段131-1、131-2號" parentView:self.parentViewController.view];
        wait.delegate = self;
        wait.tag = ALERT_WAITCAR;
        [wait show];
        return;
    */
    
    // testing success view
    /*
        SuccessViewController *successViewController=[[SuccessViewController alloc] initWithNibName:@"SuccessViewController" bundle:nil];
        successViewController.carNumber = self.manager.currentOrderCarNumber;
        successViewController.eta = self.manager.currentOrderETA;
        
        [self.navigationController pushViewController:successViewController animated:YES];
        [successViewController release];
        return;
    */
    
    self.sendBtn.enabled = NO;
    
    if(self.streetTextField.text.length == 0 || self.streetNumberTextField.text.length == 0 ||
       [self.zoneLabel.text isEqualToString:DEFAULT_ZONE_VALUE] == YES)
    {
        [SVProgressHUD showErrorWithStatus:@"地址不完整"];
        self.sendBtn.enabled = YES;
        return;
    }
    
    if(self.paymentCashButton.selected == NO && self.paymentCardButton.selected == NO && self.paymentVoucherButton.selected == NO)
    {
        [SVProgressHUD showErrorWithStatus:@"請選擇付費方式"];
        self.sendBtn.enabled = YES;
        return;
    }
    
    [SVProgressHUD showWithStatus:@"確認地址中...."];
    
    // create taxi order object
    self.orderID = [self.orderManager generateOrderID];
    TaxiOrder *order = [self.orderManager createTaxiOrderWithOrderID:orderID];
    order.customerInfo.name = self.nameTextField.text;
    order.customerInfo.title = self.manager.userTitle;
    order.customerInfo.tel = self.teleTextField.text;
    order.callType = [NSNumber numberWithInt:OrderTypeNow];
    
    // dealing with address
    BOOL autoDetectDistrict = YES;
    order.pickupInfo.region = self.regionLabel.text;
    if([self.zoneLabel.text isEqualToString:DISTRICT_AUTO_DETECT_TEXT] == NO)
    {
        order.pickupInfo.district = self.zoneLabel.text;
        autoDetectDistrict = NO;
    }
    order.pickupInfo.road = [self handleRoadType];
    order.pickupInfo.section = self.sectionTextField.text;
    order.pickupInfo.alley = self.alleyTextField.text;
    order.pickupInfo.lane = self.laneTextField.text;
    order.pickupInfo.number = self.streetNumberTextField.text;
    order.pickupInfo.formattedAddress = [self.orderManager createFormattedAddressString:order];
    order.pickupInfo.fullAddress = [self.orderManager createFullAddressString:order];
    self.manager.currentOrderInputAddress = order.pickupInfo.fullAddress;
    
    // other fields
    order.orderInfo.paidType = self.paymentCardButton.selected ? [NSNumber numberWithInt:OrderPaymentTypeCreditCard] : [NSNumber numberWithInt:OrderPaymentTypeCash];
    order.orderInfo.hasLuggage = [NSNumber numberWithBool:hasLuggage];
    order.orderInfo.hasPet = [NSNumber numberWithBool:hasPet];
    order.orderInfo.hasWheelChair = [NSNumber numberWithBool:hasWheelChair];
    order.orderInfo.hasVoucher = [NSNumber numberWithBool:self.paymentVoucherButton.selected];
    order.orderInfo.isDrunk = [NSNumber numberWithBool:isDrunk];
    order.orderInfo.specOrder = [self.orderManager createSpecOrderString:order];
    order.orderInfo.memo = self.psTextField.text;
    
    order.orderStatus = [NSNumber numberWithInt:OrderStatusInitialized];
    [self.orderManager save];
    
    self.manager.currentOrderStartTime = CFAbsoluteTimeGetCurrent();
    
    [self.manager forwardGeocodeAddress:order.pickupInfo.fullAddress
                                   road:order.pickupInfo.road
                                 region:order.pickupInfo.region
                               district:order.pickupInfo.district
                           partialMatch:FORWARD_GEOCODE_ALLOW_PARTIAL_MATCH
                                success:^(NSNumber *lat, NSNumber *lon, NSString *district, NSString *geocodedAddress, BOOL fullyMatched) {
                                    
                                    TaxiOrder *order = [self.orderManager getOrCreateTaxiOrderWithOrderID:orderID];
                                    order.pickupInfo.lat = lat;
                                    order.pickupInfo.lon = lon;
                                    if(autoDetectDistrict && district.length)
                                    {
                                        order.pickupInfo.district = district;
                                        order.pickupInfo.formattedAddress = [self.orderManager createFormattedAddressString:order];
                                    }
                                    order.isGeocoded = [NSNumber numberWithBool:YES];
                                    [self.orderManager save];
                                    
                                    self.manager.currentOrderGeocodedAddress = geocodedAddress;
                                    self.manager.currentOrderLat = lat;
                                    self.manager.currentOrderLon = lon;
                                    self.manager.currentOrderAddressMatched = @(fullyMatched);
                                    
                                    [SVProgressHUD dismiss];
                                    
                                    WaitCarAlertViewWithAD *alert = [[[WaitCarAlertViewWithAD alloc]initWithAddress:order.pickupInfo.fullAddress parentView:self.parentViewController.view]autorelease];
                                    alert.delegate = self;
                                    alert.tag = ALERT_WAITCAR;
                                    self.waitCarAlertViewWithAD = alert;
                                    self.waitCarAlertViewWithAD.userInteractionEnabled = YES;
                                    [self.waitCarAlertViewWithAD show];
                                    
                                    [[NSNotificationCenter defaultCenter]postNotificationName:TAXI_TABBAR_DISABLE object:self];
//                                    self.view.userInteractionEnabled = NO;
//                                    SuccessViewController *successViewController=[[SuccessViewController alloc] initWithNibName:@"SuccessViewController" bundle:nil];
//                                    
//                                    [self.navigationController pushViewController:successViewController animated:YES];
//                                    [successViewController release];

                                    
                                    /*
                                    if([self isRunningiOS7])
                                    {
                                        WaitCarAlertViewiOS7 *alert = [[[WaitCarAlertViewiOS7 alloc] initWithAddress:order.pickupInfo.fullAddress parentView:self.parentViewController.view] autorelease];
                                        alert.delegate = self;
                                        alert.tag = ALERT_WAITCAR;
                                        
                                        self.waitCarAlertViewiOS7 = alert;
                                        [self.waitCarAlertViewiOS7 show];
                                    }
                                    
                                    else
                                    {
                                        WaitCarAlertView *alert = [[WaitCarAlertView alloc] initWithAddress:order.pickupInfo.fullAddress];
                                        self.waitCarAlertView = alert;
                                        [self.waitCarAlertView show];
                                        [alert release];
                                    }*/
                                    
                                    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                                    self.sendBtn.enabled = YES;
                                    
                                    [self.manager submitTaxiOrder:order.orderID success:^{
                                        
                                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                                        //modified by kiki Huang 2014.02.05
                                        [[NSNotificationCenter defaultCenter]postNotificationName:TAXI_TABBAR_ENABLE object:self];
                                        
//                                        if([self isRunningiOS7])
//                                        {
//                                            [self customIOS7dialogButtonTouchUpInside:self.waitCarAlertViewiOS7 clickedButtonAtIndex:-1];
//                                        }
//                                        else
//                                        {
//                                            [self.waitCarAlertView dismissWithClickedButtonIndex:-1 animated:NO];
//                                        }
                                        
                                        //modified by kiki Huang 2014.01.12
                                        [SVProgressHUD dismiss];

                                        [self customADdialogButtonTouchUpInside:self.waitCarAlertViewWithAD clickedButtonAtIndex:-1];
                                        
                                        AudioServicesPlaySystemSound(OKSound);
                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                        
                                        SuccessViewController *successViewController=[[SuccessViewController alloc] initWithNibName:@"SuccessViewController" bundle:nil];
                                        successViewController.carNumber = self.manager.currentOrderCarNumber;
                                        successViewController.eta = self.manager.currentOrderETA;
                                        
                                        [self.navigationController pushViewController:successViewController animated:YES];
                                        [successViewController release];
                                        
                                        [self.manager processOrderXML:self.manager.currentOrderXML
                                                         inputAddress:self.manager.currentOrderInputAddress
                                                      geocodedAddress:self.manager.currentOrderGeocodedAddress
                                                       addressMatched:self.manager.currentOrderAddressMatched
                                                                  lat:self.manager.currentOrderLat
                                                                  lon:self.manager.currentOrderLon
                                                               result:ORDER_STATUS_SUCCESS
                                                               cardNo:self.manager.currentOrderCarNumber
                                                             estimate:self.manager.currentOrderETA
                                                             duration:CFAbsoluteTimeGetCurrent() - self.manager.currentOrderStartTime];
                                        
                                        //editde by kiki Huang 2014.01.15
                                        [[NSUserDefaults standardUserDefaults]setObject:self.orderID forKey:@"currentOrderID"];

                                        
                                    } failure:^{
                                        
                                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                                        
                                        //modifed by kiki Huang 2014.01.12
                                        [[NSNotificationCenter defaultCenter]postNotificationName:TAXI_TABBAR_ENABLE object:self];
                                        [SVProgressHUD dismiss];
                                        
                                        [self customADdialogButtonTouchUpInside:self.waitCarAlertViewWithAD clickedButtonAtIndex:-1];
                                        
//                                        if([self isRunningiOS7])
//                                        {
//                                            [self customIOS7dialogButtonTouchUpInside:self.waitCarAlertViewiOS7 clickedButtonAtIndex:0];
//                                        }
//                                        else
//                                        {
//                                            [self.waitCarAlertView dismissWithClickedButtonIndex:0 animated:NO];
//                                        }
                                        
                                        AudioServicesPlaySystemSound(FAILSound);
                                        
                                        FailViewController *fvc = [[FailViewController alloc] init];
                                        [self.navigationController pushViewController:fvc animated:YES];
                                        [fvc release];
                                        
                                        [self.manager processOrderXML:self.manager.currentOrderXML
                                                         inputAddress:self.manager.currentOrderInputAddress
                                                      geocodedAddress:self.manager.currentOrderGeocodedAddress
                                                       addressMatched:self.manager.currentOrderAddressMatched
                                                                  lat:self.manager.currentOrderLat
                                                                  lon:self.manager.currentOrderLon
                                                               result:ORDER_STATUS_FAILURE_NO_CAR
                                                               cardNo:nil
                                                             estimate:nil
                                                             duration:CFAbsoluteTimeGetCurrent() - self.manager.currentOrderStartTime];
                                        self.sendBtn.enabled = YES;
                                    }];
                                    
                                } failure:^(NSString *message) {
                                    
                                    [SVProgressHUD showErrorWithStatus:message];
                                    self.sendBtn.enabled = YES;
                                    
                                    [self.manager processOrderXML:nil
                                                     inputAddress:self.manager.currentOrderInputAddress
                                                  geocodedAddress:nil
                                                   addressMatched:nil
                                                              lat:nil
                                                              lon:nil
                                                           result:ORDER_STATUS_FAILURE_UNABLE_TO_GEOCODE
                                                           cardNo:nil
                                                         estimate:nil
                                                         duration:CFAbsoluteTimeGetCurrent() - self.manager.currentOrderStartTime];
                                    
                                }];
    
    [self passCheckpoint:TF_CHECKPOINT_ORDER_BY_MANUAL_ADDRESS_SUBMIT_ORDER];
}

- (void)loadDataFromFavorite
{
    if(self.fromFavorite == nil)
        return;
    
    Favorite *f = (Favorite *)[self.context objectWithID:self.fromFavorite];
    
    if(f == nil)
        return;
    
    [self populateFieldsWithName:f.name
                             tel:f.tel
                          region:f.region
                        district:f.district
                            road:f.road
                         section:f.section
                           alley:f.alley
                            lane:f.lane
                          number:f.number
                         payment:f.paidType.intValue
                      hasLuggage:[f.hasLuggage boolValue]
                          hasPet:[f.hasPet boolValue]
                   hasWheelChair:[f.hasWheelChair boolValue]
                      hasVoucher:[f.hasVoucher boolValue]
                         isDrunk:[f.isDrunk boolValue]
                            memo:f.memo];
    
    // special condition for favorite
    NSString *displayName = f.displayName.length ? f.displayName : f.fullAddress;
    self.favoriteDisplayNameTextField.text = displayName;
    
    
}
- (void)loadDataFromCM5{
//    if(self.fromFavorite == nil)
//        return;
//    
//    Favorite *f = (Favorite *)[self.context objectWithID:self.fromFavorite];
//    
//    if(f == nil)
//        return;
    
    if (self.cm5Dict) {
        NSLog(@"cm5dic %@",self.cm5Dict);
        [self populateFieldsWithName:self.manager.userTitle tel:self.manager.userTel
                              region:[cm5Dict objectForKey:@"ADDRCITY"]
                            district:[cm5Dict objectForKey:@"ADDRDIST"]
                                road:[cm5Dict objectForKey:@"ADDRSTREET"]
                             section:[cm5Dict objectForKey:@"ADDRSEG"]
                               alley:[cm5Dict objectForKey:@"ADDRLANE"]//modified by kiki Huang 2014.02.10
                                lane:[cm5Dict objectForKey:@"ADDRALLEY"]//modified by kiki Huang 2014.02.10
                              number:[cm5Dict objectForKey:@"ADDRBLK"]
                             payment:0 hasLuggage:NO hasPet:NO
                       hasWheelChair:NO
                          hasVoucher:NO
                             isDrunk:NO
                                memo:[cm5Dict objectForKey:@"ADDRMORE"]];
    }
}
- (void)loadDataFromHistory
{
    if(self.fromHistory == nil)
        return;
    
    TaxiOrder *o = (TaxiOrder *)[self.context objectWithID:self.fromHistory];
    
    if(o == nil)
        return;
    
    [self populateFieldsWithName:o.customerInfo.name
                             tel:o.customerInfo.tel
                          region:o.pickupInfo.region
                        district:o.pickupInfo.district
                            road:o.pickupInfo.road
                         section:o.pickupInfo.section
                           alley:o.pickupInfo.alley
                            lane:o.pickupInfo.lane
                          number:o.pickupInfo.number
                         payment:o.orderInfo.paidType.intValue
                      hasLuggage:[o.orderInfo.hasLuggage boolValue]
                          hasPet:[o.orderInfo.hasPet boolValue]
                   hasWheelChair:[o.orderInfo.hasWheelChair boolValue]
                      hasVoucher:[o.orderInfo.hasVoucher boolValue]
                         isDrunk:[o.orderInfo.isDrunk boolValue]
                            memo:o.orderInfo.memo];
}

- (void)loadDataFromLandmark
{
    [SVProgressHUD showWithStatus:@"解析地址中..."];
    
    NSDictionary *geometry = [self.fromLandmark objectForKey:@"geometry"];
    NSDictionary *location = [geometry objectForKey:@"location"];
    NSNumber *lat = [location objectForKey:@"lat"];
    NSNumber *lng = [location objectForKey:@"lng"];
    
    [self.manager googleMapReverseGeocodeWithLat:lat lon:lng success:^(NSDictionary *placeInfo) {
        if(self == nil)
            return;
        
        NSArray *components = [placeInfo objectForKey:@"address_components"];
        NSString *region = nil;
        NSString *district = nil;
        NSString *road = nil;
        NSString *number = nil;
        NSDictionary *addressInfo = nil;
        
        for(NSDictionary *info in components)
        {
            NSString *content = [info objectForKey:@"long_name"];
            NSString *type = [[info objectForKey:@"types"] objectAtIndex:0];
            
            DDLogInfo(@"%@", [NSString stringWithFormat:@"value:%@ type:%@", content, type]);
            
            if([type isEqualToString:@"administrative_area_level_1"] == YES
               || [type isEqualToString:@"administrative_area_level_2"] == YES)
                region = content;
            
            if([type isEqualToString:@"locality"] == YES)
                district = content;
            
            if([type isEqualToString:@"route"] == YES)
            {
                road = content;
                addressInfo = [self processThoroughfare:road];
            }
            
            if([type isEqualToString:@"street_number"] == YES)
            {
                NSString *processed = [content stringByReplacingOccurrencesOfString:@"號" withString:@""];
                number = processed;
            }
        }
        
        OrderPayment paymentMothod = OrderPaymentTypeNotSpecified;
        
        // city taxi mode the cash is the only payment option
        if(self.manager.currentAppMode == AppModeCityTaxi)
        {
            paymentMothod = OrderPaymentTypeCash;
        }
        
        [self populateFieldsWithName:self.manager.userTitle
                                 tel:self.manager.userTel
                              region:region
                            district:district
                                road:[addressInfo objectForKey:@"road"]
                             section:[addressInfo objectForKey:@"section"]
                               alley:[addressInfo objectForKey:@"alley"]
                                lane:[addressInfo objectForKey:@"lane"]
                              number:number
                             payment:paymentMothod
                          hasLuggage:NO
                              hasPet:NO
                       hasWheelChair:NO
                          hasVoucher:NO
                             isDrunk:NO
                                memo:[self.fromLandmark objectForKey:@"name"]];
        
        [SVProgressHUD dismiss];
    } failure:^(NSString *message, NSError *error) {
        [SVProgressHUD showErrorWithStatus:message];
    }];
}

- (void)loadDataFromGPS
{
    if(self.fromGPS == nil)
        return;
    
    NSString *region = [self.fromGPS objectForKey:@"region"];
    NSString *district = [self.fromGPS objectForKey:@"district"];
    NSString *number = [[self.fromGPS objectForKey:@"number"] stringByReplacingOccurrencesOfString:@"號" withString:@""];
    NSDictionary *addressInfo = [self processThoroughfare:[self.fromGPS objectForKey:@"road"]];
    
    OrderPayment paymentMothod = OrderPaymentTypeNotSpecified;
    
    // city taxi mode the cash is the only payment option
    if(self.manager.currentAppMode == AppModeCityTaxi)
    {
        paymentMothod = OrderPaymentTypeCash;
    }
    
    [self populateFieldsWithName:self.manager.userTitle
                             tel:self.manager.userTel
                          region:region
                        district:district
                            road:[addressInfo objectForKey:@"road"]
                         section:[addressInfo objectForKey:@"section"]
                           alley:[addressInfo objectForKey:@"alley"]
                            lane:[addressInfo objectForKey:@"lane"]
                          number:number
                         payment:paymentMothod
                      hasLuggage:NO
                          hasPet:NO
                   hasWheelChair:NO
                      hasVoucher:NO
                         isDrunk:NO
                            memo:@""];
    
    if(self.fromGPS_autoSubmit == YES)
    {
        [self performSelector:@selector(sendOrderInfo:)
                   withObject:nil
                   afterDelay:0.3];
    }
}

- (void)loadTestData
{
    /*
     
     [self.waitCarAlertView show];
     
    if(self.testDataArray == nil)
    {
        NSURL *testURL = [[NSBundle mainBundle] URLForResource:@"test_orders" withExtension:@"plist"];
        testDataArray = [[NSArray alloc] initWithContentsOfURL:testURL];
    }
    
    int index = arc4random() % testDataArray.count;
    NSDictionary *testData = [self.testDataArray objectAtIndex:index];
    
    [self populateFieldsWithName:[testData objectForKey:@"name"]
                             tel:[testData objectForKey:@"tel"]
                          region:[testData objectForKey:@"region"]
                        district:[testData objectForKey:@"zone"]
                            road:[testData objectForKey:@"road"]
                         section:[testData objectForKey:@"section"]
                           alley:[testData objectForKey:@"alley"]
                            lane:[testData objectForKey:@"lane"]
                          number:[testData objectForKey:@"number"]
                         payment:[[testData objectForKey:@"useCreditCard"] intValue]
                      hasLuggage:[[testData objectForKey:@"hasLuggage"] boolValue]
                          hasPet:[[testData objectForKey:@"hasPet"] boolValue]
                   hasWheelChair:[[testData objectForKey:@"hasWheelChair"] boolValue]
                      hasVoucher:NO
                         isDrunk:[[testData objectForKey:@"isDrunk"] boolValue]
                            memo:[testData objectForKey:@"memo"]];
     */
}

- (void)populateFieldsWithName:(NSString *)name
                           tel:(NSString *)tel
                        region:(NSString *)region
                      district:(NSString *)district
                          road:(NSString *)road
                       section:(NSString *)section
                         alley:(NSString *)alley
                          lane:(NSString *)lane
                        number:(NSString *)number
                       payment:(int)payment
                    hasLuggage:(BOOL)luggage
                        hasPet:(BOOL)pet
                 hasWheelChair:(BOOL)wheelChair
                    hasVoucher:(BOOL)voucher
                       isDrunk:(BOOL)drunk
                          memo:(NSString *)memo

{
    self.nameTextField.text = name;
    self.teleTextField.text = tel;
    
//    self.regionLabel.text = region;
    [self.regionLabel setText:region];
    NSLog(@"%@",self.regionLabel.text);
    if(self.regionLabel.text.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(region == %@)", self.regionLabel.text];
        
        NSDictionary *target = [[self.regionArray filteredArrayUsingPredicate:predicate] lastObject];
        
        if(target)
        {
            currentRegionIndex = [self.regionArray indexOfObject:target];
            [self.regionPickerView selectRow:currentRegionIndex inComponent:0 animated:NO];
        }
    }
    
    self.zoneLabel.text = district;
    
    if(self.zoneLabel.text.length)
    {
        NSDictionary *target = [self.regionArray objectAtIndex:currentRegionIndex];
        
        NSArray *zones = [target objectForKey:@"zones"];
        
        int zoneIndex = 0;
        for(NSString *zone in zones)
        {
            if([zone isEqualToString:self.zoneLabel.text] == YES)
            {
                break;
            }
            zoneIndex++;
        }
        
        currentZoneIndex = zoneIndex;
        [self.zonePickerView reloadAllComponents];
        [self.zonePickerView selectRow:currentZoneIndex inComponent:0 animated:NO];
    }
    
    if(road.length)
    {
        NSString *lastWord = [road substringFromIndex:road.length - 1];
        
        if([lastWord isEqualToString:@"路"])
        {
            road = [road substringToIndex:road.length - 1];
            self.roadType = @"路";
        }
        else if ([lastWord isEqualToString:@"街"])
        {
            road = [road substringToIndex:road.length - 1];
            self.roadType = @"街";
        }
        else if ([lastWord isEqualToString:@"道"])
        {
            road = [road substringToIndex:road.length - 1];
            self.roadType = @"道";
        }
        else
        {
            self.roadType = @"自定";
        }
        
        self.roadLabel.text = self.roadType;
        for(int i = 0; i < self.roadArray.count; i++)
        {
            if([self.roadLabel.text isEqualToString:[self.roadArray objectAtIndex:i]] == YES)
            {
                currentRoadIndex = i;
                break;
            }
        }
        
        [self.roadPickerView reloadAllComponents];
        [self.roadPickerView selectRow:currentRoadIndex inComponent:0 animated:NO];
    }
    
    self.streetTextField.text = road;
    self.sectionTextField.text = section;
    
    if(self.sectionTextField.text.length)
    {
        self.sectionLabel.text = [NSString stringWithFormat:@"%@段", section];
        for(int i = 0; i < self.sectionArray.count; i++)
        {
            if([self.sectionLabel.text isEqualToString:[self.sectionArray objectAtIndex:i]] == YES)
            {
                currentSectionIndex = i;
                break;
            }
        }
        
        [self.sectionPickerView reloadAllComponents];
        [self.sectionPickerView selectRow:currentSectionIndex inComponent:0 animated:NO];
    }
    else
    {
        currentSectionIndex = 0;
        self.sectionLabel.text = [self.sectionArray objectAtIndex:currentSectionIndex];
        [self.sectionPickerView reloadAllComponents];
        [self.sectionPickerView selectRow:currentSectionIndex inComponent:0 animated:NO];
    }
    
    self.alleyTextField.text = alley;
    self.laneTextField.text = lane;
    self.streetNumberTextField.text = number;
    
    self.paymentVoucherButton.selected = voucher;
    if(self.paymentVoucherButton.selected == NO)
    {
        self.paymentCashButton.selected = payment == OrderPaymentTypeCash;
        self.paymentCardButton.selected = payment == OrderPaymentTypeCreditCard;
    }
    
    if(luggage == YES)
    {
        self.spLuggageButton.selected = YES;
        hasLuggage = YES;
    }
    else
    {
        self.spLuggageButton.selected = NO;
        hasLuggage = NO;
    }
    
    if(pet == YES)
    {
        self.spPetButton.selected = YES;
        hasPet = YES;
    }
    else
    {
        self.spPetButton.selected = NO;
        hasPet = NO;
    }
    
    if(wheelChair == YES)
    {
        self.spWheelChairButton.selected = YES;
        hasWheelChair = YES;
    }
    else
    {
        self.spWheelChairButton.selected = NO;
        hasWheelChair = NO;
    }
    
    if(drunk == YES)
    {
        self.spDrunkButton.selected = YES;
        isDrunk = YES;
    }
    else
    {
        self.spDrunkButton.selected = NO;
        isDrunk = NO;
    }
    
    self.psTextField.text = memo;
}

- (NSDictionary *)processThoroughfare:(NSString *)t
{
    NSString *road = @"";
    NSString *section = @"";
    NSString *alley = @"";
    NSString *lane = @"";
    
    NSRange notFound = NSMakeRange(NSNotFound, 0);
    NSUInteger cursor = 0;
    BOOL roadFound = NO;
    
    NSRange roadRange = [t rangeOfString:@"大道"];
    if(NSEqualRanges(roadRange, notFound) == YES)
    {
        roadRange = [t rangeOfString:@"路"];
        if(NSEqualRanges(roadRange, notFound) == YES)
        {
            roadRange = [t rangeOfString:@"街"];
            if(NSEqualRanges(roadRange, notFound) == NO)
            {
                roadFound = YES;
            }
        }
        else
        {
            roadFound = YES;
        }
    }
    else
    {
        roadFound = YES;
    }
    
    if(roadFound)
    {
        cursor = roadRange.location + roadRange.length;
        road = [t substringWithRange:NSMakeRange(0, cursor)];
    }
    
    NSRange sectRange = [t rangeOfString:@"段"
                                 options:0
                                   range:NSMakeRange(cursor, t.length - cursor)];
    if(NSEqualRanges(sectRange, notFound) == NO)
    {
        section = [t substringWithRange:NSMakeRange(cursor, sectRange.location - cursor)];
        cursor = sectRange.location + sectRange.length;
    }
    
    NSRange alleyRange = [t rangeOfString:@"巷"
                                  options:0
                                    range:NSMakeRange(cursor, t.length - cursor)];
    if(NSEqualRanges(alleyRange, notFound) == NO)
    {
        alley = [t substringWithRange:NSMakeRange(cursor, alleyRange.location - cursor)];
        cursor = alleyRange.location + alleyRange.length;
    }
    
    NSRange laneRange = [t rangeOfString:@"弄"
                                 options:0
                                   range:NSMakeRange(cursor, t.length - cursor)];
    if(NSEqualRanges(laneRange, notFound) == NO)
    {
        lane = [t substringWithRange:NSMakeRange(cursor, laneRange.location - cursor)];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:road forKey:@"road"];
    [result setObject:section forKey:@"section"];
    [result setObject:alley forKey:@"alley"];
    [result setObject:lane forKey:@"lane"];
    
    return result;
}

//- (NSString *)handleRoadType
//{
//    // special condition for road
//    NSString *road = self.streetTextField.text;
//    if(road.length)
//    {
//        NSString *lastWord = [road substringFromIndex:road.length - 1];
//        if([lastWord isEqualToString:@"路"] == NO && [lastWord isEqualToString:@"街"] == NO)
//        {
//            NSString *roadType = @"";
//            if(self.streeTypeRoadButton.selected)
//                roadType = @"路";
//            else if (self.streetTypeStreetButton.selected)
//                roadType = @"街";
//            
//            if(road.length > 2)
//            {
//                NSString *lastTwoWords = [road substringFromIndex:road.length - 2];
//                if([lastTwoWords isEqualToString:@"大道"] == NO)
//                {
//                    road = [NSString stringWithFormat:@"%@%@", self.streetTextField.text, roadType];
//                }
//            }
//            else
//            {
//                road = [NSString stringWithFormat:@"%@%@", self.streetTextField.text, roadType];
//            }
//        }
//    }
//    
//    return road;
//}

- (NSString *)handleRoadType
{
    // special condition for road
    NSString *road = self.streetTextField.text;
    if(road.length)
    {
        NSString *lastWord = [road substringFromIndex:road.length - 1];
        
        if([lastWord isEqualToString:@"路"] == NO &&
           [lastWord isEqualToString:@"街"] == NO &&
           [lastWord isEqualToString:@"道"] == NO)
        {
            if([self.roadType isEqualToString:@"自定"] == NO)
                road = [NSString stringWithFormat:@"%@%@", self.streetTextField.text, self.roadType];
        }
    }
    
    return road;
}

#pragma mark - NSNotification addObserver
//edited by kiki Huang 2013.01.12
- (void)taxiInOrderConfirm {
    [SVProgressHUD showWithStatus:@"等待車子回應任務..." maskType:2];
    self.waitCarAlertViewWithAD.userInteractionEnabled = NO;
}
@end
