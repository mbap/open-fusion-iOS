//
//  GSFImageSelectorPreview.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFViewController.h"

@protocol GSFImageSelectorDelegate

- (void)removeItemFromCapturedImageArrayAtIndex:(NSInteger*)index;

@end

@interface GSFImageSelectorPreview : UIViewController

@property (nonatomic) UIImage *image;

@end
