//
//  GSFPhotoSelector.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"
#import "GSFImageSelectorPreview.h"



@interface GSFPhotoSelector : GSFTaggedVCViewController <GSFImageSelectorDelegate>

@property (nonatomic) NSMutableArray *capturedImages; //array of user pics

@end
