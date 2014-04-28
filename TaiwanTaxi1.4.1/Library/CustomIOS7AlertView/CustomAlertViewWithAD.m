//
//  CustomAlertViewWithAD.m
//  TaiwanTaxi
//
//  Created by kiki Huang Huang on 13/12/16.
//
//

#import "CustomAlertViewWithAD.h"

@implementation CustomAlertViewWithAD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@synthesize parentView, containerView, dialogView, buttonView;
@synthesize delegate;
@synthesize buttonTitles;

CGFloat static defaultButtonHeight = 50;
CGFloat static defaultButtonSpacerHeightAD = 1;
CGFloat static cornerRadiusAD = 7;

CGFloat buttonHeightAD = 0;
CGFloat buttonSpacerHeightAD = 0;

- (id)initWithParentView: (UIView *)_parentView
{
    self = [super initWithFrame:_parentView.frame];
    if (self) {
        parentView = _parentView;
        delegate = self;
        buttonTitles = [NSMutableArray arrayWithObject:@"取消訂車"];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    dialogView = [self createContainerView];
    
    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
    
    [self addSubview:dialogView];
    [parentView addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         dialogView.layer.opacity = 1.0f;
                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}

- (void)setDelegate: (id)_delegate
{
    delegate = _delegate;
}

// Button has touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    [delegate customADdialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
}

// Default button behaviour
- (void)customADdialogButtonTouchUpInside: (CustomAlertViewWithAD *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Clicked! %d, %d", buttonIndex, [alertView tag]);
    [self close];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DMakeScale(0.6f, 0.6f, 1.0);
                         dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if ([buttonTitles count] > 0) {
        buttonHeightAD = defaultButtonHeight;
        buttonSpacerHeightAD = defaultButtonSpacerHeightAD;
    } else {
        buttonHeightAD = 0;
        buttonSpacerHeightAD = 0;
    }
    
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
//    CGFloat offset = 50.0f;
    
    
    CGSize size;
    
    if (IS_IPHONE_5) {
        size = CGSizeMake(300, 250);
    }else{
        size = CGSizeMake(230, 190);
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeightAD + buttonSpacerHeightAD+size.height;
    
    CGRect adframe;
    CGRect viewframe;
    if (IS_IPHONE_5) {
        adframe = CGRectMake(0, 0, 300, 250);
        viewframe = CGRectMake(0, dialogHeight - buttonHeightAD - buttonSpacerHeightAD-size.height, 300, 250);
    }else{
        adframe = CGRectMake(0, 0, 230, 190);
        viewframe = CGRectMake(0, dialogHeight - buttonHeightAD - buttonSpacerHeightAD-size.height, 230, 190);
    }
    UIView *adContentView = [[UIView alloc]initWithFrame:viewframe];
    adContentView.userInteractionEnabled = NO;
    [adContentView setBackgroundColor:[UIColor whiteColor]];
    
    TWMTAMediaView *squareADView = [[TWMTAMediaView alloc] initWithFrame:adframe
                                                                    slotId:@"H13868204028266D9"
                                                               developerID:@""
                                                                gpsEnabled:YES
                                                                  testMode:NO];
    [squareADView receiveAd];
    [adContentView addSubview:squareADView];
    [squareADView release];
    
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - dialogHeight) / 2, dialogWidth, dialogHeight)];
    NSLog(@"dialogContainer frame %f:%f",dialogContainer.frame.size.width,dialogContainer.frame.size.height);
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
    gradient.cornerRadius = cornerRadiusAD;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadiusAD;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadiusAD + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadiusAD+5)/2, 0 - (cornerRadiusAD+5)/2);
    // ^^^
    
    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeightAD - buttonSpacerHeightAD, dialogContainer.bounds.size.width, buttonSpacerHeightAD)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^
    
    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];
    
   
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    [dialogContainer addSubview:adContentView];
    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

- (void)addButtonsToView: (UIView *)container
{
    CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];
    
    for (int i=0; i<[buttonTitles count]; i++) {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeightAD, buttonWidth, buttonHeightAD)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        
        [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [closeButton.layer setCornerRadius:cornerRadiusAD];
        
        [container addSubview:closeButton];
    }
    
}

//------------------------------------------------------
/*
- (UIView *)setupInterstitialView:(CGSize)_size {
    
//    CGFloat offset = 30.0f;
    CGSize size;
    if (IS_IPHONE_5) {
        size = CGSizeMake(300, 250);
    }else{
        size = CGSizeMake(230, 190);
    }
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeightAD + buttonSpacerHeightAD+size.height;
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    adInterstitialView = [[UIView alloc] initWithFrame:CGRectMake(0,dialogHeight-buttonHeightAD-buttonSpacerHeightAD-size.height,
                                                                  _size.width,
                                                                  _size.height)];
    return adInterstitialView;
}*/

@end
