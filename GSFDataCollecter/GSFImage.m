//
//  GSFImage.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/14/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFImage.h"

@implementation GSFImage

- (GSFImage*)initWithImage:(UIImage*)image
{
    self.oimage = image;
    
    // create hard copy of the image that will remain unchanged.
    self.highResImage = [UIImage imageWithCGImage:image.CGImage];
    return self;
}

@end
