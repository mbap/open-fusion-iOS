//
//  GSFRootViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/21/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFRootViewController.h"
#import "GSFMainViewButton.h"
#import "GSFDataTransfer.h"
#import "GSFGMapViewController.h"

@interface GSFRootViewController () <GSFDataTransferDelegate>

@property (nonatomic) NSDictionary *mapData;

@end

@implementation GSFRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get screen size
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    // create the three buttons.
    GSFMainViewButton *collect = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:0];
    
    GSFMainViewButton *saved = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64 + (screenSize.size.height - 64)/3, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:1];
    
    GSFMainViewButton *route = [[GSFMainViewButton alloc] initWithFrame:CGRectMake(0, 64 + (screenSize.size.height - 64)*2/3, screenSize.size.width, (screenSize.size.height - 64)/3) andRow:2];

    //load images into the views.
    if (screenSize.size.height > 500) {  // iPhone5/5s
        [collect setButtonImage:[UIImage imageNamed:@"collect5.png"]];
        [saved setButtonImage:[UIImage imageNamed:@"saved5.png"]];
        [route setButtonImage:[UIImage imageNamed:@"route5.png"]];
    } else {                             // iPhone4/4s
        [collect setButtonImage:[UIImage imageNamed:@"collect.png"]];
        [saved setButtonImage:[UIImage imageNamed:@"saved.png"]];
        [route setButtonImage:[UIImage imageNamed:@"route.png"]];
    }
    
    // add selector to images to cause segue.
    [collect addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [saved addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [route addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    // add buttons to view.
    [self.view addSubview:collect];
    [self.view addSubview:saved];
    [self.view addSubview:route];
}

- (void)buttonPressed:(GSFMainViewButton *)button
{
    if (0 == button.row) {
        [self performSegueWithIdentifier:@"rootCollect" sender:self];
    } else if (1 == button.row) {
        [self performSegueWithIdentifier:@"rootSaved" sender:self];
    } else {
        [self performSegueWithIdentifier:@"rootRoute" sender:self];
    }
}

- (void)handleUrlRequest:(NSString *)url
{
    GSFDataTransfer *transfer = [[GSFDataTransfer alloc] init];
    transfer.delegate = self;
    [transfer getCollectionRoute:url];
}

- (void)getRouteFromServer:(NSDictionary *)data
{
    if (data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapData = data;
            [self performSegueWithIdentifier:@"rootRoute" sender:self];
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"rootRoute"]) {
        if (self.mapData) {
            GSFGMapViewController *child = (GSFGMapViewController *)segue.destinationViewController;
            child.serverData = self.mapData;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
