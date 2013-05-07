//
//  AppDelegate.h
//  CityGuide
//
//  Created by Mac Mini on 4/30/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

-(BOOL)reachable;

- (void)showAlertView:(NSString *)title andMessage:(NSString *)message;

@end
