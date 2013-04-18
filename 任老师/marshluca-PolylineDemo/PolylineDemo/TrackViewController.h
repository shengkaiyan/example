//
//  TrackViewController.h
//  PolylineDemo
//
//  Created by Sky on 13-4-16.
//
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CarAnnotationView.h"

@interface TrackViewController : UIViewController <MKMapViewDelegate>
{
	// the map view
	MKMapView* _mapView;
    
	// the data representing the route points.
	MKPolyline* _routeLine;
	
	// the view we create for the line on the map
	MKPolylineView* _routeLineView;
	
	// the rect that bounds the loaded points
	MKMapRect _routeRect;
        
    // current location
    CLLocation* _currentLocationMap;
    CLLocation* _currentLocationMapRectify;
    CLLocationDistance allDistance;
    
    UILabel *lbDistance;
    UILabel *lbPrice;
    
    UILabel *lbDistanceSky;
    UILabel *lbPriceSky;
    CLLocationDistance allDistanceMap;
    CLLocationDistance allDistanceSky;
    
    CLLocation* _currentLocation;
    CLLocation* _currentLocationRectify;
    
    MKPolylineView* _routeLineViewSky;
    MKPolyline* _routeLineSky;
    
    MKPolylineView* _routeLineViewRectify;
    MKPolyline* _routeLineRectify;
    
    CLLocationDistance oldDistance;
    
    int collectionCount;
    int collectionCountSky;
    
    CLLocationDistance latRectifyValue;
    CLLocationDistance longRectifyValue;
    
    UIButton *btnStart;
    
    UILabel *lbShows;
}

@property (nonatomic, strong) CarAnnotationView *fromAnnotation;
@property (nonatomic, strong) CarAnnotationView *toAnnotation;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) CLLocationManager* locationManager;

-(void) configureRoutes;

@end
