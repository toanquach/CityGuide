//
//  HomeViewController.h
//  CityGuide
//
//  Created by Mac Mini on 4/30/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"

@interface HomeViewController : UIViewController<MKMapViewDelegate, UISearchBarDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
{
    dispatch_time_t delaySearchUntilQueryUnchangedForTimeOffset;
    MKCircle *circle;
    CLGeocoder *geocoder; // support IOS 5
}

- (void)addPinToMap:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle;

@end
