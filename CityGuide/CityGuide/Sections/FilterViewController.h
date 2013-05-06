//
//  FilterViewController.h
//  CityGuide
//
//  Created by Mac Mini on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    dispatch_time_t delaySearchUntilQueryUnchangedForTimeOffset;
}


@end
