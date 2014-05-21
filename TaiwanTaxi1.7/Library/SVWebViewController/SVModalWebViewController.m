//
//  SVModalWebViewController.m
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "SVPlayWebViewController.h"
#import "UINavigationController+Customize.h"

@interface SVModalWebViewController ()



@end


@implementation SVModalWebViewController

@synthesize barsTintColor, availableActions, webViewController;

#pragma mark - Initialization


- (id)initWithAddress:(NSString*)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL *)URL {
    self.webViewController = [[SVWebViewController alloc] initWithURL:URL];
    if (self = [super initWithRootViewController:self.webViewController])
    {
        UIButton* leftButton = [self setUpCustomizeButtonWithText:@"回首頁"
                                                             icon:nil
                                                    iconPlacement:CustomizeButtonIconPlacementLeft
                                                           target:webViewController
                                                           action:@selector(doneButtonClicked:)];
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
    return self;
}

//edited by kiki Huang 2013.12.09
- (id)initWithPOST:(NSDictionary *)dict {
    self.webViewController = [[SVWebViewController alloc] initWithPOST:dict];
    if (self = [super initWithRootViewController:self.webViewController])
    {
        UIButton* leftButton = [self setUpCustomizeButtonWithText:@"回首頁"
                                                             icon:nil
                                                    iconPlacement:CustomizeButtonIconPlacementLeft
                                                           target:webViewController
                                                           action:@selector(doneButtonClicked:)];
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
    return self;
}

-(id)initWithPLAYPOST:(NSDictionary*)dict{
    self.playWebViewController = [[SVPlayWebViewController alloc] initWithPOST:dict];
    if (self = [super initWithRootViewController:self.playWebViewController])
    {
        UIButton* leftButton = [self setUpCustomizeButtonWithText:@"回首頁"
                                                             icon:nil
                                                    iconPlacement:CustomizeButtonIconPlacementLeft
                                                           target:self.playWebViewController
                                                           action:@selector(doneButtonClicked:)];
        self.playWebViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
    return self;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.navigationBar.tintColor = self.toolbar.tintColor = self.barsTintColor;
}

- (void)setAvailableActions:(SVWebViewControllerAvailableActions)newAvailableActions {
    self.webViewController.availableActions = newAvailableActions;
}

// had to make another copy because this controller does not use navigation vc
#define CAP_WIDTH 20
- (UIButton*)setUpCustomizeButtonWithText:(NSString *)aString icon:(UIImage *)anIcon iconPlacement:(CustomizeButtonIconPlacement)placement target:(id)target action:(SEL)action
{
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

- (void)doneButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
