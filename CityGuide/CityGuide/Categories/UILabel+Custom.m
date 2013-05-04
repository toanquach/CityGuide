//
//  UILabel+Custom.m
//  CityGuide
//
//  Created by Toan Quach on 5/4/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel(Custom)

+ (void)setHeightForLabel:(UILabel*)newLabel
{
    CGRect frame = [newLabel frame];
    CGSize maximumSize = CGSizeMake(frame.size.width, 9999);
    
    CGSize expectedSize = [newLabel.text sizeWithFont:newLabel.font
                                    constrainedToSize:maximumSize
                                        lineBreakMode:newLabel.lineBreakMode];
    if (expectedSize.width < frame.size.width)
    {
        expectedSize.width = frame.size.width;
    }
    frame.size = expectedSize;
    newLabel.frame = frame;
}

@end
