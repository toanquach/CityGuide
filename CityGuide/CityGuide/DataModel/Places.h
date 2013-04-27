//
//  Places.h
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Places : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * text;

@end
