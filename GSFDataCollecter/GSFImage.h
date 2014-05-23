//
//  GSFImage.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/14/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Image class used with GSFData objects.
 */
@interface GSFImage : NSObject

/**
 *  Creates a GSFImage object using the image provided.
 *
 *  @param image The image used to initialize the GSFImage.
 *
 *  @return The GSFImage that was freshly allocated.
 */
- (GSFImage*)initWithImage:(UIImage*)image;

/**
 *  Stores the original image.
 */
@property (nonatomic) UIImage *oimage;

/**
 *  Stores the original image. This is different from oimage becuase it is not resized. This image is sent to the server to keep its resolution.
 */
@property (nonatomic) UIImage *highResImage;

/**
 *  Stores the facial detection image.
 */
@property (nonatomic) UIImage *fimage;

/**
 *  Store the pedestrian detection image.
 */
@property (nonatomic) UIImage *pimage;

/**
 *  Field for saving the number of faces that are detected after OpenCV algorithms are used.
 */
@property (nonatomic) NSNumber *faceDetectionNumber;

/**
 *  Field for saving the number of pedestrians that are detected after OpenCV algorithms are used.
 */
@property (nonatomic) NSNumber *personDetectionNumber;

@end

