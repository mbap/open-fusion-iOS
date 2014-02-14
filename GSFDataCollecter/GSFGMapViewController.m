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

@implementation GSFGMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *initCamera = [GMSCameraPosition cameraWithLatitude:39.5 longitude:-98.35 zoom:12];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:12];
//    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:initCamera];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.view = self.mapView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
