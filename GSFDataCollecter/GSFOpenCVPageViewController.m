//
//  GSFOpenCVPageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/27/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCVPageViewController.h"

@interface GSFOpenCVPageViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *result;

@end

@implementation GSFOpenCVPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.imageView.image = self.image;
    [self.view bringSubviewToFront:self.toolbar];
    [self.view bringSubviewToFront:self.result];
    [self.view bringSubviewToFront:self.stepper];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.result.text = [NSString stringWithFormat:@"%d", self.quantity.intValue];
    self.stepper.value = self.quantity.doubleValue;
}

- (IBAction)doneWithEdits:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(doneModifyingResults)]) {
        [self.delegate doneModifyingResults];
    }
}

- (IBAction)stepperPressed:(id)sender
{
    // stepper pressed.
    NSNumber *newval = [NSNumber numberWithDouble:self.stepper.value];
    self.result.text = [NSString stringWithFormat:@"%d", newval.intValue];
    if ([self.delegate respondsToSelector:@selector(updateResult:atIndex:)]) {
        [self.delegate updateResult:newval atIndex:self.index];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
