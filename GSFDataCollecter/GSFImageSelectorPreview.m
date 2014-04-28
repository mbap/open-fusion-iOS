//
//  GSFImageSelectorPreview.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFImageSelectorPreview.h"
#import "GSFOpenCvImageProcessor.h"

@interface GSFImageSelectorPreview ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPreview;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation GSFImageSelectorPreview

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
    if (self.image.imageOrientation == UIImageOrientationUp) { // 90 counter clock
        self.image = [pro rotateImage:self.image byDegrees:-90];
    } else if (self.image.imageOrientation == UIImageOrientationDown) { // 180 rotation.
        self.image = [pro rotateImage:self.image byDegrees:90];
    }
    self.imageViewPreview.image = self.image;
    self.imageViewPreview.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)discardImageFromSet:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addItemViewController:didFinishEnteringItem:)]) {
       [self.delegate addItemViewController:self didFinishEnteringItem:self.index];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideNavAndToolbar:(UITapGestureRecognizer*)gesture {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    self.toolBar.hidden = self.navigationController.navigationBarHidden;
}

@end
