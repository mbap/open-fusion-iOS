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

@interface GSFSensorViewController () <GSFGeoTaggerDelegate, GSFSensorIOControllerDelgate>

@property (nonatomic) GSFGeoTagger *geoTagger;
@property (nonatomic) GSFSpinner *spinner;
@property (nonatomic) GSFSensorIOController *sensorIO;
@property (nonatomic) GSFData *data;
@property (nonatomic) NSMutableArray *sensorData;
@property (nonatomic) CLLocation *coords;
@property BOOL collectionComplete;

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
    
    // get screen size
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    UIImageView *sensorBackGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, screenSize.size.height)];
    sensorBackGroundImage.contentMode = UIViewContentModeCenter;
    sensorBackGroundImage.image = [UIImage imageNamed:@"climate_smooth_drop_shadow_150px.png"];
    [self.view addSubview:sensorBackGroundImage];
    [self.view sendSubviewToBack:sensorBackGroundImage];
    
    self.collectionComplete = false;
    self.data = [[GSFData alloc] init];
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStyleBordered target:self action:@selector(discardButtonPushed)];
    
    self.sensorData = [[NSMutableArray alloc]init];
    
    // Intialize pluggable sensor collection object
    self.sensorIO = [[GSFSensorIOController alloc] initWithView:self.view];
    
    // Assign delegates
    self.sensorIO.delegate = self;
    
    // Grab location
    self.geoTagger = [[GSFGeoTagger alloc] initWithAccuracy:kCLLocationAccuracyHundredMeters];
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
    
    // Grab collected sensor data
    self.sensorData = self.sensorIO.collectSensorData;
    
    // Display data
    if ([self.sensorData count] != 0) {
        self.humidityLabel.text = [NSString stringWithFormat:@"%@", self.sensorData[0]];
        self.tempratureLabel.text = [NSString stringWithFormat:@"%@", self.sensorData[1]];
    } else {
        self.humidityLabel.text = @"N/A";
        self.tempratureLabel.text = @"N/A";
    }
    
    self.data.humidity = self.sensorData[0];
    self.data.temp = self.sensorData[1];
    
    // geo tag the data.
    self.data.coords = self.coords;
    
    // timestamp the data.
    [self.data convertToISO8601:self.data.coords];
    
    //clean up
    [self.spinner.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    self.collectionComplete = true;
}

- (void)gpsLocationHasBeenCollected:(CLLocation *)coords {
    [self.spinner setLabelText:@"Collecting..."];
    
    self.coords = [[CLLocation alloc] initWithCoordinate:coords.coordinate altitude:coords.altitude horizontalAccuracy:coords.horizontalAccuracy verticalAccuracy:coords.verticalAccuracy timestamp:coords.timestamp];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        // Start collection
        [self.sensorIO monitorSensors:YES];
    });
}

- (void) discardButtonPushed {
    if (self.collectionComplete) {
        [self.sensorIO monitorSensors:NO];
        
        if (self.sensorIO != nil) {
            self.sensorIO.delegate = nil;
            self.sensorIO = nil;
        }
        
        if (self.geoTagger.delegate != nil) {
            self.geoTagger.delegate = nil;
        }
        if (self.geoTagger != nil) {
            self.geoTagger = nil;
        }
        
        if (self.spinner != nil) {
            self.spinner = nil;
        }
        
        if (self.data != nil) {
            self.data = nil;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)sensorDoneButtonPushed:(id)sender {
    if (self.collectionComplete) {
        // Add it to the feature collection.
        if (self.data)
            [self.collectedData addObject:self.data];
        
        // Stop sensor monitoring and clean up
        [self.sensorIO monitorSensors:NO];
        if (self.sensorIO != nil) {
            self.sensorIO.delegate = nil;
            self.sensorIO = nil;
        }
        
        if (self.geoTagger.delegate != nil) {
            self.geoTagger.delegate = nil;
        }
        if (self.geoTagger != nil) {
            self.geoTagger = nil;
        }
        
        if (self.spinner != nil) {
            self.spinner = nil;
        }
        if (self.data != nil) {
            self.data = nil;
        }
        
        NSArray *viewControllers = [[self navigationController] viewControllers];
        for(id view in viewControllers){
            if([view isKindOfClass:[GSFCollectViewController class]]){
                [[self navigationController] popToViewController:view animated:YES];
            }
        }
    }
}

- (void) popVCSensorIO: (GSFSensorIOController *) sensorIOController {
    [self.sensorIO monitorSensors:NO];
    if (self.sensorIO != nil) {
        self.sensorIO.delegate = nil;
        self.sensorIO = nil;
    }
    
    if (self.geoTagger.delegate != nil) {
        self.geoTagger.delegate = nil;
    }
    if (self.geoTagger != nil) {
        self.geoTagger = nil;
    }
    
    if (self.spinner != nil) {
        self.spinner = nil;
    }
    if (self.data != nil) {
        self.data = nil;
    }
    
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
