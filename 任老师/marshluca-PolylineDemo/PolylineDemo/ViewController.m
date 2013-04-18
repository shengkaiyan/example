//
//  ViewController.m
//  PolylineDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define DOCUMENTDIRECTORY                           [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]

#define ktime1 30 //定位等待时间
#define ktime2 30 //后台线程启动间隔时间

@interface ViewController ()

@end

@implementation ViewController

@synthesize points = _points;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = _locationManager;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self configureRoutes];
    [self configureRoutesSky];
    
//    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    NSString *adFile = [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"map.plist"];
    [_points writeToFile: adFile atomically: YES];
    
    adFile = [DOCUMENTDIRECTORY stringByAppendingPathComponent: @"locationManager.plist"];
    [_pointsSky writeToFile: adFile atomically: YES];
    
    UIBackgroundTaskIdentifier __block bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [_locationManager startUpdatingLocation];
            [NSThread sleepForTimeInterval:(ktime1)];
            
//            [self culcate];
            
            [_locationManager stopUpdatingLocation];
            [NSThread sleepForTimeInterval:(ktime2)];
            
            [self.mapView setRegion: self.mapView.region animated:TRUE];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // setup map view
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;    
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;        
    [self.view addSubview:self.mapView];
    
    _points = [[NSMutableArray alloc] init];
    _pointsSky = [[NSMutableArray alloc] init];
    
    // configure location manager
    [self configureLocationManager];
    
    allDistance = 0;
    allSkyDistance = 0;
    oldDistance = 0;
    
    collectionCount = 0;
    collectionCountSky = 0;
    
    [self configureRoutes];
    
    lbDistance = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 200, 30)];
    lbDistance.backgroundColor = [UIColor clearColor];
    lbDistance.textColor = [UIColor blueColor];
    [self.view addSubview: lbDistance];
    
    lbPrice = [[UILabel alloc] initWithFrame: CGRectMake(220, 20, 100, 30)];
    lbPrice.backgroundColor = [UIColor clearColor];
    lbPrice.textColor = [UIColor redColor];
    [self.view addSubview: lbPrice];
    
    lbSkyDistance = [[UILabel alloc] initWithFrame: CGRectMake(20, 60, 200, 30)];
    lbSkyDistance.backgroundColor = [UIColor clearColor];
    lbSkyDistance.textColor = [UIColor blueColor];
    [self.view addSubview: lbSkyDistance];
    
    lbSkyPrice = [[UILabel alloc] initWithFrame: CGRectMake(220, 60, 100, 30)];
    lbSkyPrice.backgroundColor = [UIColor clearColor];
    lbSkyPrice.textColor = [UIColor redColor];
    [self.view addSubview: lbSkyPrice];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    int hour = [comps hour];
    
    NSLog(@"%d", hour);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.mapView = nil;
	self.routeLine = nil;
	self.routeLineView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark
#pragma mark Map View
- (void)configureRoutesSky
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
	
	// create a c array of points.
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _pointsSky.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _pointsSky.count; idx++)
	{
        CLLocation *location = [_pointsSky objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;
        
		// create our coordinate and add it to the correct spot in the array
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet.
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;
	}
	
    if (_routeLineSky) {
        [self.mapView removeOverlay: _routeLineSky];
    }
    
    _routeLineSky = [MKPolyline polylineWithPoints:pointArray count:_pointsSky.count];
    
    // add the overlay to the map
	if (nil != _routeLineSky) {
		[self.mapView addOverlay: _routeLineSky];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);
    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);
     
     // zoom in on the route.
     [self.mapView setVisibleMapRect:_routeRect];
     */
}

- (void)configureRoutes
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f); 
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f); 
	
	// create a c array of points. 
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
	{        
        CLLocation *location = [_points objectAtIndex:idx];  
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;		 
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;        
	}
	
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);	
    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);    	
     
     // zoom in on the route. 
     [self.mapView setVisibleMapRect:_routeRect];
     */
}


 #pragma mark
 #pragma mark Location Manager
 
 - (void)configureLocationManager
 {
 // Create the location manager if this object does not already have one.
 if (nil == _locationManager)
 _locationManager = [[CLLocationManager alloc] init];
 
 _locationManager.delegate = self;
 _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
 _locationManager.distanceFilter = 0;
 [_locationManager startUpdatingLocation];    
 // [_locationManager startMonitoringSignificantLocationChanges];
 }
 
 #pragma mark
 #pragma mark CLLocationManager delegate methods
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 

     CLLocationDistance distance = 0;
     // check the move distance
     if (_points.count > 0) {
         distance = [newLocation distanceFromLocation:_currentSkyLocation];
         if (distance < 10)
             return;
     }
     
//     static int i = 0;
//     i++;
//     if (i == 2) {
//         CLLocation *newLocation2 = [[CLLocation alloc] initWithLatitude: 31.119401 longitude:121.389739];
//         distance = [newLocation2 distanceFromLocation:_currentSkyLocation];
//         
//         [_pointsSky addObject:newLocation2];
//         _currentSkyLocation = newLocation2;         
//     }
//     else
     {
         [_pointsSky addObject:newLocation];
         _currentSkyLocation = newLocation;
     }
     
     allSkyDistance += distance;
     collectionCountSky++;

     lbSkyDistance.text = [NSString stringWithFormat: @"%.2f公里 %d", allSkyDistance/1000, collectionCountSky];
     lbSkyPrice.text = [NSString stringWithFormat: @"%ld元", (long)allSkyDistance/1000];
     
//     if (allSkyDistance - oldDistance > 500)
     {
         [self configureRoutesSky];
         oldDistance = allSkyDistance;
     }
 }

 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"error: %@",error);
 }
 

#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));

	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now. 
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
		overlayView = self.routeLineView;		
	}
	else if(overlay == _routeLineSky)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
        if (_routeLineViewSky) {
            [_routeLineViewSky removeFromSuperview];
        }
        
        _routeLineViewSky = [[MKPolylineView alloc] initWithPolyline: _routeLineSky];
        _routeLineViewSky.fillColor = [UIColor redColor];
        _routeLineViewSky.strokeColor = [UIColor blueColor];
        _routeLineViewSky.lineWidth = 10;
        
		overlayView = _routeLineViewSky;
	}
    
	return overlayView;
}

/*
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLoadingMap:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidFinishLoadingMap:(MKMapView *)mapView");
 } 
 
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
 {
 NSLog(@"mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error");
 }
 
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
 NSLog(@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
 }
 
 - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"centerCoordinate: %f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
 }
 */ 

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

/*
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 }
 
 - (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated");
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLocatingUser:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidStopLocatingUser:(MKMapView *)mapView");
 }
*/ 

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    if (userLocation.location == nil)
    {
        NSLog(@"has no location.%f", userLocation.coordinate.latitude);        
        return;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude 
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    CLLocationDistance distance = 0;
    // check the move distance
    if (_points.count > 0) {        
        distance = [location distanceFromLocation:_currentLocation];        
//        if (distance < 5) 
//            return;        
    }
    
    allDistance += distance;
    collectionCount++;
    
    [_points addObject:location];
    _currentLocation = location;
    
//    static int i = 1;
//    i++;
//    if (i == 2)
//    {
//        CLLocation *newLocation2 = [[CLLocation alloc] initWithLatitude: 31.111401 longitude:121.389839];
//        distance = [newLocation2 distanceFromLocation:_currentSkyLocation];
//        
//        [_points addObject:newLocation2];
//        _currentLocation = newLocation2;
//    }
//    else
//    {
//        [_points addObject:location];
//        _currentLocation = location;
//    }
    
    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
//    allDistance = 800;
    lbDistance.text = [NSString stringWithFormat: @"map %.2f公里 %d", allDistance/1000, collectionCount];
    lbPrice.text = [NSString stringWithFormat: @"%ld元", (long)allDistance/1000];
}

@end