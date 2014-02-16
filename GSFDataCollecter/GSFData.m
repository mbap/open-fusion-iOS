//
//  GSFData.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFData.h"

@implementation GSFData

- (GSFData*)initWithImage:(UIImage*)image {
    self.gsfImage.image = image;
    return self;
}

- (void)geoTagDataWithCoords:(CLLocation *)coords;
{
    self.gpscoords = self.coords.coordinate;
    self.altitude = self.coords.altitude;
    self.horizonalAccuracy = self.coords.horizontalAccuracy;
    self.verticalAccuracy = self.coords.verticalAccuracy;
    self.date = self.coords.timestamp;
}

@end
