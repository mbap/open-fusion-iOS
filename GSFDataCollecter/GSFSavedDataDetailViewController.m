//
//  GSFSavedDataDetailViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataDetailViewController.h"
#import "GSFSavedDataImageViewController.h"
#import "GSFOpenCVPageViewController.h"
#import "GSFOpenCvImageProcessor.h"
#import "GSFData.h"

@interface GSFSavedDataDetailViewController ()

// contains the strings for the details of the data.
@property (nonatomic) NSMutableArray *validDataStrings;

// contains the json dict as a GSFData object
@property (nonatomic) GSFData *data;

// creates the table strings or the details of the data object.
- (void)createTableStrings;

@end

@implementation GSFSavedDataDetailViewController

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
    self.data = [GSFData convertFeatureDictToGSFData:self.feature];
    [self createTableStrings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (indexPath.row == 0 && self.data.gsfImage.oimage) {
        cell.imageView.image = self.data.gsfImage.oimage;
    }
    
    cell.textLabel.text = [self.validDataStrings objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == [indexPath row]) {
        [self performSegueWithIdentifier:@"viewSavedFileImages" sender:self];
    }
}
 
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewSavedFileImages"]) {
        GSFSavedDataImageViewController *controller = (GSFSavedDataImageViewController*)segue.destinationViewController;
        controller.image = self.data.gsfImage.oimage;
    }
}

- (void)createTableStrings
{
    // create the strings that go into the table.
    self.validDataStrings = [[NSMutableArray alloc] init];
    
    // if image data then create image segue string.
    if (self.data.gsfImage.oimage) {
        [self.validDataStrings addObject:@"View Fullscreen Image"];
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
}

@end
