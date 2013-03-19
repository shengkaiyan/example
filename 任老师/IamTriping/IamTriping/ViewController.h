//
//  ViewController.h
//  IamTriping
//
//  Created by Sky on 13-1-4.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController
<MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *map;
    UIButton *btnHere;
    
    CLLocationManager *locationManager;
    
    UITextView *tvPlace;
}

@end
