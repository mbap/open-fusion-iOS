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


// gives an array of processed images back.
- (NSMutableArray* )detectPeopleUsingImageArray:(NSMutableArray *)capturedImages;


@end

