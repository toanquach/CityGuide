//
//  PlaceAnnotation.h
//  CityGuide
//
//  Created by Toan Quach on 4/29/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : MKPlacemark
{
	CLLocationCoordinate2D coordinate_;
	NSString *title_;
	NSString *subtitle_;
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite.
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@end
