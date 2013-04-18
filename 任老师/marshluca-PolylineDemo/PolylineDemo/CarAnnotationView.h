//
//  CarAnnotationView.h
//  PolylineDemo
//
//  Created by Sky on 13-4-17.
//
//

#import <MapKit/MapKit.h>

@interface CarAnnotationView : MKAnnotationView<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    BOOL isFromPoint;
}

@property (nonatomic, assign) BOOL isFromPoint;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
