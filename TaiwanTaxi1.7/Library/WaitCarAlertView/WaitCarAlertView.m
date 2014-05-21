//
//  WaitCarAlertView.m
//  TaiwanTaxi
//
//  Created by ling tsu hsuan on 7/31/12.
//  Copyright (c) 2012 jtg2078@hotmail.com. All rights reserved.
//

#import "WaitCarAlertView.h"

@interface WaitCarAlertView ()
//- (void)changeToProgressWithMessage:(NSString *)message;
@end

@implementation WaitCarAlertView

- (void)dealloc
{
    [imgView release];
    [indView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDefaultSetting
{
    self = [super initWithTitle:@"搜尋車輛中" 
                        message:@" "
                       delegate:nil 
              cancelButtonTitle:nil otherButtonTitles:@"取消訂車", nil];
    if(self) {
        [self setupCustomView:60];
    }
    return self;
}

- (id)initWithAddress:(NSString *)address
{
    NSString *msg = address.length > 11 ?
    [NSString stringWithFormat:@"上車地址：%@\n\n\n\n", address] : [NSString stringWithFormat:@"上車地址：%@\n\n\n\n\n\n", address];
    
    self = [super initWithTitle:@"搜尋車輛中"
                        message:msg
                       delegate:nil
              cancelButtonTitle:nil otherButtonTitles:@"取消訂車", nil];
    if(self) {
        [self setupCustomView:90];
    }
    return self;
}

- (void)setupCustomView:(CGFloat)y
{
    indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect indFrame = indView.frame;
    indFrame.origin.x = 200;
    indFrame.origin.y = 16;
    indView.frame = indFrame;
    [indView startAnimating];
    [self addSubview:indView];
    
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(80, y, 140, 64)];
    
    imgView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"car00.png"],
                               [UIImage imageNamed:@"car01.png"],
                               [UIImage imageNamed:@"car02.png"], nil];
    
    //動畫全部的播放時間 單位：秒
    imgView.animationDuration = 1;
    //總共要播放幾次，0 = 播放無限循環
    imgView.animationRepeatCount = 0;
    
    [self addSubview:imgView];
    
}

- (void)show
{
    [super show];
    
    //開始播放動畫
    [imgView startAnimating];
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [imgView stopAnimating];
    [indView stopAnimating];
    
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end

@implementation WaitCarAlertViewiOS7

- (id)initWithAddress:(NSString *)address parentView:(UIView *)parentView
{
    self = [super initWithParentView:parentView];
    if (self) {
        [self setupContentView:address];
        [self setButtonTitles:[NSMutableArray arrayWithObjects:@"取消訂車", nil]];
    }
    return self;
}

- (void)setupContentView:(NSString *)address
{
    UIView *view = [[[UIView alloc] init] autorelease];
    view.frame = CGRectMake(0, 0, 260, 10);
    view.backgroundColor = [UIColor blackColor];
    
    // the title
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.frame = CGRectMake(0, 10, 260, 20);
    titleLabel.text = @"搜尋車輛中";
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    // spinner
    UIActivityIndicatorView *indView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    CGRect indFrame = indView.frame;
    indFrame.origin.x = 180;
    indFrame.origin.y = 10;
    indView.frame = indFrame;
    [indView startAnimating];
    
    // address
    UILabel *addressLabel = [[[UILabel alloc] init] autorelease];
    addressLabel.frame = CGRectMake(0, 40, 260, 34);
    addressLabel.text = [NSString stringWithFormat:@"上車地址：%@", address];
    addressLabel.textAlignment = UITextAlignmentCenter;
    addressLabel.numberOfLines = 2;
    addressLabel.font = [UIFont systemFontOfSize:14];
//    addressLabel.backgroundColor = [UIColor orangeColor];
    
    // car
    UIImageView *imgView = [[[UIImageView alloc] init] autorelease];
    imgView.frame = CGRectMake(80, 100, 140, 64);
    imgView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"car00.png"],
                               [UIImage imageNamed:@"car01.png"],
                               [UIImage imageNamed:@"car02.png"], nil];
    //動畫全部的播放時間 單位：秒
    imgView.animationDuration = 1;
    //總共要播放幾次，0 = 播放無限循環
    imgView.animationRepeatCount = 0;
    [imgView startAnimating];

    
    [view addSubview:titleLabel];
    [view addSubview:indView];
    [view addSubview:addressLabel];
    [view addSubview:imgView];
    
    [self setContainerView:view];
}
@end

//edited by kiki Huang 2013.12.17
@implementation WaitCarAlertViewWithAD

- (id)initWithAddress:(NSString *)address parentView:(UIView *)parentView{
    self = [super initWithParentView:parentView];
    if (self) {
        [self setupContentView:address];
//        [self setButtonTitles:[NSMutableArray arrayWithObjects:@"取消訂車", nil]];
    }
    return self;
}
- (void)setupContentView:(NSString *)address
{
    if (IS_IPHONE_5) {
        [self SetupIPhone5UI:address];
    }else
        [self SetupIPhone4UI:address];
}

-(void)SetupIPhone5UI:(NSString*)address{
    UIView *view = [[[UIView alloc] init] autorelease];
    view.frame = CGRectMake(0, 0, 300, 180);
    //    view.backgroundColor = [UIColor blackColor];
    
    // the title
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.frame = CGRectMake(0, 10, 300, 20);
    titleLabel.text = @"搜尋車輛中";
    titleLabel.backgroundColor = [UIColor clearColor];   //added by kiki Huang 2013.12.16
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    // spinner
    UIActivityIndicatorView *indView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    CGRect indFrame = indView.frame;
    indFrame.origin.x = 220;
    indFrame.origin.y = 10;
    indView.frame = indFrame;
    [indView startAnimating];
    
    // address
    UILabel *addressLabel = [[[UILabel alloc] init] autorelease];
    addressLabel.frame = CGRectMake(0, 40, 300, 35);
    addressLabel.text = [NSString stringWithFormat:@"上車地址：%@", address];
    addressLabel.backgroundColor = [UIColor clearColor];  //added by kiki Huang 2013.12.16
    addressLabel.textAlignment = UITextAlignmentCenter;
    addressLabel.numberOfLines = 2;
    addressLabel.font = [UIFont systemFontOfSize:14];
    //    addressLabel.backgroundColor = [UIColor orangeColor];
    
    // car
    UIImageView *imgView = [[[UIImageView alloc] init] autorelease];
    imgView.frame = CGRectMake(80, 80, 140, 64);
    imgView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"car00.png"],
                               [UIImage imageNamed:@"car01.png"],
                               [UIImage imageNamed:@"car02.png"], nil];
    //動畫全部的播放時間 單位：秒
    imgView.animationDuration = 1;
    //總共要播放幾次，0 = 播放無限循環
    imgView.animationRepeatCount = 0;
    [imgView startAnimating];
    
//    CGSize size;
//    if (IS_IPHONE_5) {
//        size = CGSizeMake(300, 250);
//    }else{
//        size = CGSizeMake(230, 190);
//    }
//    UIView *adInterstitialView;
//    adInterstitialView = [[UIView alloc] initWithFrame:CGRectMake(0,
//                                                                  imgView.frame.size.height,
//                                                                  size.width,
//                                                                  size.height)];
//    [adInterstitialView setBackgroundColor:[UIColor blueColor]];
    [view addSubview:titleLabel];
    [view addSubview:indView];
    [view addSubview:addressLabel];
    [view addSubview:imgView];
//    [view addSubview:adInterstitialView];
    [self setContainerView:view];

}

- (void)SetupIPhone4UI:(NSString *)address {
    UIView *view = [[[UIView alloc] init] autorelease];
    view.frame = CGRectMake(0, 0, 230, 160);
    //    view.backgroundColor = [UIColor blackColor];
    
    // the title
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    titleLabel.frame = CGRectMake(0, 7, 230, 15);
    titleLabel.text = @"搜尋車輛中";
    titleLabel.backgroundColor = [UIColor clearColor];   //added by kiki Huang 2013.12.16
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    // spinner
    UIActivityIndicatorView *indView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    CGRect indFrame = indView.frame;
    indFrame.origin.x = 190;
    indFrame.origin.y = 5;
    indView.frame = indFrame;
    [indView startAnimating];
    
    // address
    UILabel *addressLabel = [[[UILabel alloc] init] autorelease];
    addressLabel.frame = CGRectMake(0, 28, 230, 35);
    addressLabel.text = [NSString stringWithFormat:@"上車地址：%@", address];
    addressLabel.backgroundColor = [UIColor clearColor];  //added by kiki Huang 2013.12.16
    addressLabel.textAlignment = UITextAlignmentCenter;
    addressLabel.numberOfLines = 2;
    addressLabel.font = [UIFont systemFontOfSize:13];
    //    addressLabel.backgroundColor = [UIColor orangeColor];
    
    // car
    UIImageView *imgView = [[[UIImageView alloc] init] autorelease];
    imgView.frame = CGRectMake(65, 75, 125, 60);
    imgView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"car00.png"],
                               [UIImage imageNamed:@"car01.png"],
                               [UIImage imageNamed:@"car02.png"], nil];
    //動畫全部的播放時間 單位：秒
    imgView.animationDuration = 1;
    //總共要播放幾次，0 = 播放無限循環
    imgView.animationRepeatCount = 0;
    [imgView startAnimating];
    
    
    [view addSubview:titleLabel];
    [view addSubview:indView];
    [view addSubview:addressLabel];
    [view addSubview:imgView];
    
    [self setContainerView:view];
}

@end
