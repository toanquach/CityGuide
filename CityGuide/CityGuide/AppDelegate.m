//
//  AppDelegate.m
//  CityGuide
//
//  Created by Mac Mini on 4/26/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeViewController.h"

#import "Reachability.h"

//#import "AFNetworking.h"

@implementation AppDelegate

@synthesize isNetworkAvailable;

- (void)dealloc
{
    [_navigationController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    //
    //      Init Home Page
    //
    HomeViewController *homeViewController = [[[HomeViewController alloc]init] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:homeViewController] autorelease];
    //
    //      Set Root View Controller
    //
    self.window.rootViewController = self.navigationController;
    //
    //      Config Navigation
    //
    self.navigationController.navigationBarHidden   = YES;
    self.navigationController.navigationBar.hidden  = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.496f green:0.504 blue:0.52f alpha:1.0f];
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    self.isNetworkAvailable = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.isNetworkAvailable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.isNetworkAvailable = YES;
        });
    };
    
    [reach startNotifier];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - check network

#pragma mark - reachabilityChanged

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.isNetworkAvailable = YES;
    }
    else
    {
        self.isNetworkAvailable = NO;
    }
}

@end