//
//  GSFImageSelectorPreview.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"
#import "GSFViewController.h"

// Forward declaration for the protocol.
@class GSFImageSelectorPreview;

/**
 *  A protocol for telling the GSFViewController parent view that the user wants to remove a image from the collection view.
 */
@protocol GSFImageSelectorDelegate <NSObject>

@optional
/**
 *  This is called when the user wants to remove an image from the collection view from the parent view controller.
 *
 *  @param controller This controller.
 *  @param indexPath  The indexPath of the image to remove.
 */
- (void)addItemViewController:(GSFImageSelectorPreview *)controller didFinishEnteringItem:(NSIndexPath *)indexPath;

@end

/**
 *  The view controller for previewing images out of a collection view from GSFViewController objects.
 */
@interface GSFImageSelectorPreview : GSFTaggedVCViewController

/**
 *  The image that is previewd in the view.
 */
@property (nonatomic) UIImage *image;

/**
 *  The indexPath into the parent collection view that the image is located.
 */
@property (nonatomic) NSIndexPath *index;

/**
 *  The delegate object.
 */
@property (nonatomic, weak) id <GSFImageSelectorDelegate> delegate;

@end
