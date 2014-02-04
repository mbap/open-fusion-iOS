//
//  GSFImageSelectorPreview.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFImageSelectorPreview.h"

@interface GSFImageSelectorPreview ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPreview;

@end

@implementation GSFImageSelectorPreview

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.imageViewPreview.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)discardImageFromSet:(id)sender
{
    [self.delagate addItemViewController:self didFinishEnteringItem:self.index];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
