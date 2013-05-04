//
//  DetailAnnotationViewCell.h
//  CityGuide
//
//  Created by Toan Quach on 5/4/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailAnnotationViewCell : UITableViewCell
{
    IBOutlet UILabel *captionLabel;
    IBOutlet UITextField *textTextField;
    IBOutlet UILabel *infoLabel;
}

- (void)setupViewWithDict:(NSDictionary *)dict;
- (NSString *)getInfoText;

@end
