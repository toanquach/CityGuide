//
//  DetailAnnotationViewController.h
//  CityGuide
//
//  Created by Toan Quach on 5/3/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailAnnotationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) NSDictionary *dictAddress;

@end