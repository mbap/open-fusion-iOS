//
//  GSFGMapViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/12/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "GSFGMapViewController.h"
#import "GSFDirectionService.h"

@interface GSFGMapViewController () <GMSMapViewDelegate, GSFDirectionServer>

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) NSMutableArray *polylines;

@property (nonatomic) NSMutableArray *waypoints;
@property (nonatomic) NSMutableArray *waypointStrings;

@property (nonatomic) CLLocation *bestEffort;
@property (nonatomic) NSMutableArray *locationMeasurements;

@property (nonatomic) GSFDirectionService *serv;

// sets the camera of the map.
- (void)setGoogleMapCameraLocation:(CLLocation*)location;

@end

@implementation GSFGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // get the current user location.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    // Create a GMSCameraPosition that tells the map to display the
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.bestEffort.coordinate zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.view = self.mapView;
    self.mapView.delegate = self;
    self.waypoints = [[NSMutableArray alloc] init];
    self.waypointStrings = [[NSMutableArray alloc] init];
    self.locationMeasurements = [[NSMutableArray alloc] init];
    self.polylines = [[NSMutableArray alloc] init];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate: (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.map = self.mapView;
    [self.waypoints addObject:marker];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                coordinate.latitude,coordinate.longitude];
    [self.waypointStrings addObject:positionString];
    self.serv = [[GSFDirectionService alloc] initWithGPSCoords:self.waypoints andWithWaypointStrings:self.waypointStrings];
    self.serv.delegate = self;
    [self.serv solveTSP];
}

- (void)clearPolylines
{
    for (GMSPolyline *polyline in self.polylines) {
        polyline.map = nil;
    }
}

- (void)getTSPResults:(NSDictionary *)data
{
    /*
    NSMutableString *finalRoute = [[NSMutableString alloc] init];
    [finalRoute appendString:@""];
    if ([[data objectForKey:@"legs"] isKindOfClass:[NSArray class]]) {
        NSArray *legs = [data objectForKey:@"legs"];
        if ([[legs objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmp = [legs objectAtIndex:0];
            if([[tmp objectForKey:@"steps"] isKindOfClass:[NSArray class]]) {
                NSArray *steps = [tmp objectForKey:@"steps"];
                for (NSDictionary *stuff in steps) {
                    if ([[stuff objectForKey:@"polyline"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *polyline = [stuff objectForKey:@"polyline"];
                        NSString *poly = [polyline objectForKey:@"points"];
                        [finalRoute appendString:poly];
                    }
                }
            }
        }
    }
    */
    
    [self clearPolylines];
    
    NSArray *bestPath = [data objectForKey:@"bestPath"];
    NSLog(@"%@, %@", bestPath.description, self.waypoints.description);
    NSMutableArray *bestLegs = [[NSMutableArray alloc] init];
    for (int i = 1; i <= bestPath.count; ++i) {
        NSNumber *ind = [[NSNumber alloc] init];
        if (i < bestPath.count) {
            ind = bestPath[i];
        }
        NSURL *query = nil;
        if (i  == bestPath.count) {
            query = [self.serv createURLStringWithOrigin:[self.waypointStrings firstObject] withDestination:[self.waypointStrings lastObject] withStops:nil];
        } else {
            query = [self.serv createURLStringWithOrigin:self.waypointStrings[ind.intValue-1] withDestination:self.waypointStrings[ind.intValue] withStops:nil];
        }
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:query];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (json) {
            [bestLegs addObject:json];
        } else {
            NSLog(@"%@", error);
        }
    }
    for (NSDictionary *data in bestLegs) {
        NSDictionary *routes = [data objectForKey:@"routes"][0];
        NSDictionary *route = [routes objectForKey:@"overview_polyline"];
        NSString *overview_route = [route objectForKey:@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        [self.polylines addObject:polyline];
        polyline.map = self.mapView;
    }
}

//- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate: (CLLocationCoordinate2D)coordinate {
//    
//    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//    GMSMarker *marker = [GMSMarker markerWithPosition:position];
//    marker.map = self.mapView;
//    [self.waypoints addObject:marker];
//    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
//                                coordinate.latitude,coordinate.longitude];
//    [self.waypointStrings addObject:positionString];
//    if([self.waypoints count]>1){
//        NSString *sensor = @"false";
//        NSArray *parameters = [NSArray arrayWithObjects:sensor, self.waypointStrings,
//                               nil];
//        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
//        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
//                                                          forKeys:keys];
//        self.serv = [[GSFDirectionService alloc] init];
//        self.serv.delegate = self;
//        [self.serv setDirectionsQuery:query];
//    }
//}
//
//- (void)checkJSONResults:(NSDictionary *)data
//{
//    NSDictionary *routes = [data objectForKey:@"routes"][0];
//    
//    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
//    NSString *overview_route = [route objectForKey:@"points"];
//    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
//    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//    polyline.map = self.mapView;
//}


- (void)setGoogleMapCameraLocation:(CLLocation*)location
{
    GMSCameraPosition *currentLocation = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:12];
    [self.mapView setCamera:currentLocation];
    if (self.waypoints.count == 0) {
        [self.waypoints addObject:[GMSMarker markerWithPosition:location.coordinate]];
        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                    location.coordinate.latitude, location.coordinate.longitude];
        [self.waypointStrings addObject:positionString];
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
        [self setGoogleMapCameraLocation:newLocation];

        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [self.locationManager stopUpdatingLocation];
            [self setGoogleMapCameraLocation:newLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    NSLog(@"Location services has stopped.\n Error:%@\nUpdating the google maps camera.", error);
    [self setGoogleMapCameraLocation:self.bestEffort];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Services has failed.\n%@\n", error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
