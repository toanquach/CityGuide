//
//  DetailAnnotationViewCell.m
//  CityGuide
//
//  Created by Toan Quach on 5/4/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "DetailAnnotationViewCell.h"
#import "UILabel+Custom.h"

@implementation DetailAnnotationViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViewWithDict:(NSDictionary *)dict
{
    captionLabel.font = [UIFont boldSystemFontOfSize:14.0];
    infoLabel.font = [UIFont boldSystemFontOfSize:14.0];
    if ([[dict objectForKey:@"Type"] isEqualToString:@"1"])
    {
        captionLabel.text = [dict objectForKey:@"Caption"];
        infoLabel.hidden = YES;
    }
    else
    {
        captionLabel.text = [dict objectForKey:@"Caption"];
        infoLabel.text = [dict objectForKey:@"Info"];
        textTextField.hidden = YES;
        [UILabel setHeightForLabel:infoLabel];
        [UILabel setHeightForLabel:captionLabel];
    }
}

- (NSString *)getInfoText
{
    return textTextField.text;
}

- (void)dealloc
{
    [captionLabel release];
    [textTextField release];
    [infoLabel release];
    [super dealloc];
}
@end
