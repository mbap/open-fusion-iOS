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

@protocol GSFImageSelectorDelegate

- (void)addItemViewController:(GSFImageSelectorPreview *)controller didFinishEnteringItem:(NSIndexPath *)indexPath;

@end

@interface GSFImageSelectorPreview : GSFTaggedVCViewController

@property (nonatomic) UIImage *image;
@property (nonatomic) NSIndexPath *index;
@property (nonatomic, weak) id <GSFImageSelectorDelegate> delagate;

@end
