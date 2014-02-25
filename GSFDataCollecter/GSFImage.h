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
@property (nonatomic) UIImage *image;

// field for saving the number of people or faces that are detected.
@property (nonatomic) NSNumber *detectionNumber;


@end

