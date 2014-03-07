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

//  Facial Detection. pass an array of gsfdata objects and gsfimage params will be filled.
- (void)detectFacesUsingImageArray:(NSMutableArray *)capturedImages;

// Person Detection (whole body) pass an array of gsfdata objects and gsfimage params will be filled.
- (void)detectPeopleUsingImageArray:(NSMutableArray *)capturedImages;

// rotate image by degrees.
- (UIImage *)rotateImage:(UIImage*)image byDegrees:(CGFloat)degrees;

// scales an image to 480x640 or 640x480 depending on its orientaiton
- (UIImage *)resizedImage:(UIImage *)image;

@end


