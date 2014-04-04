//
//  GSFPageControllerContentViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Helper class to present a page controller for the images from a single GSFData object.
 */
@interface GSFPageControllerContentViewController : UIViewController

/**
 *  Contains the image to be viewed
 */
@property (nonatomic) IBOutlet UIImageView *imageView;

/**
 *  The image to be viewed.
 */
@property (nonatomic) UIImage *image;

/**
 *  Index to store the current view controller presented in the page controller.
 */
@property (nonatomic) NSUInteger index;

@end
