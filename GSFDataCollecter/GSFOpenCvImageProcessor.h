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

/**
 *  Object that runs image processing tasks.
 */
@interface GSFOpenCvImageProcessor : NSObject

/**
 *  Uses OpenCV to detect human faces in the images contained with in the array of data that is passed in. GSFData objects should be passed in and the GSFImage params will be filled. GSFImages lie within these GSFData objects and they are the images that will be used during the detection algorithm.
 *
 *  @param capturedImages An array of GSFData objects.
 */
- (void)detectFacesUsingImageArray:(NSMutableArray *)capturedImages;

/**
 *  Uses OpenCV to detect human bodies in the images contained with in the array of data that is passed in. GSFData objects should be passed in and the GSFImage params will be filled. GSFImages lie within these GSFData objects and they are the images that will be used during the detection algorithm. Note: Detects Full Bodies such as a pedestrian.
 *
 *  @param capturedImages An Array of GSFData objects.
 */
- (void)detectPeopleUsingImageArray:(NSMutableArray *)capturedImages;

/**
 *  Rotates an image by a certain number of degrees. This has an effect on the bits of the image.
 *
 *  @param image   The image to be rotated.
 *  @param degrees The number in degrees that the image will be rotated by.
 *
 *  @return The image passed in rotated by the specified number of degrees.
 */
- (UIImage *)rotateImage:(UIImage*)image byDegrees:(CGFloat)degrees;

/**
 *  Takes an image and resizes it to the scale of the front facing camera. This is to speed up any processing on the image, lower disk consumption. For iPhone4/4s this is 480x640 or 640x480 and for iPhone5/5s it is (fill in).
 *
 *  @param image The image to be resized.
 *
 *  @return The resized image.
 */
- (UIImage *)resizedImage:(UIImage *)image;

@end


