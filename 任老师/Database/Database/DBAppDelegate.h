//
//  DBAppDelegate.h
//  Database
//
//  Created by Sky on 13-4-9.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DB.h"

@class DBViewController;

@interface DBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DBViewController *viewController;

@end
