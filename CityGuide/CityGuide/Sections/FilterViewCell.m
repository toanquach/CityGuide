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

- (void)setupCellWithDict:(NSDictionary *)dict
{
    //
    //      config
    //
    subTitleLabel.text = @"";
    textTitleLabel.text = @"";
    infoImageView.hidden = YES;
    subTitleLabel.hidden = YES;
    textTitleLabel.hidden = YES;
    //loadingView.hidden = YES;

    NSString *type = [dict objectForKey:@"type"];
    if ([type isEqualToString:@"1"])
    {
        infoImageView.hidden = NO;
        infoImageView.image = nil;
        [loadingView stopAnimating];
        //
        //      group item
        //
        CGRect rect = textTitleLabel.frame;
        rect.origin.x = 20;
        rect.origin.y = 17;
        textTitleLabel.frame = rect;
        
        textTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        textTitleLabel.hidden = NO;
        textTitleLabel.text = [dict objectForKey:@"value"];
    }
    else
    {
        //
        // custom view and style font
        //
        
        CGRect rect = textTitleLabel.frame;
        rect.origin.x = 58;
        rect.origin.y = 7;
        textTitleLabel.frame = rect;
        textTitleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        subTitleLabel.font = [UIFont italicSystemFontOfSize:14.0];
        
        infoImageView.hidden = NO;
        subTitleLabel.hidden = NO;
        textTitleLabel.hidden = NO;
        Places *place = [dict objectForKey:@"value"];
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
