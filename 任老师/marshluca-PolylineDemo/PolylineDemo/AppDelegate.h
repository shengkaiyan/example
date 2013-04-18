//
//  AppDelegate.h
//  PolylineDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TrackViewController.h"

typedef void (^GetLocationBlock)(CLLocation *location);

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    GetLocationBlock getLocationBlock;
}

- (void)setGetLocationBlock:(GetLocationBlock)block;
- (void)startLocation;
- (void)stopLocation;

@property (strong, nonatomic) TrackViewController *trackViewController;
// routes points
@property (strong, nonatomic) NSMutableArray* pointsMap;
@property (strong, nonatomic) NSMutableArray* pointsGps;
@property (strong, nonatomic) NSMutableArray* pointsRectify;

// location manager
@property (strong, nonatomic) CLLocationManager* locationManager;

@property (nonatomic)BOOL inBackground;
@property (nonatomic)BOOL isRecording;

@property (strong, nonatomic) UIWindow *window;

extern AppDelegate *appDelegate;

@end
