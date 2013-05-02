//
//  PlaceAnnotation.m
//  CityGuide
//
//  Created by Toan Quach on 4/29/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize hidden;
@synthesize distance;

+ (MKAnnotationView *)getAnnotationViewForAnnotation:(NSObject<MKAnnotation> *)annotation
                                     reuseIdentifier:(NSString *)identifier
{
    // This baseclass returns a MKPinAnnotationView as a default
    // Override this class method if you wish to use a different MKAnnotationView
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:identifier];
    
    pin.pinColor = MKPinAnnotationColorRed;
    
    return pin;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)mCoordinate andTitle:(NSString *)mTitle andSubTitle:(NSString *)mSubTitle
{
    if (self = [super init])
    {
        self.coordinate = mCoordinate;
        self.title = mTitle;
        self.subtitle = mSubTitle;
    }
    return self;
}

- (void)dealloc
{
    [title release];
    [subtitle release];
    
    [super dealloc];
}
@end
