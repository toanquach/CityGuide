//
//  CityGuideCoreDataManager.h
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Posted whenever the persistent store is ready, as this is done asynchronously
#define kPersistentStoreDidBecomeAvailable (@"kPersistentStoreDidBecomeAvailable")

@interface CityGuideCoreDataManager : NSObject

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong) NSURL *ubiquityURL;

@property (readonly) BOOL persistenStoreIsReady;

@property (copy, nonatomic) NSString *storeFilename;

+ (CityGuideCoreDataManager *)sharedCityGuideCoreDataManager;

- (void)saveContext;

@end
