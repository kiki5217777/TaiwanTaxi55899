//
//  UIImage+helper.h
//  TaiwanTaxi
//
//  Created by jason on 8/15/12.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (helper)

+ (void)saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)extension
      inDirectory:(NSString *)directoryPath;

+ (UIImage *)loadImage:(NSString *)fileName
               ofType:(NSString *)extension
          inDirectory:(NSString *)directoryPath;

@end
