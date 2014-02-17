//
//  GSFOpenCvImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageViewController.h"
#import "GSFImage.h"
#import "GSFOpenCvImageProcessor.h"

@interface GSFOpenCvImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GSFOpenCvImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
    if (self.cvCapturedImages.count == 1) {
        if ([[self.cvCapturedImages objectAtIndex:0] isKindOfClass:[GSFImage class]]) {
            GSFImage *img = [self.cvCapturedImages objectAtIndex:0];
            NSNumber *num = [self.originalOrientation objectAtIndex:0];
            if (num.intValue == UIImageOrientationLeft) { // requires 90 clockwise rotation
                img.image = [pro rotateImage:img.image byDegrees:180];
            } else if (num.intValue == UIImageOrientationUp) { // 90 counter clock
                img.image = [pro rotateImage:img.image byDegrees:-90];
            } else if (num.intValue == UIImageOrientationDown) { // 180 rotation.
                img.image = [pro rotateImage:img.image byDegrees:90];
            }
            self.imageView.image = img.image;
        }
    } else if (self.cvCapturedImages.count > 1) {
        if ([[self.cvCapturedImages objectAtIndex:0] isKindOfClass:[GSFImage class]]) {
            NSMutableArray *images = [[NSMutableArray alloc] init];
            int i = 0;
            for (GSFImage *img in self.cvCapturedImages) {
                NSNumber *num = [self.originalOrientation objectAtIndex:i];
                if (num.intValue == UIImageOrientationLeft) { // requires 90 clockwise rotation
                    img.image = [pro rotateImage:img.image byDegrees:180];
                } else if (num.intValue == UIImageOrientationUp) { // 90 counter clock
                    img.image = [pro rotateImage:img.image byDegrees:-90];
                } else if (num.intValue == UIImageOrientationDown) { // 180 rotation.
                    img.image = [pro rotateImage:img.image byDegrees:90];
                }
                [images addObject:img.image];
                ++i;
            }
            self.imageView.animationImages = images;
            self.imageView.animationDuration = 5;
            self.imageView.animationRepeatCount = 0;
            [self.imageView startAnimating];
        }
    }
}


- (IBAction)hideNavBar:(UITapGestureRecognizer*)gesture {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}



@end
