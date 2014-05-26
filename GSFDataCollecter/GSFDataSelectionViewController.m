//
//  GSFDataSelectionViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDataSelectionViewController.h"
#import "GSFMainViewButton.h"
#import "GSFViewController.h"

@interface GSFDataSelectionViewController ()

- (IBAction)buttonPressed:(id)sender;

@end

@implementation GSFDataSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get screen size
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    // create the three buttons.
    GSFMainViewButton *camera = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:0];
    
    GSFMainViewButton *sound = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64 + (screenSize.size.height - 64)/3, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:1];
    
    GSFMainViewButton *pluggable = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64 + (screenSize.size.height - 64)*2/3, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:2];
    
    //load images into the views.
    if (screenSize.size.height > 500) {  // iPhone5/5s
        [camera setButtonImage:[UIImage imageNamed:@"image5.png"]];
        [sound setButtonImage:[UIImage imageNamed:@"sound5.png"]];
        [pluggable setButtonImage:[UIImage imageNamed:@"pluggable5.png"]];
    } else {                             // iPhone4/4s
        [camera setButtonImage:[UIImage imageNamed:@"image4.png"]];
        [sound setButtonImage:[UIImage imageNamed:@"sound4.png"]];
        [pluggable setButtonImage:[UIImage imageNamed:@"pluggable4.png"]];
    }
    
    // add selector to images to cause segue.
    [camera addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [sound addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [pluggable addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    // add buttons to view.
    [self.view addSubview:camera];
    [self.view addSubview:sound];
    [self.view addSubview:pluggable];
}

- (IBAction)buttonPressed:(id)sender
{
    if ([sender isKindOfClass:[GSFMainViewButton class]]) {
        GSFMainViewButton *button = (GSFMainViewButton *)sender;
        if (0 == button.row) {
            [self performSegueWithIdentifier:@"cameraSelection" sender:self];
        } /*else if (1 == button.row) {
            [self performSegueWithIdentifier:@"" sender:self];
        } else if (2 == button.row) {
            [self performSegueWithIdentifier:@"" sender:self];
        }*/
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // in all cases pass the data array forward.
    if ([[segue identifier] isEqualToString:@"cameraSelection"]) {
        GSFViewController *child = (GSFViewController *)segue.destinationViewController;
        child.collectedData = self.collectedData;
    } /*else if ([[segue identifier] isEqualToString:@""]) {
        GSFDataSelectionViewController *child = (GSFDataSelectionViewController *)segue.destinationViewController;
        child.collectData = self.collectedData;
    } else if ([[segue identifier] isEqualToString:@""]) {
        GSFDataSelectionViewController *child = (GSFDataSelectionViewController *)segue.destinationViewController;
        child.collectData = self.collectedData;
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
