//
//  GSFSensorViewController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 5/27/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSensorViewController.h"
#import "GSFSpinner.h"
#import "GSFGeoTagger.h"
#import "GSFData.h"
#import "GSFCollectViewController.h"

@interface GSFSensorViewController () <GSFGeoTaggerDelegate>

@property (nonatomic) GSFGeoTagger *geoTagger;
@property (nonatomic) GSFSpinner *spinner;
@property GSFSensorIOController *sensorIO;
@property NSMutableArray *data;
@property BOOL collectionFinished;

// View
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempratureLabel;

@end

@implementation GSFSensorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [[NSMutableArray alloc]init];
    self.collectionFinished = false;
    
    // Intialize pluggable sensor collection object
    self.sensorIO = [[GSFSensorIOController alloc] initWithView:self.view];
    
    // Assign delegates
    self.sensorIO.collectionDelegate = self;
    self.sensorIO.popVCSensorIODelegate = self;
    
    // Start collection
    [self.sensorIO monitorSensors:YES];
    
    // Grab location
    self.geoTagger = [[GSFGeoTagger alloc] init];
    self.geoTagger.delegate = self;
    [self.geoTagger startUpdatingGeoTagger];
    self.spinner = [[GSFSpinner alloc] init];
    [self.spinner setLabelText:@"Locating..."];
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner.spinner startAnimating];

}

// Delegate function call that ends collection process after a predetermine number of packets has been collected
- (void) endCollection: (GSFSensorIOController *) sensorIOController {
    // Stop monitoring process and free sensorIO
    [self performSelectorInBackground:@selector(stopAudio) withObject:nil];
}

- (void) stopAudio {
    // Stop collection
    [self.sensorIO monitorSensors:NO];
    if (!self.collectionFinished) {
        self.collectionFinished = true;
        // Grab collected sensor data
        self.data = self.sensorIO.collectSensorData;
        
        // Display data
        if ([self.data count] != 0) {
            self.humidityLabel.text = [NSString stringWithFormat:@"%@", self.data[0]];
            self.tempratureLabel.text = [NSString stringWithFormat:@"%@", self.data[1]];
        } else {
            self.humidityLabel.text = @"N/A";
            self.tempratureLabel.text = @"N/A";
        }
    }
}

- (void)gpsLocationHasBeenCollected:(CLLocation *)coords {
    [self.spinner setLabelText:@"Collecting..."];
    GSFData *data = [[GSFData alloc] init];
    
    if (!self.collectionFinished) {
        self.collectionFinished = true;
        // Grab collected sensor data
        self.data = self.sensorIO.collectSensorData;
        
        // Display data
        if ([self.data count] != 0) {
            self.humidityLabel.text = [NSString stringWithFormat:@"%@", self.data[0]];
            self.tempratureLabel.text = [NSString stringWithFormat:@"%@", self.data[1]];
        } else {
            self.humidityLabel.text = @"N/A";
            self.tempratureLabel.text = @"N/A";
        }
    }
    
    // Place collected humidity and temprature data in data structure
    data.humidity = self.data[0];
    data.temp = self.data[1];
    
    // geo tag the data.
    data.coords = [[CLLocation alloc] initWithCoordinate:coords.coordinate altitude:coords.altitude horizontalAccuracy:coords.horizontalAccuracy verticalAccuracy:coords.verticalAccuracy timestamp:coords.timestamp];
    
    // timestamp the data.
    [data convertToISO8601:data.coords];
    
    // add it to the feature collection.
    [self.collectedData addObject:data];
    
    //clean up
    self.geoTagger.delegate = nil;
    self.geoTagger = nil;
    [self.spinner.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}
- (IBAction)sensorDoneButtonPushed:(id)sender {
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for(id view in viewControllers){
        if([view isKindOfClass:[GSFCollectViewController class]]){
            [[self navigationController] popToViewController:view animated:YES];
        }
    }
}

- (void) popVCSensorIO: (GSFSensorIOController *) sensorIOController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
