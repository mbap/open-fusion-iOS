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
    NSMutableArray *cycler = [[NSMutableArray alloc] init];
    int i = 0;
    for (GSFData *data in self.originalData) {
        NSNumber *num = [self.originalOrientation objectAtIndex:i];
        if (num.intValue == UIImageOrientationLeft) { // requires 90 clockwise rotation
            if (data.gsfImage.fimage) {
                [cycler addObject:data.gsfImage.fimage];
            }
            if (data.gsfImage.pimage) {
                [cycler addObject:data.gsfImage.pimage];
            }
        } else if (num.intValue == UIImageOrientationUp) { // 90 counter clock
            if (data.gsfImage.fimage) {
                data.gsfImage.fimage = [pro rotateImage:data.gsfImage.fimage byDegrees:-90];
                [cycler addObject:data.gsfImage.fimage];
            }
            if (data.gsfImage.pimage) {
                data.gsfImage.pimage = [pro rotateImage:data.gsfImage.pimage byDegrees:-90];
                [cycler addObject:data.gsfImage.pimage];
            }
        } else if (num.intValue == UIImageOrientationDown) { // 180 rotation.
            if (data.gsfImage.fimage) {
                data.gsfImage.fimage = [pro rotateImage:data.gsfImage.fimage byDegrees:-90];
                [cycler addObject:data.gsfImage.fimage];
            }
            if (data.gsfImage.pimage) {
                data.gsfImage.pimage = [pro rotateImage:data.gsfImage.pimage byDegrees:-90];
                [cycler addObject:data.gsfImage.pimage];
            }
        } else {
            if (data.gsfImage.fimage) {
                [cycler addObject:data.gsfImage.fimage];
            }
            if (data.gsfImage.pimage) {
                [cycler addObject:data.gsfImage.pimage];
            }
        }
        ++i;
    }
    
    self.imageView.animationImages = cycler;
    self.imageView.animationDuration = 4;
    self.imageView.animationRepeatCount = 0;
    [self.imageView startAnimating];
    [self.view bringSubviewToFront:self.toolbar];
}

- (IBAction)sendDataToDB:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OpenCV Image(s)", @"Original Image(s)", @"Both", nil];
    [menu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_queue_t networkQueue = dispatch_queue_create("networkQueue", NULL);
    dispatch_async(networkQueue, ^{
        GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
        [driver uploadDataArray:[driver formatDataAsJSON:self.originalData withFlag:[NSNumber numberWithLong:buttonIndex]]];
    });
}

@end
