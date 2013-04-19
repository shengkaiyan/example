//
//  locationRectify.h
//  locationRectify
//
//  Created by Sky on 13-4-19.
//  Copyright (c) 2013年 Sky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface locationRectify : NSObject


//
// World Geodetic System ==> Mars Geodetic System
void transform(double wgLat, double wgLon, double *mgLat, double *mgLon);


@end
