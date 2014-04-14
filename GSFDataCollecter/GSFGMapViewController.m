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

@interface GSFGMapViewController () <GMSMapViewDelegate>

@property (nonatomic) GMSMapView *mapView;

@property (nonatomic) NSMutableArray *waypoints;
@property (nonatomic) NSMutableArray *waypointStrings;

@property (nonatomic) CLLocation *bestEffort;

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
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate: (CLLocationCoordinate2D)coordinate {
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.map = self.mapView;
    [self.waypoints addObject:marker];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                coordinate.latitude,coordinate.longitude];
    [self.waypointStrings addObject:positionString];
    if([self.waypoints count]>1){
        NSString *sensor = @"false";
        NSArray *parameters = [NSArray arrayWithObjects:sensor, self.waypointStrings,
                               nil];
        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
                                                          forKeys:keys];
        GSFDirectionService *serv = [[GSFDirectionService alloc] init];
        SEL selector = @selector(addDirections:);
        [serv setDirectionsQuery:query withSelector:selector withDelegate:self];
    }
}


- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.mapView;
}

- (void)setGoogleMapCameraLocation:(CLLocation*)location
{
    GMSCameraPosition *currentLocation = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:12];
    [self.mapView setCamera:currentLocation];

}

// delegate for super class location manager
// gets called several times while the location manager is update gps coords.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"%@", locations.description);
    
    CLLocation *newLocation = [locations lastObject];
    self.bestEffort = newLocation;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0 || newLocation.verticalAccuracy < 0) {
        return;
    }
    
    
    // test the measurement to see if it meets the desired accuracy
    //
    // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
    // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
    // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
    //
    NSLog(@"%f, %f", newLocation.horizontalAccuracy, self.locationManager.desiredAccuracy);
    if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
        [self.locationManager stopUpdatingLocation];
        [self setGoogleMapCameraLocation:newLocation];
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
