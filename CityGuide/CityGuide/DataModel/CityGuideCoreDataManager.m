//
//  CityGuideCoreDataManager.m
//  CityGuide
//
//  Created by Toan Quach on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "CityGuideCoreDataManager.h"

@interface CityGuideCoreDataManager()
{
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (retain, nonatomic) NSURL *storeUrl;
@property (retain, nonatomic) NSDictionary *localStoreOptions;
@property (readwrite, strong) NSURL *ubiquityURL;
@property (assign) BOOL persistenStoreIsReady;
@property (strong) NSDictionary *tripObjectIDToCompensation;

@end

@implementation CityGuideCoreDataManager

+ (CityGuideCoreDataManager *)sharedCityGuideCoreDataManager
{
    static dispatch_once_t once;
    static CityGuideCoreDataManager *_sharedCampaignCoreDataManager = nil;
    dispatch_once(&once, ^
    {
                      
        _sharedCampaignCoreDataManager = [[CityGuideCoreDataManager alloc] init];
                      
    });
    
    return _sharedCampaignCoreDataManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(globalQueue, ^{
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:nil];
            
            if (!ubiquityURL) return;
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                self.ubiquityURL = ubiquityURL;
            });
        });
        
        self.localStoreOptions = @{
            NSMigratePersistentStoresAutomaticallyOption : @(YES),
            NSInferMappingModelAutomaticallyOption : @(YES)
        };
        
        self.storeFilename =  @"CityGuideModel.sqlite";
        self.storeUrl = [LIBRARYCACHESURL URLByAppendingPathComponent:self.storeFilename];
    }
    return self;
}

#pragma mark - Save Content

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CityGuideModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    
    if (self.storeUrl == nil)
    {
        [LIBRARYCACHESURL URLByAppendingPathComponent:self.storeFilename];
    }
    // This is the actual store we interact with. It has a separate embedded store which we initialize below.
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                         configuration:nil
                                                                                   URL:self.storeUrl
                                                                               options:self.localStoreOptions
                                                                                 error:&error];
    
    if (!store)
    {
        DLog(@"Could not create/add incremental store. Unresolved error %@, %@", error, [error userInfo]);
        _persistentStoreCoordinator = nil;
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPersistentStoreDidBecomeAvailable object:store];
    
    return _persistentStoreCoordinator;
}

@end
