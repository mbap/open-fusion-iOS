//
//  GSFOpenCvImageViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFData.h"

/**
 *  The view controller for the post processing view. After OpenCV has processed the images taken by the user the images are shown in this view.
 */
@interface GSFOpenCvImageViewController : UIPageViewController

/**
 *  Contains the original data or the images taken by the user.
 */
@property (nonatomic) NSMutableArray *originalData;

/**
 *  Contains the original orientations of all images.
 */
@property (nonatomic) NSMutableArray *originalOrientation;

@end
