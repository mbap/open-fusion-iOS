//
//  GSFSavedDataImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataImageViewController.h"

@interface GSFSavedDataImageViewController ()

@end

@implementation GSFSavedDataImageViewController

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
	// Do any additional setup after loading the view.
    
    UIViewController *vc1 = [[UIViewController alloc] init];
    UIViewController *vc2 = [[UIViewController alloc] init];
    UIViewController *vc3 = [[UIViewController alloc] init];
    [vc1.view addSubview:[[UIImageView alloc] initWithImage:[self.images objectAtIndex:0]]];
    [vc2.view addSubview:[[UIImageView alloc] initWithImage:[self.images objectAtIndex:1]]];
    [vc3.view addSubview:[[UIImageView alloc] initWithImage:[self.images objectAtIndex:2]]];
    NSArray *vcs = [[NSArray alloc] initWithObjects:vc1, vc2, vc3, nil];
    
    [self setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
        // do nothing.
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
