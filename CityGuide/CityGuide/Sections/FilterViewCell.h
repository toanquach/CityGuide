//
//  FilterViewCell.h
//  CityGuide
//
//  Created by Mac Mini on 5/2/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Places;

@interface FilterViewCell : UITableViewCell
{
    IBOutlet UILabel *textTitleLabel;
    IBOutlet UILabel *subTitleLabel;
    IBOutlet UIImageView *infoImageView;
    IBOutlet UIActivityIndicatorView *loadingView;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *imagePath;
}
- (void)setupCellWithDict:(NSDictionary *)dict;
- (void)setTextTitle:(NSString *)text;
@end
