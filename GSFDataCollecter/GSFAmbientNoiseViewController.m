//
//  GSFAmbientNoiseViewController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 5/27/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFAmbientNoiseViewController.h"
#import "GSFSpinner.h"
#import "GSFGeoTagger.h"
#import "GSFData.h"
#import "GSFCollectViewController.h"

@interface GSFAmbientNoiseViewController () <GSFGeoTaggerDelegate, GSFNoiseLevelControllerDelgate>

@property (nonatomic) GSFNoiseLevelController *ambientNoise;
@property (nonatomic) GSFGeoTagger *geoTagger;
@property (nonatomic) GSFSpinner *spinner;
@property (nonatomic) GSFData *data;

// View
@property (weak, nonatomic) IBOutlet UILabel *peakDBLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgDBLabel;

@end

@implementation GSFAmbientNoiseViewController

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
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStyleBordered target:self action:@selector(discardButtonPushed)];
    
    self.peakDBLabel.text = @"N/A";
    self.avgDBLabel.text = @"N/A";
    
    self.ambientNoise = [[GSFNoiseLevelController alloc] initWithView:self.view];
    self.ambientNoise.delegate = self;
    
    [self.ambientNoise mointorNoise:YES];
    [self.ambientNoise checkAudioStatus];
    
    self.data = [[GSFData alloc] init];
    
    self.geoTagger = [[GSFGeoTagger alloc] initWithAccuracy:kCLLocationAccuracyHundredMeters];
    self.geoTagger.delegate = self;
    [self.geoTagger startUpdatingGeoTagger];
    self.spinner = [[GSFSpinner alloc] init];
    [self.spinner setLabelText:@"Locating..."];
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner.spinner startAnimating];
}

- (void)gpsLocationHasBeenCollected:(CLLocation *)coords {
    // Collect Noise
    [self.spinner setLabelText:@"Collecting..."];
    [self.ambientNoise collectNoise];
    
    self.data.noiseLevel = [NSNumber numberWithDouble:self.ambientNoise.avgDBInput];
    
    // Update view
    self.peakDBLabel.text = [NSString stringWithFormat:@"%3.2f", self.ambientNoise.peakDBInput];
    self.avgDBLabel.text = [NSString stringWithFormat:@"%3.2f", self.ambientNoise.avgDBInput];
    
    // geo tag the data.
    self.data.coords = [[CLLocation alloc] initWithCoordinate:coords.coordinate altitude:coords.altitude horizontalAccuracy:coords.horizontalAccuracy verticalAccuracy:coords.verticalAccuracy timestamp:coords.timestamp];
    
    // timestamp the data.
    [self.data convertToISO8601:self.data.coords];
    
    [self.spinner.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

- (void) popVCNoiseLevel: (GSFNoiseLevelController *) noiseLevelController {
    [self.ambientNoise mointorNoise:NO];
    
    self.ambientNoise.delegate = nil;
    self.ambientNoise = nil;
    self.geoTagger.delegate = nil;
    self.geoTagger = nil;
    self.data = nil;
    
    if (self.spinner != nil) {
        [self.spinner.spinner stopAnimating];
        [self.spinner removeFromSuperview];
        self.spinner = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) discardButtonPushed {
    [self.ambientNoise mointorNoise:NO];
    
    self.ambientNoise.delegate = nil;
    self.ambientNoise = nil;
    self.geoTagger.delegate = nil;
    self.geoTagger = nil;
    self.data = nil;
    
    if (self.spinner != nil) {
        [self.spinner.spinner stopAnimating];
        [self.spinner removeFromSuperview];
        self.spinner = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)noiseDoneButtonPushed:(id)sender {
    // Add it to the feature collection.
    if (self.data)
        [self.collectedData addObject:self.data];
    
    // Stop noise colleciton and clean up
    [self.ambientNoise mointorNoise:NO];
    
    self.ambientNoise.delegate = nil;
    self.ambientNoise = nil;
    self.geoTagger.delegate = nil;
    self.geoTagger = nil;
    self.data = nil;
    
    if (self.spinner != nil) {
        [self.spinner.spinner stopAnimating];
        [self.spinner removeFromSuperview];
        self.spinner = nil;
    }
    
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for(id view in viewControllers){
        if([view isKindOfClass:[GSFCollectViewController class]]){
            [[self navigationController] popToViewController:view animated:YES];
        }
    }
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
