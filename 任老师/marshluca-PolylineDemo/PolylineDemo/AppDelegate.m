//
//  AppDelegate.m
//  PolylineDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#define DOCUMENTDIRECTORY                           [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]
#define ktime1 30 //定位等待时间
#define ktime2 10//后台线程启动间隔时间


@implementation AppDelegate

@synthesize window = _window;
@synthesize inBackground;

AppDelegate *appDelegate = nil;


-(void)setGetLocationBlock:(GetLocationBlock)block
{
    getLocationBlock = [block copy];
}

- (void)startLocation
{
    [_locationManager startUpdatingLocation];
}

- (void)stopLocation
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark
#pragma mark CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (getLocationBlock && oldLocation) {
        getLocationBlock(newLocation);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"error: %@",error);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appDelegate = self;
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.trackViewController = [[TrackViewController alloc] init];
    [self.window addSubview: self.trackViewController.view];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.pointsGps = [[NSMutableArray alloc] init];
    self.pointsMap = [[NSMutableArray alloc] init];
    self.pointsRectify = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 0;
    
    self.isRecording = NO;
    
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
    NSLog(@"background");
    
    NSMutableString *strLocation = [[NSMutableString alloc] init];
    NSString *adFile = nil;
    
    for(int idx = 0; idx < appDelegate.pointsGps.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsGps objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;
        
        [strLocation appendFormat: @"%f %f; ", latitude, longitude];
    }
    if (strLocation.length) {
        adFile = [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"locationManager.dat"];
        BOOL isWriteFile = [strLocation writeToFile: adFile atomically: YES];
        NSLog(@"isWriteFile locationManager.plist %d", isWriteFile);
    }
    
    [strLocation setString: @""];
    
    for(int idx = 0; idx < appDelegate.pointsMap.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsMap objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;
        
        [strLocation appendFormat: @"%f %f;", latitude, longitude];
    }
    if (strLocation.length) {
        adFile = [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"map.dat"];
        BOOL isWriteFile = [strLocation writeToFile: adFile atomically: YES];
        NSLog(@"isWriteFile map.dat %d", isWriteFile);
    }
    
    [strLocation setString: @""];
    
    for(int idx = 0; idx < appDelegate.pointsRectify.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsRectify objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;
        
        [strLocation appendFormat: @"%f %f;", latitude, longitude];
    }
    if (strLocation.length) {
        adFile = [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"rectify.dat"];
        BOOL isWriteFile = [strLocation writeToFile: adFile atomically: YES];
        NSLog(@"isWriteFile rectify.plist %d", isWriteFile);
    }    
    
    self.inBackground = YES;
    [self stopLocation];
    
    if (!appDelegate.isRecording) {
        return ;
    }

    UIBackgroundTaskIdentifier __block bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.inBackground) {
            [self startLocation];
//            [self.trackViewController.mapView setRegion: self.trackViewController.mapView.region animated: YES];
            [NSThread sleepForTimeInterval:(ktime1)];
            
//            [self culcate];
            
            [self stopLocation];
            [NSThread sleepForTimeInterval:(ktime2)];
        }
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self startLocation];
    self.inBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
