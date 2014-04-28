//
//  AddressCell.m
//  TaiwanTaxi
//
//  Created by Kevin Tsai on 12/7/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell

@synthesize addressLabel;
@synthesize resultLabel;
@synthesize infoLabel;

- (void)dealloc
{
    [addressLabel release];
    [resultLabel release];
    [infoLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        addressLabel.minimumFontSize = 10.0f;
        addressLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
