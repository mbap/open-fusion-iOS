//
//  GSFImage.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/14/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFImage : NSObject

// init with an image.
- (GSFImage*)initWithImage:(UIImage*)image;

// field for storing an image.
@property (nonatomic) UIImage *oimage;  //original
@property (nonatomic) UIImage *fimage;  //face detect
@property (nonatomic) UIImage *pimage;  //person detect

// field for saving the number of faces that are detected.
@property (nonatomic) NSNumber *faceDetectionNumber;

// field for saving the number of people are detected.
@property (nonatomic) NSNumber *personDetectionNumber;

@end

