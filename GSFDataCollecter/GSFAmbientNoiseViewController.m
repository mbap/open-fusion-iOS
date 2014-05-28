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

@interface GSFAmbientNoiseViewController () <GSFGeoTaggerDelegate>

@property (nonatomic) GSFGeoTagger *geoTagger;
@property (nonatomic) GSFSpinner *spinner;

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
    
    self.peakDBLabel.text = @"N/A";
    self.avgDBLabel.text = @"N/A";
    
    self.geoTagger = [[GSFGeoTagger alloc] init];
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
    GSFNoiseLevelController *noiseCtrl = [[GSFNoiseLevelController alloc] init];
    [noiseCtrl collectNoise];
    GSFData *data = [[GSFData alloc] init];
    data.noiseLevel = [NSNumber numberWithDouble:noiseCtrl.avgDBInput];
    
    // Update view
    self.peakDBLabel.text = [NSString stringWithFormat:@"%3.2f", noiseCtrl.peakDBInput];
    self.avgDBLabel.text = [NSString stringWithFormat:@"%3.2f", noiseCtrl.avgDBInput];
    
    // geo tag the data.
    data.coords = [[CLLocation alloc] initWithCoordinate:coords.coordinate altitude:coords.altitude horizontalAccuracy:coords.horizontalAccuracy verticalAccuracy:coords.verticalAccuracy timestamp:coords.timestamp];
    
    // timestamp the data.
    [data convertToISO8601:data.coords];
    
    // add it to the feature collection.
    [self.collectedData addObject:data];
    
    //clean up
    self.geoTagger.delegate = nil;
    self.geoTagger = nil;
    noiseCtrl = nil;
    [self.spinner.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (IBAction)noiseDoneButtonPushed:(id)sender {
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
