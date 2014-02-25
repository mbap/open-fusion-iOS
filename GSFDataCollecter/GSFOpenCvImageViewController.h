//
//  GSFOpenCvImageViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFData.h"

@interface GSFOpenCvImageViewController : UIViewController

@property (nonatomic) NSMutableArray *dataArray; // this is the data to send.

@property (nonatomic) NSMutableArray *originalData;
@property (nonatomic) NSMutableArray *cvCapturedImages;
@property (nonatomic) NSMutableArray *originalOrientation;

@end
