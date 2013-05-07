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

@interface FilterViewCell()

@end

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

- (void)setTextTitle:(NSString *)text
{
    textTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    textTitleLabel.hidden = NO;
    textTitleLabel.text = text;
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
        
        //infoImageView.hidden = NO;
        subTitleLabel.hidden = NO;
        textTitleLabel.hidden = NO;
        Places *place = [dict objectForKey:@"value"];
        textTitleLabel.text = place.text;
        subTitleLabel.text = place.city;
        infoImageView.image = nil;
        //
        //      Check image cache local
        //
        NSArray *pathArray = [place.image componentsSeparatedByString:@"/"];
        NSString *fileName = @"";
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([pathArray count] > 0)
        {
            fileName = [pathArray objectAtIndex:[pathArray count] - 1];
        }
        if ([fileName isEqualToString:@""] == FALSE)
        {
            
            imagePath = [[NSString alloc] initWithFormat:@"%@/%@/%@",LIBRARYCACHESDIRECTORY,@"Images",fileName];
            if ([fileManager fileExistsAtPath:imagePath])
            {
                infoImageView.hidden = NO;
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
                infoImageView.image = image;
                [image release];
                fileName = nil;
                [imagePath release];
                imagePath = nil;
                return;
            }
        }
        fileName = nil;
        //
        //      if no image cache => call downloading image
        //
        [loadingView startAnimating];
        activeDownload = [[NSMutableData alloc]init];
        
        NSURLRequest *imgRequest = [[NSURLRequest alloc]
                                 initWithURL: [NSURL URLWithString:[place.image stringByReplacingOccurrencesOfString:@": //" withString:@"://"]]
                                 cachePolicy:             NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                 timeoutInterval: 60
                                 ];
        
        imageConnection =  [[NSURLConnection alloc] initWithRequest:imgRequest delegate:self];
        
        [imgRequest release];
    }
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //
	// Clear the activeDownload property to allow later attempts
    //
    [activeDownload release];
    activeDownload = nil;
    
    //
    // Release the connection now that it's finished
    //
    [imageConnection release];
    imageConnection = nil;
    
    [imagePath release];
    imagePath = nil;
    
    [loadingView stopAnimating];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //
    // Set appIcon and clear temporary data/image
    //
    UIImage *image = [[UIImage alloc] initWithData:activeDownload];
    infoImageView.hidden = NO;
    if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
	{
        CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
		UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		infoImageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {
        infoImageView.image = image;
    }
    
    if (activeDownload != nil)
    {
        [activeDownload writeToFile:imagePath atomically:YES];
    }
    
    [activeDownload release];
    activeDownload = nil;
    // Release the connection now that it's finished
    [imageConnection release];
    imageConnection = nil;
    [image release];
    image = nil;
    [imagePath release];
    imagePath = nil;
    
    [loadingView stopAnimating];
}


- (void)dealloc
{
    [imagePath release];
    [activeDownload release];
    [imageConnection release];
    [textTitleLabel release];
    [subTitleLabel release];
    [infoImageView release];
    [loadingView release];
    [super dealloc];
}
@end
