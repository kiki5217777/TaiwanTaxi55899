//
//  ShareViewController.h
//  TaiwanTaxi
//
//  Created by jason on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"



@interface ShareViewController : BaseViewController <UITextViewDelegate>

@property (retain, nonatomic) IBOutlet UITextView *postMessageTextView;
@property (retain, nonatomic) IBOutlet UIImageView *postImageView;
@property (retain, nonatomic) IBOutlet UILabel *postNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *postCaptionLabel;
@property (retain, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (retain, nonatomic) NSMutableDictionary *postParams;
@property (retain, nonatomic) NSMutableData *imageData;
@property (retain, nonatomic) NSURLConnection *imageConnection;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *shareButton;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;

@end
