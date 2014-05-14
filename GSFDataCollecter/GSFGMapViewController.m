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
#import "GSFSpinner.h"

@interface GSFGMapViewController () <GMSMapViewDelegate, GSFDirectionServer, UIActionSheetDelegate>

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSCoordinateBounds *bounds;
@property (nonatomic) BOOL tappable;

@property (nonatomic) NSMutableArray *polylines;
@property (nonatomic) NSMutableArray *waypoints;
@property (nonatomic) NSMutableArray *waypointStrings;
@property (nonatomic) NSMutableArray *bestPathIndex;

// no means A2Z yes means Roundtrip
@property (nonatomic) BOOL RT_A2Z_toggle;

@property (nonatomic) CLLocation *bestEffort;
@property (nonatomic) NSMutableArray *locationMeasurements;

@property (nonatomic) GSFDirectionService *serv;
@property (nonatomic) GSFSpinner *spinner;

// sets the camera of the map.
- (void)setGoogleMapCameraLocation:(CLLocation*)location;

@end

@implementation GSFGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // this means roundtrip
    self.RT_A2Z_toggle = YES;
    
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
    
    if (self.serverData) {
        self.tappable = false;
    } else {
        self.tappable = true;
    }
}

- (void)parseServerData
{
    if ([[self.serverData objectForKey:@"geometries"] isKindOfClass:[NSArray class]]) {
        NSArray *points = [self.serverData objectForKey:@"geometries"];
        for (NSDictionary *data in points) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                if ([[data objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]) {
                    NSArray *coords = [data objectForKey:@"coordinates"];
                    NSNumber *longitude = [coords firstObject];
                    NSNumber *latitude = [coords lastObject];
                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        marker.map = self.mapView;
                    });
                    [self.waypoints addObject:marker];
                    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                                latitude.doubleValue, longitude.doubleValue];
                    [self.waypointStrings addObject:positionString];
                }
            }
        }
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate: (CLLocationCoordinate2D)coordinate {
    if (true == self.tappable) {
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        dispatch_async(dispatch_get_main_queue(), ^{
            marker.map = self.mapView;
        });
        [self.waypoints addObject:marker];
        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                    coordinate.latitude,coordinate.longitude];
        [self.waypointStrings addObject:positionString];
        self.serv = [[GSFDirectionService alloc] initWithGPSCoords:self.waypoints andWithWaypointStrings:self.waypointStrings];
        self.serv.delegate = self;
        self.spinner = [[GSFSpinner alloc] init];
        [self.mapView addSubview:self.spinner];
        [self.mapView bringSubviewToFront:self.spinner];
        [self.spinner setLabelText:@"Loading..."];
        [self.spinner.spinner startAnimating];
        dispatch_queue_t tspQueue = dispatch_queue_create("tspQueue", NULL);
        dispatch_async(tspQueue, ^{
            [self.serv solveTSP:self.RT_A2Z_toggle];
        });
    }
}

- (void)clearPolylines
{
    for (GMSPolyline *polyline in self.polylines) {
        polyline.map = nil;
    }
}

- (void)clearMarkers
{
    for (GMSMarker *marker in self.waypoints) {
        marker.map = nil;
    }
}

- (void)getTSPResults:(NSDictionary *)data
{
    if (data) {
        [self clearPolylines];
        NSArray *bestPath = [data objectForKey:@"bestPath"];
        self.bestPathIndex = [NSMutableArray arrayWithArray:bestPath];
        NSMutableArray *bestLegs = [[NSMutableArray alloc] init];
        for (int i = 1; i <= bestPath.count; ++i) {
            NSNumber *ind = [[NSNumber alloc] init];
            if (i < bestPath.count) {
                ind = bestPath[i];
            }
            NSURL *query = nil;
            if (i == bestPath.count) {
                if (self.RT_A2Z_toggle == YES) {
                    query = [self.serv createURLStringWithOrigin:[self.waypointStrings firstObject] withDestination:[self.waypointStrings lastObject] withStops:nil];
                }
            } else {
                query = [self.serv createURLStringWithOrigin:self.waypointStrings[ind.intValue-1] withDestination:self.waypointStrings[ind.intValue] withStops:nil];
            }
            NSError *error = nil;
            NSData *data = nil;
            NSDictionary *json = nil;
            if (query) {
                data = [NSData dataWithContentsOfURL:query];
                json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            }
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
            dispatch_async(dispatch_get_main_queue(), ^{
                polyline.map = self.mapView;
                [self.spinner.spinner stopAnimating];
                [self.spinner removeFromSuperview];
                self.spinner = nil;
                [self fitRouteToMap];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner.spinner stopAnimating];
            [self.spinner removeFromSuperview];
            self.spinner = nil;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Google direction service failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)setGoogleMapCameraLocation:(CLLocation*)location
{
    GMSCameraPosition *currentLocation = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:12];
    [self.mapView setCamera:currentLocation];
    if (self.waypoints.count == 0) {
        [self.waypoints addObject:[GMSMarker markerWithPosition:location.coordinate]];
        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                    location.coordinate.latitude, location.coordinate.longitude];
        [self.waypointStrings addObject:positionString];
        if (self.serverData) {
            [self parseServerData];
            self.tappable = false;
            self.serv = [[GSFDirectionService alloc] initWithGPSCoords:self.waypoints andWithWaypointStrings:self.waypointStrings];
            self.serv.delegate = self;
            self.spinner = [[GSFSpinner alloc] init];
            [self.mapView addSubview:self.spinner];
            [self.mapView bringSubviewToFront:self.spinner];
            [self.spinner setLabelText:@"Loading..."];
            [self.spinner.spinner startAnimating];
            dispatch_queue_t tspqueue = dispatch_queue_create("tspqueue", NULL);
            dispatch_async(tspqueue, ^{
                [self.serv solveTSP:self.RT_A2Z_toggle];
            });
        }
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

- (void)resetAllMapObjects
{
    // reset the map
    [self clearPolylines];
    [self clearMarkers];
    [self.polylines removeAllObjects];
    [self.waypoints removeAllObjects];
    [self.waypointStrings removeAllObjects];
    [self.waypoints addObject:[GMSMarker markerWithPosition:self.bestEffort.coordinate]];
    self.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.bestEffort.coordinate coordinate:self.bestEffort.coordinate];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                self.bestEffort.coordinate.latitude, self.bestEffort.coordinate.longitude];
    [self.waypointStrings addObject:positionString];
    
    // if we truly want to reset it we should not point strongly to the old coordinates and turn on map tap below.
    
}

- (void)getDirectionsUsingSafari
{
    // get directions for entire route in safari
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://www.google.com/maps/dir/"];
    NSUInteger wpCount = [self.waypointStrings count];
    for(int i = 0; i < wpCount; i++){
        NSNumber *ind = self.bestPathIndex[i];
        [url appendString:[self.waypointStrings objectAtIndex:ind.intValue]];
        [url appendString: @"/"];
    }
    [url appendString:[self.waypointStrings firstObject]];
    [url appendString: @"/"];
    [url appendString: @"@"];
    [url appendString:[self.waypointStrings firstObject]];
    [url appendString: @"/"];
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]) {
        NSLog(@"Google Maps App not installed.");
    }
}

- (void)plotLegInGoogleMapsApp
{
    // plot one leg in googele maps.
    NSNumber *s = self.bestPathIndex[1];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@",[self.waypointStrings firstObject], [self.waypointStrings objectAtIndex:s.intValue]]];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"Google Maps app is not installed");
        //maybe have an alert view pop up here. telling them to push different option
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)fitRouteToMap
{
    // fit the camera
    self.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.bestEffort.coordinate coordinate:self.bestEffort.coordinate];
    for (GMSMarker *extender in self.waypoints) {
        self.bounds = [self.bounds includingCoordinate:extender.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:self.bounds];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView moveCamera:update];
    });
}

- (void)toggleRTA2Z
{
    self.RT_A2Z_toggle = !self.RT_A2Z_toggle;
    self.spinner = [[GSFSpinner alloc] init];
    [self.mapView addSubview:self.spinner];
    [self.mapView bringSubviewToFront:self.spinner];
    [self.spinner setLabelText:@"Loading..."];
    [self.spinner.spinner startAnimating];
    dispatch_queue_t togglequeue = dispatch_queue_create("togglequeue", NULL);
    dispatch_async(togglequeue, ^{
        [self.serv solveTSP:self.RT_A2Z_toggle];
    });
}


// really should be named open Action Menu.
- (IBAction)openGoogleMapsApp:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"User Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Map" otherButtonTitles:@"Get Directions", @"First Leg: Google Maps App", @"Fit Camera to Route", @"Toggle RoundTrip / AtoZ", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        [self resetAllMapObjects];
    } else if (1 == buttonIndex) {
        [self getDirectionsUsingSafari];
    } else if (2 == buttonIndex) {
        [self plotLegInGoogleMapsApp];
    } else if (3 == buttonIndex) {
        [self fitRouteToMap];
    } else if (4 == buttonIndex) {
        [self toggleRTA2Z];
    } else {
        // do nothing cancel button was hit.
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
