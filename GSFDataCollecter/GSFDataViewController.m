//
//  GSFDataViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDataViewController.h"
#import "GSFViewController.h"

@interface GSFDataViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *personDetectToggle;
@property (weak, nonatomic) IBOutlet UISwitch *faceDetectionToggle;
@property (nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GSFDataViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // add background image here.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white.png"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startCollecting:(id)sender {
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
    }
}



@end
