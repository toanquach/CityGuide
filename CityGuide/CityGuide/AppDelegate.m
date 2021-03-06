//
//  AppDelegate.m
//  CityGuide
//
//  Created by Mac Mini on 4/30/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeViewController.h"

#import "Reachability.h"

@implementation AppDelegate

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
    UIColor *color = [[UIColor alloc] initWithRed:0.496f green:0.504 blue:0.52f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = color;
    [color release];
    //
    //      create folder images
    //
    NSString *imageFolderPath = [[NSString alloc]initWithFormat:@"%@/%@",LIBRARYCACHESDIRECTORY,@"Images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imageFolderPath])
    {
        [fileManager createDirectoryAtPath:imageFolderPath withIntermediateDirectories:YES attributes:0 error:nil];
    }
    [imageFolderPath release];
    
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

#pragma mark - Check network

#pragma mark - reachabilityChanged

-(BOOL)reachable
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.apple.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable)
    {
        return NO;
        
    }
    return YES;
}

- (void)showAlertView:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    alertView = nil;
}

@end
