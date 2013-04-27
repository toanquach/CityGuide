//
//  Places+Custom.h
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Places.h"

@interface Places(Custom)
//
//      update list item to database
//
+ (BOOL)processUpdate:(NSArray *)lists;
//
//      Insert item into database
//
+ (BOOL)insert:(NSDictionary *)dict;
//
//      Delete item
//
+ (BOOL)deleteWithLat:(NSString *)latitude andLong:(NSString *)longitude;
//
//      Search data with key
//
+ (Places *)searchItemWithLat:(NSString *)latitude andLong:(NSString *)longitude;
//
//      Search with name or city
//
+ (NSArray *)searchItemWithKey:(NSString *)keyword;

@end
