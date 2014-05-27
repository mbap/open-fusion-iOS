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
 *  GSFOpenCvImageViewController delegate methods.
 */
@protocol GSFOpenCvImageViewControllerDelegate <NSObject>

@optional
/**
 *  Call this when you want to reset the collection view back to zero items.
 */
- (void)resetDataCollections;

@end

/**
 *  The view controller for the post processing view. After OpenCV has processed the images taken by the user the images are shown in this view.
 */
@interface GSFOpenCvImageViewController : UIPageViewController

/**
 *  Contains the original data or the images taken by the user.
 */
@property (weak, nonatomic) NSMutableArray *originalData;

/**
 *  Contains the original orientations of all images.
 */
@property (weak, nonatomic) NSMutableArray *originalOrientation;

/**
 *  The delegate object.
 */
@property (nonatomic, weak) id <GSFOpenCvImageViewControllerDelegate> delegate2;

/**
 *
 */
@property (nonatomic, weak) NSMutableArray *collectedData;

@end
