//
//  PersonAnnotationView.m
//  carrefour
//
//  Created by jason on 1/31/13.
//  Copyright (c) 2013 jason. All rights reserved.
//

#import "PersonAnnotationView.h"

@implementation PersonAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImage *image = [UIImage imageNamed:@"me"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, 12, 25);
        self.frame = imageView.frame;
        self.opaque = NO;
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}

@end
