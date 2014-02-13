//
//  GSFGMapViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/12/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "GSFGMapViewController.h"

@interface GSFGMapViewController ()

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) CLLocation *currentLocation;

// helper structure to get the current location
@property (nonatomic, weak) NSMutableArray *locationMeasurements;
@property (nonatomic, weak) CLLocation *bestEffort;

@end

@implementation GSFGMapViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
    
//    // allocate the location Manager
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    
//    // select accuracy for the gps. we can go even higher in accuracy.
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    
//    // get current location
//    self.currentLocation = [[CLLocation alloc] init];
//    [self.locationManager startUpdatingLocation];
//    
//    // Create a GMSCameraPosition that tells the map to display the current location
//    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
//    self.mapView.myLocationEnabled = YES;
//    [self.view addSubview:self.mapView];
//    
//    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = self.currentLocation.coordinate;
//    marker.title = @"Current Location";
//    marker.snippet = @"You are here!";
//    marker.map = self.mapView;
}

//// delegate for super class location manager
//// gets called several times while the location manager is update gps coords.
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    // store all of the measurements, just so we can see what kind of data we might receive
//    [self.locationMeasurements addObject:newLocation];
//    
//    // test the age of the location measurement to determine if the measurement is cached
//    // in most cases you will not want to rely on cached measurements
//    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//    
//    if (locationAge > 5.0) return;
//    // test that the horizontal accuracy does not indicate an invalid measurement
//    
//    if (newLocation.horizontalAccuracy < 0) return;
//    // test the measurement to see if it is more accurate than the previous measurement
//    
//    if (self.bestEffort == nil || self.bestEffort.horizontalAccuracy > newLocation.horizontalAccuracy) {
//        // store the location as the "best effort"
//        self.bestEffort = newLocation;
//        // test the measurement to see if it meets the desired accuracy
//        //
//        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
//        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
//        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
//        //
//        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
//            [self.locationManager stopUpdatingLocation];
//            self.currentLocation = self.bestEffort;
//            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
//                                                                    longitude:self.currentLocation.coordinate.longitude
//                                                                         zoom:6];
//            self.mapView.camera = camera;
//        }
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
