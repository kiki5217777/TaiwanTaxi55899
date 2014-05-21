//
//  UINavigationController+Customize.m
//  testNaviWithCommonBG
//
//  Created by jason on 2011/8/4.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationController+Customize.h"


@implementation UINavigationController (Customize)

#pragma mark -
#pragma mark define

#define MAX_BACK_BUTTON_WIDTH 95
#define CAP_WIDTH 20
#define TEXT_INSET_LEFT_RIGHT 21

#pragma mark -
#pragma mark macro

#define SHOW_LAYER_BORDER(s) s.layer.borderWidth = 2.0f; s.layer.borderColor = [[UIColor redColor] CGColor];

- (UIButton*)setUpCustomizeBackButton {
	// Just like the standard back button, use the title of the previous item as the default back text
	NSString *buttonText = [self checkForInvalidText:self.navigationBar.topItem.title];
	
	return [self setUpCustomizeBackButtonWithText:buttonText];
}

- (UIButton*)setUpCustomizeBackButtonWithText:(NSString *)aString {
	// Create stretchable images for the normal and highlighted states
	UIImage *backButtonImage = [UIImage imageNamed:@"customBackButton"];
	UIImage* buttonImage = [backButtonImage stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
	
	// Create a custom button
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	// Set the title to use the same font and shadow as the standard back button
	button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	button.titleLabel.textColor = [UIColor whiteColor];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	button.titleLabel.shadowColor = [UIColor darkGrayColor];
	
	// Set the break mode to truncate at the end like the standard back button
	button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	
	// Set textLabel alignment from default center to left
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	//SHOW_LAYER_BORDER(button.titleLabel)
	//SHOW_LAYER_BORDER(button)
	
	// Inset the title on the left and right (top, left, bottom, right)
	button.titleEdgeInsets = UIEdgeInsetsMake(0, TEXT_INSET_LEFT_RIGHT, 0, TEXT_INSET_LEFT_RIGHT);
	
	// Make the button as high as the passed in image
	button.frame = CGRectMake(0, 0, 0, buttonImage.size.height);
	
	NSString *buttonText = aString;
	CGSize textSize = [buttonText sizeWithFont:button.titleLabel.font];
	// Change the button's frame. The width is either the width of the new text or the max width
	button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (textSize.width + (TEXT_INSET_LEFT_RIGHT * 2.0)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (TEXT_INSET_LEFT_RIGHT * 2.0)), button.frame.size.height);
	[button setTitle:buttonText forState:UIControlStateNormal];
	button.titleLabel.textColor = [UIColor whiteColor];
	
	// Set the stretchable images as the background for the button
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	
	// Add an action for going back
	[button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (NSString *)checkForInvalidText:(NSString *)aText
{
	NSString *trimmed = [aText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(trimmed.length == 0 || trimmed.length > 10)
		return NSLocalizedString(@"返回", nil);
	return trimmed;
}

- (void)setUpCustomizeAppearence 
{
    
    UINavigationBar *navBar = self.navigationBar;
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        // set the background image of navigation bar
        [navBar setBackgroundImage:[UIImage imageNamed:@"blueNavBar.png"] 
                     forBarMetrics:UIBarMetricsDefault];
        
        // adding shadow right below navigation bar for dept effect
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleBarShadow.png"]];
        shadowImageView.frame = CGRectMake(0, 44, 320, 8);
        [navBar addSubview:shadowImageView];
        [shadowImageView release];
    }
    else
    {
        // set the background image of navigation bar
        CALayer *backgroundImageLayer;
        backgroundImageLayer = [CALayer layer];
        backgroundImageLayer.frame = CGRectMake(0, 0, 320, 44);
        backgroundImageLayer.backgroundColor = [UIColor redColor].CGColor;
        backgroundImageLayer.contents = (id)[[UIImage imageNamed:@"blueNavBar.png"] CGImage];
        backgroundImageLayer.zPosition = -5.0;
        [navBar.layer addSublayer:backgroundImageLayer];
    
    }
}

// With a custom back button, we have to provide the action. We simply pop the view controller
- (IBAction)back:(id)sender{
	[self popViewControllerAnimated:YES];
}

- (UIButton*)setUpCustomizeButtonWithText:(NSString *)aString icon:(UIImage *)anIcon iconPlacement:(CustomizeButtonIconPlacement)placement target:(id)target action:(SEL)action {
	// Create stretchable images for the normal and highlighted states
	UIImage *image = [UIImage imageNamed:@"customButtonRound"];
	UIImage *buttonBackgroundImage = [image stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
	
	// Create a custom button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	// Set the title to use the same font and shadow as the standard back button
	button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	button.titleLabel.textColor = [UIColor whiteColor];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	button.titleLabel.shadowColor = [UIColor darkGrayColor];
	
	// Set the break mode to truncate at the end like the standard back button
	button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	
	// Set textLabel alignment from default center to left
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	// Find out the text's size
	NSString *buttonText = aString;
	CGSize textSize = [buttonText sizeWithFont:button.titleLabel.font];
	
	// Set the stretchable images as the background for the button
	[button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
	
	// Set icon image 
	[button setImage:anIcon forState:UIControlStateNormal];
	
	// Set button text
	[button setTitle:buttonText forState:UIControlStateNormal];
	
	int buttonWidth = 0;
#define MAX_RIGHT_BUTTON_WIDTH 100
#define ICON_SIZE 0
#define ICON_TOP_INSET -1
#define TEXT_TOP_INSET 0
	// for left placement icon
#define ICON_LEFT_INSET_FOR_LEFT_ALIGN 5
#define TEXT_LEFT_INSET_FOR_LEFT_ALIGN_ICON 9
#define TEXT_RIGHT_INSET_FOR_LEFT_ALIGN_ICON 6
	// for right palcement icon
#define TEXT_LEFT_INSET_FOR_RIGHT_ALIGN_ICON 5
#define ICON_RIGHT_INSET_FOR_RIGHT_ALIGN 3
#define TEXT_RIGHT_INSET_FOR_RIGHT_ALIGN_ICON 6
	// Adjust button icon and text inset base on position of image (left or right)
	if(placement == CustomizeButtonIconPlacementLeft) {
		// UIEdgeInsetsMake(top, left, bottom, right)
		button.imageEdgeInsets = UIEdgeInsetsMake(ICON_TOP_INSET, 
												  ICON_LEFT_INSET_FOR_LEFT_ALIGN, 
												  0, 
												  0);
		
		button.titleEdgeInsets = UIEdgeInsetsMake(TEXT_TOP_INSET, 
												  TEXT_LEFT_INSET_FOR_LEFT_ALIGN_ICON, 
												  0, 
												  TEXT_RIGHT_INSET_FOR_LEFT_ALIGN_ICON);
		
		buttonWidth = ICON_LEFT_INSET_FOR_LEFT_ALIGN + ICON_SIZE + TEXT_LEFT_INSET_FOR_LEFT_ALIGN_ICON + textSize.width + TEXT_RIGHT_INSET_FOR_LEFT_ALIGN_ICON;
		
		if(buttonWidth > MAX_RIGHT_BUTTON_WIDTH)
			buttonWidth = MAX_RIGHT_BUTTON_WIDTH;
		
	} else {
		button.titleEdgeInsets = UIEdgeInsetsMake(TEXT_TOP_INSET, 
												  TEXT_LEFT_INSET_FOR_RIGHT_ALIGN_ICON - ICON_SIZE + ICON_RIGHT_INSET_FOR_RIGHT_ALIGN, 
												  0, 
												  TEXT_RIGHT_INSET_FOR_RIGHT_ALIGN_ICON + ICON_SIZE);
		button.imageEdgeInsets = UIEdgeInsetsMake(ICON_TOP_INSET, 
												  TEXT_LEFT_INSET_FOR_RIGHT_ALIGN_ICON + textSize.width + TEXT_RIGHT_INSET_FOR_RIGHT_ALIGN_ICON, 
												  0, 
												  ICON_RIGHT_INSET_FOR_RIGHT_ALIGN);
		
		buttonWidth = TEXT_LEFT_INSET_FOR_RIGHT_ALIGN_ICON + textSize.width + TEXT_RIGHT_INSET_FOR_RIGHT_ALIGN_ICON + ICON_SIZE + ICON_RIGHT_INSET_FOR_RIGHT_ALIGN;
		
		if(buttonWidth > MAX_RIGHT_BUTTON_WIDTH){
			buttonWidth = MAX_RIGHT_BUTTON_WIDTH;
			button.imageEdgeInsets = UIEdgeInsetsMake(ICON_TOP_INSET, buttonWidth - (ICON_RIGHT_INSET_FOR_RIGHT_ALIGN + ICON_SIZE), 0, ICON_RIGHT_INSET_FOR_RIGHT_ALIGN);
		}
	}
	
	button.frame = CGRectMake(0, 
							  0, 
							  buttonWidth, 
							  buttonBackgroundImage.size.height);
	
	//SHOW_LAYER_BORDER(button.titleLabel)
	//SHOW_LAYER_BORDER(button)
	//SHOW_LAYER_BORDER(button.imageView)
	
	// Add corresponding action
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

@end
