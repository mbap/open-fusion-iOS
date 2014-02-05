//
//  GSFOpenCvImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageViewController.h"

@interface GSFOpenCvImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GSFOpenCvImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.cvCapturedImages.count == 1) {
        if ([[self.cvCapturedImages objectAtIndex:0] isKindOfClass:[UIImage class]]) {
            self.imageView.image = [self.cvCapturedImages objectAtIndex:0];
        }
    } else if (self.cvCapturedImages.count > 1) {
        if ([[self.cvCapturedImages objectAtIndex:0] isKindOfClass:[UIImage class]]) {
            self.imageView.animationImages = self.cvCapturedImages;
            self.imageView.animationDuration = 5;
            self.imageView.animationRepeatCount = 0;
            [self.imageView startAnimating];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
