//
//  AdBannerView.h
//  TaiwanTaxi
//
//  Created by jason on 2/6/13.
//
//

#import <UIKit/UIKit.h>

@protocol CustomAdBannerViewDelegate<NSObject>
@optional
- (void)bannerButtonPressed:(NSString *)url;
@end

@interface CustomAdBannerView : UIView
{
    int currentIndex;
}

@property (nonatomic, assign) id<CustomAdBannerViewDelegate> delegate;

@end
