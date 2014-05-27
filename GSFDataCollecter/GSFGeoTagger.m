//
//  GSFGeoTagger.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFGeoTagger.h"

@interface GSFGeoTagger() <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, weak) NSMutableArray *locationMeasurements;

@end



@implementation GSFGeoTagger

- (id)init
{
    self = [super init];
    if (self ) {
        // allocate the location manager.
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // select accuracy for the gps. we can go even higher in accuracy.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    return self;
}

- (id)initWithAccuracy:(CLLocationAccuracy)accuracy
{
    self = [super init];
    if (self ) {
        // allocate the location manager.
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // select accuracy for the gps. we can go even higher in accuracy.
        self.locationManager.desiredAccuracy = accuracy;
    }
    return self;
}

- (void)startUpdatingGeoTagger
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingGeoTagger
{
    [self.locationManager stopUpdatingLocation];
    if ([self.delegate respondsToSelector:@selector(gpsLocationHasBeenCollected:)]) {
        [self.delegate gpsLocationHasBeenCollected:self.bestEffort];
    }
}

// delegate for super class location manager
// gets called several times while the location manager is update gps coords.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // store all of the measurements, just so we can see what kind of data we might receive
    CLLocation *newLocation = [locations lastObject];
    [self.locationMeasurements addObject:newLocation];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    
    if (self.bestEffort == nil || self.bestEffort.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffort = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [self stopUpdatingGeoTagger];
        }
    }
}

@end
