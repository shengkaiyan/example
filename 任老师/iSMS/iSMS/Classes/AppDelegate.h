//
//  AppDelegate.h
//  iSMS
//
//  Created by Sky on 12-11-30.
//  Copyright (c) 2012年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BWStatusBarOverlay.h"
#import "SmsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    SmsViewController *smsViewController;
    
    UINavigationController *navController;
    
    UITabBarController *tabBarController;
}

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UIWindow *window;

extern AppDelegate *appDelegate;

@end
