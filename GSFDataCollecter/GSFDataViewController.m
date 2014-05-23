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
#import "GSFDataTransfer.h"

@interface GSFDataViewController () <GSFDataTransferDelegate>

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

- (IBAction)startCollecting:(id)sender {
    if (self.personDetectToggle.on || self.faceDetectionToggle.on ||
        self.noiseDetectionToggle.on || self.sensorToggle.on) {
        [self performSegueWithIdentifier:@"imagePickerSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"imagePickerSegue"]) {
        __weak GSFViewController *child = (GSFViewController*)segue.destinationViewController;
        child.personDetect = self.personDetectToggle.on;
        child.faceDetect = self.faceDetectionToggle.on;
        child.noiseSwitch = self.noiseDetectionToggle.on;
        child.sensorIOSwitch = self.sensorToggle.on;
    }
}

- (IBAction)archivedData:(id)sender {
    [self performSegueWithIdentifier:@"archived" sender:self];
}

@end
