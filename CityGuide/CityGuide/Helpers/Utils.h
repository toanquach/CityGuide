//
//  Utils.h
//  CityGuide
//
//  Created by Mac Mini on 5/2/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Utils : NSObject

//
//      Convert Mile to M
//
+ (int)mileToM:(int)miles;
//
//      Distance from 2 point
//
+ (double)distanceFromTwoPoint:(CLLocation *)startPoint andEndPoint:(CLLocation *)endPoint;

@end
