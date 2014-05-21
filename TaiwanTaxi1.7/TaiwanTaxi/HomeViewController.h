//
//  HomeViewController.h
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CustomAdBannerView.h"
#import "VponAdBannerView.h"

//edited by kiki Huang 2013.12.12---------------------
#import "TWMTAMediaView.h"
//edited by kiki Huang 2013.12.18
#import "FreewayViewController.h"

//edited by kiki Huang 2013.12.28
#import "AutoButtonManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PECropViewController.h"
//-----------------------------------------------

@interface HomeViewController : BaseViewController <UIAlertViewDelegate, CustomAdBannerViewDelegate, TWMTAMediaViewDelegate,AutoButtonAlretDelegate,NSURLConnectionDataDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,PECropViewControllerDelegate>
{
    AutoButtonManager *autobuttonMaganer;
    UIActionSheet *actionsheet;
    UIImagePickerController *imagePickerController;
    BOOL viewDidLoadFirst;
    UITapGestureRecognizer *tapGesture;
    NSInteger actionsheetIndex;
    UIImageView *leftArrow, *rightArrow;
    
    BOOL isalertShow;
    
}

@property (retain, nonatomic) IBOutlet UIView *centerGridView;
//@property (retain, nonatomic) IBOutlet UIButton *appCallTaxiBtn;
//@property (retain, nonatomic) IBOutlet UIButton *memberAreaBtn;
//@property (retain, nonatomic) IBOutlet UIButton *pointBtn;
//@property (retain, nonatomic) IBOutlet UIButton *telCallTaxi;
//@property (retain, nonatomic) IBOutlet UIButton *ratingBtn;
//@property (retain, nonatomic) IBOutlet UIButton *messageBtn;
//@property (retain, nonatomic) UIImage *topBannerImage;
//@property (retain, nonatomic) UIImage *botBannerImage;
//@property (retain, nonatomic) IBOutlet CustomAdBannerView *adBannerView;
//@property (retain, nonatomic) IBOutlet VponAdBannerView *vponBannerView;



@property (retain, nonatomic) IBOutlet UILabel *carNumberLabel;
@property (retain, nonatomic) IBOutlet UILabel *estimateTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *cancelOrderLabel;
@property (retain, nonatomic) IBOutlet UILabel *taxiCallLabel;

@property (retain, nonatomic) IBOutlet UILabel *bonusOverDateLabel;//edited by kiki Huang 2013.12.10
@property (retain, nonatomic) NSDictionary *adInfoTop;
@property (retain, nonatomic) NSDictionary *adInfoBot;

- (void)configStatusView;

- (IBAction)appCallTaxi:(id)sender;
- (IBAction)memberArea:(id)sender;
- (IBAction)pointBtnPressed:(id)sender;
- (IBAction)telCallTaxi:(id)sender;
- (IBAction)rating:(id)sender;
- (IBAction)messageBtnPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

//edited by kiki Huang 2013.12.09
- (IBAction)taxiPlayButtonPressed:(id)sender;
- (IBAction)taxiTicketButtonPressed:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIScrollView *buttonScrollView;
@property (retain, nonatomic) IBOutlet UIImageView *personBoardImageView;
@property (retain, nonatomic) IBOutlet UIScrollView *originScrollView;
@property (retain, nonatomic) IBOutlet UIButton *personBtn;

@end

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation:(ALAssetRepresentation*)alasset;

@end

@interface UIImage (Extras)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end


