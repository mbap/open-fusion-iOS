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
//@property (nonatomic) CLLocation *currentLocation;

@property (nonatomic) NSMutableArray *waypoints;
@property (nonatomic) NSMutableArray *waypointStrings;

@end

@implementation GSFGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:12];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
