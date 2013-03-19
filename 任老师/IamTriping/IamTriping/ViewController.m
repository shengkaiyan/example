//
//  ViewController.m
//  IamTriping
//
//  Created by Sky on 13-1-4.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect frame = self.view.bounds;
    frame.size.height -= (200);
    
    map = [[MKMapView alloc] initWithFrame: frame];
    map.mapType = MKMapTypeStandard;
	map.showsUserLocation = YES;
    map.delegate = self;
    
    btnHere = [UIButton buttonWithType: UIButtonTypeInfoLight];
    btnHere.center = map.center;
    [btnHere addTarget:self action:@selector(TripToHere) forControlEvents:UIControlEventTouchUpInside];
    
    [map addSubview: btnHere];    
    [self.view addSubview:map];
    
    tvPlace = [[UITextView alloc] init];
    frame = self.view.bounds;
    frame.size.height = 200;
    frame.origin.y = self.view.bounds.size.height-200;
    tvPlace.frame = frame;
    tvPlace.editable = NO;
    
    [self.view addSubview: tvPlace];
}

- (void)TripToHere
{
    CLLocationCoordinate2D tripPlace =
    [map convertPoint: btnHere.center toCoordinateFromView: map];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude: tripPlace.latitude longitude:tripPlace.longitude];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           tvPlace.text = [NSString stringWithFormat: @"%@\n\nlocation:%f %f", error.description, tripPlace.latitude, tripPlace.longitude];
                           return;
                       }
                       
                       NSLog(@"reverseGeocodeLocation:completionHandler:%@", placemarks);
                       
                       NSMutableString *location = [[NSMutableString alloc] init];
                       
                       for (CLPlacemark *placemark in placemarks) {
                           NSLog(@"key:%@", [placemark.addressDictionary allKeys]);
                           
                           
                           NSString *Country=[placemark.addressDictionary objectForKey:@"Country"];
                           
                           NSLog(@"\n\nCountry %@",Country);
                           
                           NSString *CountryCode=[placemark.addressDictionary objectForKey:@"CountryCode"];
                           NSLog(@"CountryCode %@",CountryCode);
                           
                           NSString *State=[placemark.addressDictionary objectForKey:@"State"];
                           
                           NSLog(@"State %@",State);
                           
                           if (State) {
                               [location appendString: State];
                           }
                           
                           NSString *cityStr=[placemark.addressDictionary objectForKey:@"City"];
                           
                           NSLog(@"city %@",cityStr);
                           
                           if (cityStr) {
                               if (location.length) {
                                   [location appendFormat: @", %@", cityStr];
                               }
                               else
                               {
                                   [location appendString: cityStr];
                               }
                           }
                           
                           NSString *Street=[placemark.addressDictionary objectForKey:@"Street"];
                           
                           NSLog(@"Street %@",Street);
                           
                           NSString *Name=[placemark.addressDictionary objectForKey:@"Name"];
                           
                           NSLog(@"Name %@",Name);
                           
                           //                               if (Street) {
                           //                                   if (location.length) {
                           //                                       [location appendFormat: @", %@", Street];
                           //                                   }
                           //                                   else
                           //                                   {
                           //                                       [location appendString: Street];
                           //                                   }
                           //                               }
                           
                           //                               if (Name && Name.length>=3) {
                           //                                   location = [NSMutableString stringWithString: [Name substringFromIndex: 2]];
                           //                               }
                           
                           
                           NSString *FormattedAddressLines=[placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
                           
                           NSLog(@"FormattedAddressLines %@",FormattedAddressLines);
                           
                           NSString *SubLocality=[placemark.addressDictionary objectForKey:@"SubLocality"];
                           
                           if (SubLocality) {
                               if (State && ([State isEqualToString: @"澳門特別行政區"] || [State isEqualToString: @"Macau"] || [State isEqualToString: @"香港特別行政區"] || [State isEqualToString: @"Hong Kong"] || [State isEqualToString: @"上海市"] || [State isEqualToString: @"Shanghai"] || [State isEqualToString: @"北京市"] || [State isEqualToString: @"Beijing"] || [State isEqualToString: @"天津市"] || [State isEqualToString: @"Tianjin"] || [State isEqualToString: @"重庆市"] || [State isEqualToString: @"Chongqing"]))
                               {
                                   if (location.length) {
                                       [location appendFormat: @", %@", SubLocality];
                                   }
                                   else
                                   {
                                       [location appendString: SubLocality];
                                   }
                               }
                           }
                           
                           NSLog(@"SubLocality %@",SubLocality);
                           
                           NSString *Thoroughfare=[placemark.addressDictionary objectForKey:@"Thoroughfare"];
                           
                           NSLog(@"Thoroughfare %@",Thoroughfare);
                           
                           NSString *ZIP=[placemark.addressDictionary objectForKey:@"ZIP"];
                           
                           NSLog(@"ZIP %@",ZIP);
                           
                           break;
                       }
                       
                       if (location) {
                           tvPlace.text = [NSString stringWithFormat: @"%@\n\n%@", location, placemarks.description];
//                           [NSString stringWithCString: placemarks.description.c encoding:<#(NSStringEncoding)#>];
//                           [NSString stringWithCString:str encoding: NSJapaneseEUCStringEncoding]
                       }
                       else
                       {
                           tvPlace.text = [NSString stringWithFormat: @"没有得到位置信息\n\n%@", placemarks.description];
                       }
                   }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
