//
//  AddressViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BaseViewController.h"
#import "UIPickerViewButton.h"
#import "WaitCarAlertView.h"



@interface AddressViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    int currentRegionIndex;
    int currentZoneIndex;
    int currentSectionIndex;
    int currentRoadIndex;
    BOOL hasLuggage;
    BOOL hasPet;
    BOOL hasWheelChair;
    BOOL isDrunk;
    UITextField *currentActiveTextField;
    
    SystemSoundID OKSound;
    SystemSoundID FAILSound;
    
}

@property (retain, nonatomic) IBOutlet UIView *favoriteViewAddition;
@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (retain, nonatomic) IBOutlet UITextField *favoriteDisplayNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *teleTextField;

@property (retain, nonatomic) IBOutlet UIPickerViewButton *regionButton;
@property (retain, nonatomic) IBOutlet UIPickerViewButton *zoneButton;
@property (retain, nonatomic) IBOutlet UIPickerViewButton *sectionButton;
@property (retain, nonatomic) IBOutlet UIPickerViewButton *roadButton;

@property (retain, nonatomic) IBOutlet UILabel *regionLabel;
@property (retain, nonatomic) IBOutlet UILabel *zoneLabel;
@property (retain, nonatomic) IBOutlet UILabel *sectionLabel;
@property (retain, nonatomic) IBOutlet UILabel *roadLabel;

@property (retain, nonatomic) UIPickerView *regionPickerView;
@property (retain, nonatomic) UIPickerView *zonePickerView;
@property (retain, nonatomic) UIPickerView *sectionPickerView;
@property (retain, nonatomic) UIPickerView *roadPickerView;

@property (retain, nonatomic) IBOutlet UIButton *streeTypeRoadButton;
@property (retain, nonatomic) IBOutlet UIButton *streetTypeStreetButton;
@property (retain, nonatomic) IBOutlet UITextField *streetTextField;
@property (retain, nonatomic) IBOutlet UITextField *sectionTextField;
@property (retain, nonatomic) IBOutlet UITextField *alleyTextField;
@property (retain, nonatomic) IBOutlet UITextField *laneTextField;
@property (retain, nonatomic) IBOutlet UITextField *streetNumberTextField;

- (IBAction)regionButtonPressed:(id)sender;
- (IBAction)zoneButtonPressed:(id)sender;
- (IBAction)sectionButtonPressed:(id)sender;
- (IBAction)streetTypeButtonsPressed:(id)sender;
- (IBAction)roadButtonPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *cashLabel;
@property (retain, nonatomic) IBOutlet UILabel *cardLabel;
@property (retain, nonatomic) IBOutlet UILabel *voucherLabel;

@property (retain, nonatomic) IBOutlet UIButton *paymentCashButton;
@property (retain, nonatomic) IBOutlet UIButton *paymentCardButton;
@property (retain, nonatomic) IBOutlet UIButton *paymentVoucherButton;

- (IBAction)paymentButtonsPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *spLuggageButton;
@property (retain, nonatomic) IBOutlet UIButton *spPetButton;
@property (retain, nonatomic) IBOutlet UIButton *spWheelChairButton;
@property (retain, nonatomic) IBOutlet UIButton *spDrunkButton;
@property (retain, nonatomic) IBOutlet UITextField *psTextField;

- (IBAction)spButtonPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *sendBtn;
@property (retain, nonatomic) IBOutlet UIButton *favoriteBtn;

- (IBAction)sendOrderInfo:(id)sender;
- (IBAction)addFavorite:(id)sender;

@property (retain, nonatomic) NSArray *regionArray;
@property (retain, nonatomic) NSArray *sectionArray;
@property (retain, nonatomic) NSArray *roadArray;
@property (retain, nonatomic) WaitCarAlertView *waitCarAlertView;
@property (retain, nonatomic) NSString *orderID;
@property (retain, nonatomic) NSManagedObjectID *fromFavorite;
@property (retain, nonatomic) NSManagedObjectID *fromHistory;
@property (retain, nonatomic) NSDictionary *fromLandmark;
@property (retain, nonatomic) NSDictionary *fromGPS;
@property (assign, nonatomic) BOOL fromGPS_autoSubmit;
@property (assign, nonatomic) BOOL fromFavorite_create;

//edited by kiki Huang 2014.01.04

@property (nonatomic)NSInteger buttonTag;
@property (retain ,nonatomic) NSDictionary *cm5Dict;
@end
