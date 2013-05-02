//
//  PlaceAnnotation.h
//  CityGuide
//
//  Created by Toan Quach on 4/29/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic) double distance; // distance from self to userlocation

+ (MKAnnotationView *)getAnnotationViewForAnnotation:(NSObject<MKAnnotation> *)annotation
                                     reuseIdentifier:(NSString *)identifier;

- (id)initWithCoordinate:(CLLocationCoordinate2D)mCoordinate andTitle:(NSString *)mTitle andSubTitle:(NSString *)mSubTitle;

@end
