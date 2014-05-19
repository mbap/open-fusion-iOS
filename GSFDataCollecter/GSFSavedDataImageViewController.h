//
//  GSFSavedDataImageViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Class used to present the images from a single GSFData object.
 */
@interface GSFSavedDataImageViewController : UIViewController

/**
 *  An image to be displayed.
 */
@property (weak, nonatomic) UIImage *image;

@end
