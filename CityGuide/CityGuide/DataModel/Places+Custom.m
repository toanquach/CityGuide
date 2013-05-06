//
//  Places+Custom.m
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "Places+Custom.h"
#import "CityGuideCoreDataManager.h"
#import "NSDictionary+EmptyString.h"

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
    
    return success;
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
        
        dict = [dict dictionaryByReplacingNullsWithStrings];
        obj.text = [dict objectForKey:@"text"];
        obj.city = [dict objectForKey:@"city"];
        obj.image = [dict objectForKey:@"image"];
        obj.latitude = [NSNumber numberWithDouble:[[dict objectForKey:@"latitude"] doubleValue]];
        obj.longitude = [NSNumber numberWithDouble:[[dict objectForKey:@"longtitude"] doubleValue]];
        obj.address = [dict objectForKey:@"address"];
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
//
//      Search with name or city
//
+ (NSArray *)searchItemWithKey:(NSString *)keyword
{
    NSArray *list = nil;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:kEntityName];
    [fetch setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text CONTAINS[cd] %@ or city CONTAINS[cd] %@", keyword,keyword];//[NSPredicate predicateWithFormat:@"text LIKE '%@'",keyword];
    [fetch setPredicate:predicate];
    
    list = [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] executeFetchRequest:fetch error:nil];
    
    if (list == nil)
    {
        return nil;
    }
    
    return list;
}
//
//      Get all place
//
+ (NSArray *)getAllPlaces
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:kEntityName];
    [fetch setFetchBatchSize:20];
    
    NSArray *list = [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] executeFetchRequest:fetch error:nil];
    
    if (list == nil)
    {
        return nil;
    }
    
    return [list autorelease];
}
//
//
//
+ (NSArray *)selectGroupBy
{
    NSManagedObjectContext *managedObjectContext = [[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext];
    
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:kEntityName];
    NSEntityDescription* entity = [NSEntityDescription entityForName:kEntityName
                                              inManagedObjectContext:managedObjectContext];
    NSAttributeDescription* statusDesc = [entity.attributesByName objectForKey:@"city"];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"text"]; // Does not really matter
    NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
                                                              arguments: [NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName: @"count"];
    [expressionDescription setExpression: countExpression];
    [expressionDescription setExpressionResultType: NSInteger32AttributeType];
    [fetch setPropertiesToFetch:[NSArray arrayWithObjects:statusDesc, expressionDescription, nil]];
    [fetch setPropertiesToGroupBy:[NSArray arrayWithObject:statusDesc]];
    [fetch setResultType:NSDictionaryResultType];
    NSError* error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetch
                                                             error:&error];
    
    [expressionDescription release];
    return results;
}
//
//      Get list place in city
//
+ (NSArray *)selectItemByCity:(NSString *)cityName
{
    NSArray *list = nil;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:kEntityName];
    [fetch setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city = %@", cityName];
    [fetch setPredicate:predicate];
    
    list = [[[CityGuideCoreDataManager sharedCityGuideCoreDataManager] managedObjectContext] executeFetchRequest:fetch error:nil];
    
    if (list == nil)
    {
        return nil;
    }
    
    return [list autorelease];
}
@end
