//
//  GSFLiveDataTableViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/17/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFLiveDataTableViewController.h"

@interface GSFLiveDataTableViewController ()

// contains the table strings.
@property (nonatomic) NSMutableArray *validDataStrings;

// creates the table strings or the details of the data object.
- (void)createTableStrings;

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
    [self createTableStrings];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // this should be the number of non nil properties in a GSF Geojson object.
    return self.validDataStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [self.validDataStrings objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)createTableStrings
{
    // create the strings that go into the table.
    self.validDataStrings = [[NSMutableArray alloc] init];
    
    // gps coord string
    if (self.data.coords) {
        __weak CLLocation *coords = self.data.coords;
        NSString *coord = [NSString stringWithFormat:@"GPS: %.4f, %.4f", coords.coordinate.latitude, coords.coordinate.longitude];
        [self.validDataStrings addObject:coord];
    }
    
    // date string
    if (self.data.date) {
        NSString *datestring = @"Date: ";
        [self.validDataStrings addObject:[datestring stringByAppendingString:self.data.date]];
    }
    
    // add alitude
    if (self.data.coords) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"Altitude: %.2fm", self.data.coords.altitude]];
    }
    
    // add horizontal accuracy
    if (self.data.coords) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"H_Acc: %.1f", self.data.coords.horizontalAccuracy]];
    }
    
    // add vertical accuracy
    if (self.data.coords) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"V_Acc: %.1f", self.data.coords.verticalAccuracy]];
    }
    
    // add face detection number
    if (self.data.gsfImage.faceDetectionNumber) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"Faces: %d detected.", [self.data.gsfImage.faceDetectionNumber intValue]]];
    }
    
    // add person detection number
    if (self.data.gsfImage.personDetectionNumber) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"People: %d detected.", [self.data.gsfImage.personDetectionNumber intValue]]];
    }
    
    // add noiseLevel
    if (self.data.noiseLevel) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"Noise(dB): %f.", [self.data.noiseLevel doubleValue]]];
    }
    
    // add temperature data
    if (self.data.temp) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"Temperture(˚C): %f.", [self.data.temp doubleValue]]];
    }
    
    // add humidity data
    if (self.data.humidity) {
        [self.validDataStrings addObject:[NSString stringWithFormat:@"Humidity(%%): %f%%.", [self.data.humidity doubleValue]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
