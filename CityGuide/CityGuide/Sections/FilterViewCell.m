//
//  FilterViewCell.m
//  CityGuide
//
//  Created by Mac Mini on 5/2/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "FilterViewCell.h"
#import "Places.h"
#import "AFNetworking.h"

@implementation FilterViewCell

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

- (void)setupCellWithPlace:(Places *)place
{
    //
    // custom view and style font
    //
    textTitleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    subTitleLabel.font = [UIFont italicSystemFontOfSize:14.0];
    
    textTitleLabel.text = place.text;
    subTitleLabel.text = place.city;
    infoImageView.image = nil;
    [loadingView startAnimating];
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:place.image]];
    AFImageRequestOperation *imgOperation = [AFImageRequestOperation
                                             imageRequestOperationWithRequest:imgRequest
                                             imageProcessingBlock:^UIImage *(UIImage *image)
     {
         return image;
     }
     success:^(NSURLRequest *imgRequest, NSHTTPURLResponse *response, UIImage *image)
     {
         infoImageView.image = image;
         [loadingView stopAnimating];
     }
     failure:^(NSURLRequest *imgRequest, NSHTTPURLResponse *response, NSError *error)
     {
         NSLog(@"Error getting photo");
         [loadingView stopAnimating];
     }];
    
    [imgOperation start];
}

- (void)dealloc
{
    [textTitleLabel release];
    [subTitleLabel release];
    [infoImageView release];
    [loadingView release];
    [super dealloc];
}
@end
