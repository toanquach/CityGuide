//
//  Places+Custom.m
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "Places+Custom.h"
#import "CityGuideCoreDataManager.h"
#define kEntityName     @"Places"

@implementation Places(Custom)
//
//      update list item to database
//
+ (BOOL)processUpdate:(NSArray *)lists
{
    //
    //      Update list item
    //
    BOOL success = YES;
    NSManagedObjectContext *managedObjectContext = [[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext];
    
    if (managedObjectContext == nil)
    {
        success = NO;
    }
    @try 
    {
        for (int i=0; i < [lists count]; i++) 
        {
            NSDictionary *dict = [lists objectAtIndex:i];
            [Places insert:dict];
        }
    }
    @catch (NSException *exception) 
    {
        DLog(@"Error: %@", exception.description);
    }
}
//
//      Insert item into database
//
+ (BOOL)insert:(NSDictionary *)dict
{
    Places *obj = nil;
    NSError *error = nil;
    BOOL success = YES;
    NSManagedObjectContext *managedObjectContext = [[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext];
    
    if (managedObjectContext == nil)
    {
        success = NO;
    }
    @try
    {
        
        obj = [NSEntityDescription insertNewObjectForEntityForName:kEntityName
                                            inManagedObjectContext:managedObjectContext];
        
        obj.text = [dict objectForKey:@"text"];
        obj.city = [dict objectForKey:@"city"];
        obj.image = [dict objectForKey:@"image"];
        obj.latitude = [dict objectForKey:@"latitude"];
        obj.longitude = [dict objectForKey:@"longitude"];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",exception.description);
    }
    
    [managedObjectContext save:&error];
    if (error) 
    {
        success = NO;
    }
    else
    {
        success = YES;
    }
    
    return success;
}
//
//      Delete item
//
+ (BOOL)deleteWithLat:(NSString *)latitude andLong:(NSString *)longitude
{
    Places *obj = [Places searchItemWithLat:latitude andLong:longitude];
    //
    //      Check obj valid
    //
    if (obj == nil)
    {
        return NO;
    }
    //
    //      Call update database
    //
    NSError *error = nil;
    [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] deleteObject:obj];
    [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] save:&error];
    //
    //      Check having error
    //
    if (error) 
    {
        return NO;
    }
    
    return YES;
}
//
//      Search data with key
//
+ (Places *)searchItemWithLat:(NSString *)latitude andLong:(NSString *)longitude
{
    Places *obj = nil;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:kEntityName];
    [fetch setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude = %@ AND longitude = %@",latitude, longitude];
    [fetch setPredicate:predicate];
    
    
    NSArray *list = [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] executeFetchRequest:fetch error:nil];
    if ([list count] > 0)
    {
        obj = [[list objectAtIndex:0] retain];
    }
    
    [list release];
    list = nil;
    return [obj autorelease];
}

@end
