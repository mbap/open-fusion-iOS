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
#import "GSFDataTransfer.h"

#define OPENCV 0
#define ORIG   1
#define BOTH   2

@interface GSFOpenCvImageViewController () <NSURLSessionTaskDelegate, NSURLSessionDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendData;
@property (nonatomic) NSNumber *sendPref;

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
                    //img.image = [pro rotateImage:img.image byDegrees:180];
                } else if (num.intValue == UIImageOrientationUp) { // 90 counter clock
                    //img.image = [pro rotateImage:img.image byDegrees:-90];
                } else if (num.intValue == UIImageOrientationDown) { // 180 rotation.
                    //img.image = [pro rotateImage:img.image byDegrees:90];
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
    [self.view bringSubviewToFront:self.toolbar];
}

- (IBAction)sendDataToDB:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OpenCV Image(s)", @"Original Image(s)", @"Both", nil];
    [menu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
    NSInteger jsonerr = 0;
    if (OPENCV == buttonIndex) {  // open cv images
        = [driver uploadDataArray:[driver formatDataAsJSON:self.originalData]];

    } else if (ORIG == buttonIndex) { // original images
        
    } else if (BOTH == buttonIndex) { // both opencv and original.
        
    }
    if (jsonerr) {
        NSLog(@"Network Connection Failed\n Check your json objects are formatted correctly\n.");
    }
}

@end
