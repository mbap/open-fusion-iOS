//
//  GSFSavedDataImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataImageViewController.h"

@interface GSFSavedDataImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GSFSavedDataImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
