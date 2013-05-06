//
//  PlaceAnnotation.m
//  CityGuide
//
//  Created by Toan Quach on 4/29/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary {
	
	if ((self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary]))
    {
		self.coordinate = coordinate;
	}
	return self;
}

- (void)dealloc
{
    [title_ release];
    [subtitle_ release];
    
    [super dealloc];
}
@end
