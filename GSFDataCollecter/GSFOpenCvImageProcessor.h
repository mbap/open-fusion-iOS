//
//  GSFOpenCvImageProcessor.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/29/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//
//  Complex Hand Wavey Class.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface GSFOpenCvImageProcessor : NSObject

// gives an array of processed images back. Facial Detection
- (NSMutableArray* )detectFacesUsingImageArray:(NSMutableArray *)capturedImages;

// gives an array of processed images back. Person Detection (whole body)
- (NSMutableArray* )detectPeopleUsingImageArray:(NSMutableArray *)capturedImages;

// rotate image by degrees.
- (UIImage *)rotateImage:(UIImage*)image byDegrees:(CGFloat)degrees;

@end

