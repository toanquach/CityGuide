//
//  Utils.m
//  CityGuide
//
//  Created by Mac Mini on 5/2/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "Utils.h"

@implementation Utils

//
//      Convert Mile to M
//
+ (int)mileToM:(int)miles
{
    double km = miles * kMilesToKm;
    
    return (int)(km * 1000);
}
//
//      Distance from 2 point
//
+ (double)distanceFromTwoPoint:(CLLocation *)startPoint andEndPoint:(CLLocation *)endPoint
{
    return [startPoint distanceFromLocation:endPoint];
}

@end
