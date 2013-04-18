//
//  TrackViewController.m
//  PolylineDemo
//
//  Created by Sky on 13-4-16.
//
//

#import "TrackViewController.h"
#import "AppDelegate.h"

@interface TrackViewController ()

@end

@implementation TrackViewController
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = _locationManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

const double pi = 3.14159265358979324;

//
// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

//
// World Geodetic System ==> Mars Geodetic System
void transform(double wgLat, double wgLon, double *mgLat, double *mgLon)
{
    if (outOfChina(wgLat, wgLon))
    {
        *mgLat = wgLat;
        *mgLon = wgLon;
        return;
    }
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    *mgLat = wgLat + dLat;
    *mgLon = wgLon + dLon;
}

static bool outOfChina(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

static double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(ABS(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(ABS(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.fromAnnotation = [[CarAnnotationView alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
    self.toAnnotation = [[CarAnnotationView alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
    
    // setup map view
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    [self.view addSubview:self.mapView];
    
    allDistance = 0;
    allDistanceMap = 0;
    allDistanceSky = 0;

    collectionCount = 0;
    collectionCountSky = 0;
    
    latRectifyValue = 0;
    longRectifyValue = 0;
    
    lbDistance = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 200, 30)];
    lbDistance.backgroundColor = [UIColor clearColor];
    lbDistance.textColor = [UIColor blueColor];
    [self.view addSubview: lbDistance];
    
    lbPrice = [[UILabel alloc] initWithFrame: CGRectMake(180, 20, 140, 30)];
    lbPrice.backgroundColor = [UIColor clearColor];
    lbPrice.textColor = [UIColor redColor];
    [self.view addSubview: lbPrice];
    
    lbDistanceSky = [[UILabel alloc] initWithFrame: CGRectMake(20, 60, 200, 30)];
    lbDistanceSky.backgroundColor = [UIColor clearColor];
    lbDistanceSky.textColor = [UIColor blueColor];
    [self.view addSubview: lbDistanceSky];
    
    lbPriceSky = [[UILabel alloc] initWithFrame: CGRectMake(180, 60, 140, 30)];
    lbPriceSky.backgroundColor = [UIColor clearColor];
    lbPriceSky.textColor = [UIColor redColor];
    [self.view addSubview: lbPriceSky];
    
    btnStart = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [btnStart setTitle: @"开始" forState: UIControlStateNormal];
    [btnStart setFrame: CGRectMake(260, 50, 50, 30)];
    [btnStart addTarget: self action: @selector(Start) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: btnStart];
    
    lbShows = [[UILabel alloc] initWithFrame: CGRectMake(20, 400, 300, 30)];
    lbShows.backgroundColor = [UIColor clearColor];
    lbShows.textColor = [UIColor blueColor];
    [self.view addSubview: lbShows];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    int hour = [comps hour];
    
    NSLog(@"%d", hour);
    
    [appDelegate setGetLocationBlock:^(CLLocation *location) {
        if (!appDelegate.isRecording) {
            return ;
        }
        
//        [self.mapView removeAnnotation: self.fromAnnotation];
//        self.fromAnnotation.annotation.coordinate = location.coordinate;
//        self.fromAnnotation.image = [UIImage imageNamed: @"startPoint.png"];
//        
//        [self.mapView addAnnotation: self.fromAnnotation];
        
        CLLocationDistance distance = 0;
        // check the move distance
        if (appDelegate.pointsGps.count > 0) {
            distance = [location distanceFromLocation:_currentLocation];
//            if (distance < 10)
//            {
//                return;
//            }
        }
        
        [appDelegate.pointsGps addObject: location];
        _currentLocation = location;
        
        allDistance += distance;
        collectionCountSky++;
        
        if (latRectifyValue==0 && _currentLocationMap)
//        if (_currentLocationMap)
        {
            latRectifyValue = _currentLocationMap.coordinate.latitude - _currentLocation.coordinate.latitude;
            longRectifyValue = _currentLocationMap.coordinate.longitude - _currentLocation.coordinate.longitude;
            
            NSLog(@"rectifyValue: %f %f", latRectifyValue, longRectifyValue);
        }
        
       
        if (0 != latRectifyValue) {
            CLLocation *newlocation = [[CLLocation alloc] initWithLatitude: location.coordinate.latitude+latRectifyValue longitude:location.coordinate.longitude+longRectifyValue];
            
            if (_currentLocationMapRectify) {
                distance = [newlocation distanceFromLocation:_currentLocationMapRectify];

                allDistanceMap += distance;
            }
            
            _currentLocationMapRectify = newlocation;
            [appDelegate.pointsMap addObject: newlocation];
        }
        
        double newLat;
        double newLong;
        transform(location.coordinate.latitude, location.coordinate.longitude, &newLat, &newLong);
        CLLocation *newlocation2 = [[CLLocation alloc] initWithLatitude: newLat longitude:newLong];
        if (appDelegate.pointsRectify.count) {
            distance = [newlocation2 distanceFromLocation:_currentLocationRectify];
            
            allDistanceSky += distance;
        }
        
        _currentLocationRectify = newlocation2;
        [appDelegate.pointsRectify addObject: newlocation2];
        

        
        lbDistance.text = [NSString stringWithFormat: @"map:%.2f公里", allDistanceMap/1000];
        lbPrice.text = [NSString stringWithFormat: @"纠偏%.2f公里", allDistanceSky/1000];
        lbDistanceSky.text = [NSString stringWithFormat: @"%.2f公里 %d", allDistance/1000, collectionCountSky];
        lbPriceSky.text = [NSString stringWithFormat: @"%ld元", (long)allDistance/1000];
        
//        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.userLocation.location.coordinate, MKCoordinateSpanMake(0.005f, 0.005f)) animated:NO];
//        self.mapView.userLocation.title = @"Location Coordinates";
        
        [self configureRoutesGps];
    }];
}

- (void)Start
{
    appDelegate.isRecording = !appDelegate.isRecording;
    
    if (appDelegate.isRecording) {
        [appDelegate.pointsRectify removeAllObjects];
        [appDelegate.pointsMap removeAllObjects];
        [appDelegate.pointsGps removeAllObjects];
        
        [btnStart setTitle: @"停止" forState: UIControlStateNormal];
    }
    else
    {
        [self.mapView removeAnnotation: self.fromAnnotation];
        [self.mapView removeOverlay: _routeLine];
        [self.mapView removeOverlay: _routeLineRectify];
        [self.mapView removeOverlay: _routeLineSky];
        
        lbDistance.text = @"";
        lbPrice.text = @"";
        lbDistanceSky.text = @"";
        lbPriceSky.text = @"";
        
        allDistance = 0;
        allDistanceMap = 0;
        allDistanceSky = 0;
        
        collectionCount = 0;
        collectionCountSky = 0;
        
        [btnStart setTitle: @"开始" forState: UIControlStateNormal];
    }
}

- (void)configureRoutesGps
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
	
	// create a c array of points.
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * appDelegate.pointsGps.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < appDelegate.pointsGps.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsGps objectAtIndex:idx];
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
    
    _routeLineSky = [MKPolyline polylineWithPoints:pointArray count:appDelegate.pointsGps.count];
    
    // add the overlay to the map
	if (nil != _routeLineSky) {
		[self.mapView addOverlay: _routeLineSky];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);
        
    pointArray = malloc(sizeof(CLLocationCoordinate2D) * appDelegate.pointsRectify.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < appDelegate.pointsRectify.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsRectify objectAtIndex:idx];
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
	
    if (_routeLineRectify) {
        [self.mapView removeOverlay: _routeLineRectify];
    }
    
    _routeLineRectify = [MKPolyline polylineWithPoints:pointArray count:appDelegate.pointsRectify.count];
    
    // add the overlay to the map
	if (nil != _routeLineRectify) {
		[self.mapView addOverlay: _routeLineRectify];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);
    
    
    pointArray = malloc(sizeof(CLLocationCoordinate2D) * appDelegate.pointsMap.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < appDelegate.pointsMap.count; idx++)
	{
        CLLocation *location = [appDelegate.pointsMap objectAtIndex:idx];
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
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count: appDelegate.pointsMap.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);
    
    if (appDelegate.pointsRectify.count) {
        [self.mapView removeAnnotation: self.fromAnnotation];
        [self.mapView removeAnnotation: self.toAnnotation];
        
        self.fromAnnotation = [[CarAnnotationView alloc] initWithLocation: [[appDelegate.pointsRectify objectAtIndex: 0] coordinate]];
        self.fromAnnotation.isFromPoint = YES;
//        self.fromAnnotation.image = [UIImage imageNamed: @"startPoint.png"];

        self.toAnnotation = [[CarAnnotationView alloc] initWithLocation: [[appDelegate.pointsRectify objectAtIndex: appDelegate.pointsRectify.count-1] coordinate]];
        //        self.toAnnotation.title = [directionsOverlay.toAddress descriptionWithAddressFields:MTDAddressFieldCity | MTDAddressFieldStreet | MTDAddressFieldCountry];
//        self.toAnnotation.image = [UIImage imageNamed: @"car.png"];
        self.toAnnotation.isFromPoint = NO;

        
        [self.mapView addAnnotation: self.fromAnnotation];
//        [self.mapView addAnnotation:self.toAnnotation];
        
        lbShows.text = @"add car";
    }
}

- (void)configureRoutes
{    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);
     
     // zoom in on the route.
     [self.mapView setVisibleMapRect:_routeRect];
     */
}

#pragma mark
#pragma mark MKMapViewDelegate
////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
    {
//    if ([annotation isKindOfClass:[MKUserLocation class]]) {
//        return nil;
//    }

    if (annotation == mapView.userLocation) {
        [mapView.userLocation setTitle:@"您的位置"];
        return nil;
    }
    
    static  NSString *annotationIdentifier = @"myAnnotationId";
    CarAnnotationView *myAnnotation = (CarAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!myAnnotation)//&& myAnnotation.annotation != map.userLocation)
    {
        myAnnotation = [[CarAnnotationView alloc]
                        initWithAnnotation:annotation
                        reuseIdentifier:annotationIdentifier];
        lbShows.text = @"viewForAnnotation";
    }
    
    myAnnotation.isFromPoint = ((CarAnnotationView *)annotation).isFromPoint;
    
    if (myAnnotation.isFromPoint) {
        myAnnotation.image = [UIImage imageNamed: @"startPoint.png"];
    }
    else // if (myAnnotation == self.toAnnotation)
    {
        myAnnotation.image = [UIImage imageNamed: @"car.png"];
    }
    
    return myAnnotation;
    
//    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MTDirectionsKitAnnotation"];
//    
//    if (pin == nil) {
//        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MTDirectionsKitAnnotation"];
//    } else {
//        pin.annotation = annotation;
//    }
//    
//    pin.draggable = YES;
//    pin.animatesDrop = YES;
//    pin.canShowCallout = YES;
//    
//    if (annotation == self.fromAnnotation.annotation) {
//        pin.pinColor = MKPinAnnotationColorRed;
//    } else if (annotation == self.toAnnotation.annotation) {
//        pin.pinColor = MKPinAnnotationColorGreen;
//    } else {
//        pin.pinColor = MKPinAnnotationColorPurple;
//    }
//    
//    return pin;
}
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
        self.routeLineView.lineWidth = 2;
        
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
        _routeLineViewSky.lineWidth = 2;
        
		overlayView = _routeLineViewSky;
	}
    else if(overlay == _routeLineRectify)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
        if (_routeLineViewRectify) {
            [_routeLineViewRectify removeFromSuperview];
        }
        
        _routeLineViewRectify = [[MKPolylineView alloc] initWithPolyline: _routeLineRectify];
        _routeLineViewRectify.fillColor = [UIColor yellowColor];
        _routeLineViewRectify.strokeColor = [UIColor yellowColor];
        _routeLineViewRectify.lineWidth = 2;
        
		overlayView = _routeLineViewRectify;
	}
    
	return overlayView;
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    if (userLocation.location == nil || !appDelegate.isRecording)
    {
        NSLog(@"has no location.%f", userLocation.coordinate.latitude);
        return;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    
//    self.fromAnnotation = [[CarAnnotationView alloc] initWithLocation: location.coordinate];
//    [self.mapView removeAnnotation: self.fromAnnotation];
//    self.fromAnnotation.annotation.coordinate = location.coordinate;
//    self.fromAnnotation.image = [UIImage imageNamed: @"startPoint.png"];
//    
//    [self.mapView addAnnotation: self.fromAnnotation];
    
    
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    if (latRectifyValue==0 && _currentLocation)
        //    if (_currentLocation)
    {
        latRectifyValue = _currentLocationMap.coordinate.latitude - _currentLocation.coordinate.latitude;
        longRectifyValue = _currentLocationMap.coordinate.longitude - _currentLocation.coordinate.longitude;
        
        NSLog(@"rectifyValue: %f %f", latRectifyValue, longRectifyValue);
    }

    CLLocationDistance distance = 0;
    // check the move distance
    if (appDelegate.pointsMap.count > 0) {
        distance = [location distanceFromLocation: _currentLocationMap];
//        if (distance < 10)
//            return;
    }
    
//    allDistance += distance;
//    collectionCount++;
//    
//    [appDelegate.pointsMap addObject:location];
    _currentLocationMap = location;
    
    return;
    
    //    static int i = 1;
    //    i++;
    //    if (i == 2)
    //    {
    //        CLLocation *newLocation2 = [[CLLocation alloc] initWithLatitude: 31.111401 longitude:121.389839];
    //        distance = [newLocation2 distanceFromLocation:_currentLocation];
    //
    //        [_points addObject:newLocation2];
    //        _currentLocationMap = newLocation2;
    //    }
    //    else
    //    {
    //        [_points addObject:location];
    //        _currentLocationMap = location;
    //    }

    [self configureRoutesGps];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    //    allDistance = 800;
    lbDistance.text = [NSString stringWithFormat: @"map %.2f公里 %d", allDistance/1000, collectionCount];
    lbPrice.text = [NSString stringWithFormat: @"%ld元", (long)allDistance/1000];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
