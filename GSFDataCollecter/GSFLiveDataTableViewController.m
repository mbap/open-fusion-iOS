//
//  GSFLiveDataTableViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/17/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFLiveDataTableViewController.h"

@interface GSFLiveDataTableViewController ()

@end

@implementation GSFLiveDataTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // this should be the number of properties in a GSF Geojson object.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (0 == indexPath.row) {
        // gps coords
        if (self.data.coords) {
            __weak CLLocation *coords = self.data.coords;
            NSString *coord = [[NSString alloc] initWithFormat:@"GPS: %.4f, %.4f", coords.coordinate.latitude, coords.coordinate.longitude];
            cell.textLabel.text = coord;
        }
    } else if(1 == indexPath.row) {
        // date string
        if (self.data.date) {
            NSString *datestring = @"Date: ";
            cell.textLabel.text = [datestring stringByAppendingString:self.data.date];
        }
    } else if (2 == indexPath.row) {
        if (self.data.coords) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Altitude: %.2fm", self.data.coords.altitude];
        }
    } else if (3 == indexPath.row) {
        if (self.data.coords) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"H_Acc: %.1f", self.data.coords.horizontalAccuracy];
        }
    } else if (4 == indexPath.row) {
        if (self.data.coords) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"V_Acc: %.1f", self.data.coords.verticalAccuracy];
        }
    } else if (5 == indexPath.row) {
        if (self.data.gsfImage.faceDetectionNumber) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: %d detected.", [self.data.gsfImage.faceDetectionNumber intValue]];
        } else {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: n/a."];
        }
    } else if (6 == indexPath.row) {
        if (self.data.gsfImage.personDetectionNumber) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: %d detected.", [self.data.gsfImage.personDetectionNumber intValue]];
        } else {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: n/a."];
        }
    } else if (7 == indexPath.row) {
        if (self.data.noiseLevel) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Noise(dB): %f.", [self.data.noiseLevel doubleValue]];
        } else {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Noise(dB): n/a."];
        }
    } else if (8 == indexPath.row) {
        if (self.data.temp) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Temperture(˚C): %f.", [self.data.temp doubleValue]];
        } else {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Temperture(˚C): n/a."];
        }
    } else if (9 == indexPath.row) {
        if (self.data.humidity) {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Humidity(%%): %f%%.", [self.data.humidity doubleValue]];
        } else {
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"Humidity(%%): n/a."];
        }
    }
    return cell;
}

@end
