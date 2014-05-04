//
//  GSFDataViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDataViewController.h"
#import "GSFViewController.h"
#import "GSFLoginViewController.h"
#import "UYLPasswordManager.h"

#import "GSFNoiseLevelController.h"
#import "GSFSensorIOController.h"
#import "GSFGMapViewController.h"
#import "GSFDataTransfer.h"

@interface GSFDataViewController () <GSFDataTransferDelegate>

@property GSFNoiseLevelController *noiseMonitor;
@property GSFSensorIOController *sensorIO;
@property (weak, nonatomic) IBOutlet UISwitch *personDetectToggle;
@property (weak, nonatomic) IBOutlet UISwitch *faceDetectionToggle;
@property (weak, nonatomic) IBOutlet UISwitch *noiseDetectionToggle;
@property (weak, nonatomic) IBOutlet UISwitch *sensorToggle;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSDictionary *mapData;

@end

@implementation GSFDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // add background image here.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white.png"]];
    
    // see if user has an api key.
    UYLPasswordManager *pman = [UYLPasswordManager sharedInstance];
    if (![pman validKey:nil forIdentifier:@"apikey"]) {
        // push view controller to get the api key.
        [self.navigationController pushViewController:[[GSFLoginViewController alloc] init] animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Turn off noise monitoring switch if sensor monitor is on
- (IBAction)sensorToggleFlipped:(id)sender {
    if (self.sensorToggle.on) {
        if (self.noiseMonitor) {
            [self.noiseMonitor mointorNoise:NO];
        }
        self.noiseDetectionToggle.on = NO;
        
        // Init GSFSensorIOController instance
        //if (!self.sensorIO) {
            self.sensorIO = [[GSFSensorIOController alloc] init];
            [self.sensorIO monitorSensors:YES];
        //}
    }
}

// Turn off sensor monitoring switch if noise monitoring is on
- (IBAction)noiseToggleFlipped:(id)sender {
    if (self.noiseDetectionToggle.on) {
        if (self.sensorIO) {
            [self.sensorIO monitorSensors:NO];
        }
        self.sensorToggle.on = NO;
        
        //if (!self.noiseMonitor) {
            self.noiseMonitor = [[GSFNoiseLevelController alloc] init];
            [self.noiseMonitor mointorNoise:YES];
        //}
    }
}

- (IBAction)startCollecting:(id)sender {
    NSLog(@"Noise Change Reason: %d", self.noiseMonitor.audioChangeReason);
    NSLog(@"Sensor Change Reason: %d", self.sensorIO.audioChangeReason);
    if (self.noiseDetectionToggle.on && self.noiseMonitor.audioChangeReason != NO_CHANGE) {
        if (self.noiseMonitor.isSensorConnected){
            self.noiseDetectionToggle.on = NO;
            [self.noiseMonitor addAlertViewToView:self.view :self.noiseMonitor.audioChangeReason];
        }
    } else if (self.sensorToggle.on && self.sensorIO.audioChangeReason != NO_CHANGE) {
        if (self.noiseMonitor.isSensorConnected){
            self.noiseDetectionToggle.on = NO;
            [self.sensorIO addAlertViewToView:self.view :self.sensorIO.audioChangeReason];
        }
    } else if (self.personDetectToggle.on ||
               self.faceDetectionToggle.on ||
               self.noiseDetectionToggle.on ||
               self.sensorToggle.on) {
        [self performSegueWithIdentifier:@"imagePickerSegue" sender:self];
    }
}

- (IBAction)startMapData:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"imagePickerSegue"]) {
        GSFViewController *child = (GSFViewController*)segue.destinationViewController;
        child.personDetect = self.personDetectToggle.on;
        child.faceDetect = self.faceDetectionToggle.on;
        child.noiseMonitor = self.noiseMonitor;
        child.sensorIO = self.sensorIO;
    } else if ([[segue identifier] isEqualToString:@"mapSegue"]) {
        if (self.mapData) {
            GSFGMapViewController *child = (GSFGMapViewController *)segue.destinationViewController;
            child.serverData = self.mapData; // this is getting passed through as nil for some reason.
        }
    }
}

- (IBAction)archivedData:(id)sender {
    [self performSegueWithIdentifier:@"archived" sender:self];
}

- (void)handleUrlRequest:(NSString *)url
{
    
    GSFDataTransfer *transfer = [[GSFDataTransfer alloc] init];
    transfer.delegate = self;
    [transfer getCollectionRoute:url];
    
    /*
    // TEST DATA BEGIN
    NSString *string = @"{\
	\"type\": \"GeometryCollection\",\
	\"geometries\": [\
                   {\
                       \"type\": \"Point\",\
                       \"coordinates\": [-122.0617279, 37.0032456]\
                   },\
                   {\
                       \"type\": \"Point\",\
                       \"coordinates\": [-122.0213875, 37.0072211]\
                   },\
    {\
        \"type\": \"Point\",\
        \"coordinates\": [-121.9918617, 36.9878901]\
	},\
    {\
        \"type\": \"Point\",\
        \"coordinates\": [-122.0047363, 36.9791141]\
	},\
    {\
        \"type\": \"Point\",\
        \"coordinates\": [-122.0375236, 36.9596388]\
	}\
                   ]\
}\
    ";
    NSError *error = nil;
    NSData *d = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:&error];
    if (error) NSLog(@"%@", error);
    if (data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapData = data;
            [self performSegueWithIdentifier:@"mapSegue" sender:self];
        });
    }
    // TEST DATA END
    */
    
}

- (void)getRouteFromServer:(NSDictionary *)data
{
    if (data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapData = data;
            [self performSegueWithIdentifier:@"mapSegue" sender:self];
        });
    }
}

@end
