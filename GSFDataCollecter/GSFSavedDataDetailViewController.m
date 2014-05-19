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

@interface GSFSavedDataDetailViewController ()

@property (weak, nonatomic) UIImage *cacheImage;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // cache image so that the table wont hang on scrolling.
    NSDictionary *properties = nil;
    if ([[self.feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
        properties = [self.feature objectForKey:@"properties"];
    }
    // NOTE: went down to lorez image. HIGH rez image takes too long to cache
    if ([properties objectForKey:@"image"]) {
        self.cacheImage = self.thumbnail;
    }
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
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (0 == [indexPath row]) {
        cell.textLabel.text = @"View Fullscreen Image";
        NSDictionary *properties = nil;
        if ([[self.feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            properties = [self.feature objectForKey:@"properties"];
        }
        if ([properties objectForKey:@"image"]) {
            cell.imageView.image =  self.cacheImage;
        }
    } else {
        if (1 == indexPath.row) {
            if ([[self.feature objectForKey:@"geometry"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *geometry = [self.feature objectForKey:@"geometry"];
                if ([[geometry objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]) {
                    NSArray *coords = [geometry objectForKey:@"coordinates"];
                    NSString *coord = [[NSString alloc] initWithFormat:@"GPS: %.4f, %.4f", [[coords objectAtIndex:0] doubleValue], [[coords objectAtIndex:1] doubleValue]];
                    cell.textLabel.text = coord;
                }
            }
        } else {
            NSDictionary *properties = nil;
            if ([[self.feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
                properties = [self.feature objectForKey:@"properties"];
            }
            if(2 == indexPath.row) {
                NSString *datestring = @"Date: ";
                cell.textLabel.text = [datestring stringByAppendingString:[properties objectForKey:@"time"]];
            } else if (3 == indexPath.row) {
                if ([properties objectForKey:@"altitude"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Altitude: %.2fm", [[properties objectForKey:@"altitude"] doubleValue]];
                }
            } else if (4 == indexPath.row) {
                if ([properties objectForKey:@"h_accuracy"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"H_Acc: %.1f", [[properties objectForKey:@"h_accuracy"] doubleValue]];
                }
            } else if (5 == indexPath.row) {
                if ([properties objectForKey:@"v_accuracy"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"V_Acc: %.1f", [[properties objectForKey:@"v_accuracy"] doubleValue]];
                }
            } else if (6 == indexPath.row) {
                if ([properties objectForKey:@"faces_detected"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: %d detected.", [[properties objectForKey:@"faces_detected"] intValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: n/a."];
                }
            } else if (7 == indexPath.row) {
                if ([properties objectForKey:@"people_detected"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: %d detected.", [[properties objectForKey:@"people_detected"] intValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: n/a."];
                }
            } else if (8 == indexPath.row) {
                if ([properties objectForKey:@"noise_level"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Noise(dB): %f.", [[properties objectForKey:@"noise_level"] doubleValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Noise(dB): n/a."];
                }
            } else if (9 == indexPath.row) {
                if ([properties objectForKey:@"temperature"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Temperture(˚C): %f.", [[properties objectForKey:@"temperature"] doubleValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Temperture(˚C): n/a."];
                }
            } else if (10 == indexPath.row) {
                if ([properties objectForKey:@"humidity"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Humidity(%%): %f%%.", [[properties objectForKey:@"humidity"] doubleValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Humidity(%%): n/a."];
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == [indexPath row]) {
        [self performSegueWithIdentifier:@"viewSavedFileImages" sender:self];
    }
}


 
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewSavedFileImages"]) {
        GSFSavedDataImageViewController *controller = (GSFSavedDataImageViewController*)segue.destinationViewController;
        controller.image = self.cacheImage;
    }
}



@end
