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


@interface GSFDataViewController ()

@property GSFNoiseLevelController *noiseMonitor;
@property GSFSensorIOController *sensorIO;
@property (weak, nonatomic) IBOutlet UISwitch *personDetectToggle;
@property (weak, nonatomic) IBOutlet UISwitch *faceDetectionToggle;
@property (weak, nonatomic) IBOutlet UISwitch *noiseDetectionToggle;
@property (weak, nonatomic) IBOutlet UISwitch *sensorToggle;
@property (nonatomic) IBOutlet UIImageView *imageView;

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
        self.noiseDetectionToggle.on = NO;
        
        // Init GSFSensorIOController instance
        self.sensorIO = [[GSFSensorIOController alloc] init];
        if (!self.sensorIO.isSensorConnected){
            self.sensorToggle.on = NO;
            [self.sensorIO addAlertViewToView:self.view :0];
        }
    }
}

// Turn off sensor monitoring switch if noise monitoring is on
- (IBAction)noiseToggleFlipped:(id)sender {
    if (self.noiseDetectionToggle.on) {
        self.sensorToggle.on = NO;
        
        self.noiseMonitor = [[GSFNoiseLevelController alloc] init];
        if (self.noiseMonitor.isSensorConnected){
            self.noiseDetectionToggle.on = NO;
            [self.noiseMonitor addAlertViewToView:self.view :0];
        }
    }
}

- (IBAction)startCollecting:(id)sender {
    if (self.noiseDetectionToggle.on) {
        NSLog(@"Start audio session recorder and add to collection.");
    }
    if (self.sensorToggle.on) {
        NSLog(@"Start collecting sensor data and add to collection.");
    }
    if (self.personDetectToggle.on || self.faceDetectionToggle.on) {
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
    }
}

- (IBAction)archivedData:(id)sender {
    [self performSegueWithIdentifier:@"archived" sender:self];
}


@end
