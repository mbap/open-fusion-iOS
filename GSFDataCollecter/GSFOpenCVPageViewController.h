//
//  GSFOpenCVPageViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/27/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  Protocol for returning the HTTP status code to objects that conform.
 */
@protocol GSFOpenCVPageViewControllerDelegate <NSObject>

@optional

/**
 *  Tells the calling class that the data should be saved to the feature collection.
 */
- (void)doneModifyingResults;

/**
 *  Updates a gsfImage detection number.
 *
 *  @param update The new value to be associated with an image.
 *  @param index The index that the view was in the page controller.
 */
- (void)updateResult:(NSNumber *)update atIndex:(NSUInteger)index;

@end



/**
 *  Helper class to present a page controller for the images from a single GSFData object.
 */
@interface GSFOpenCVPageViewController : UIViewController

/**
 *  Contains the image to be viewed
 */
@property (nonatomic) IBOutlet UIImageView *imageView;

/**
 *  The image to be viewed.
 */
@property (nonatomic) UIImage *image;

/**
 *  Stores the results that may get modified by the stepper button.
 */
@property (nonatomic) NSNumber *quantity;

/**
 *  Index to store the current view controller presented in the page controller.
 */
@property (nonatomic) NSUInteger index;

/**
 *  The delegate object.
 */
@property (nonatomic, weak) id <GSFOpenCVPageViewControllerDelegate> delegate;

@end
