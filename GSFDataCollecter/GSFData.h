//
//  GSFData.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GSFData : NSObject

@property (nonatomic) UIImage *image;
@property (nonatomic) CLLocation *gpslocation;

- (GSFData*)initWithImage:(UIImage*)image;

@end
