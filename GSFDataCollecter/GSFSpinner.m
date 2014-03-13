//
//  GSFSpinner.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSpinner.h"

#define WIDTH  75
#define HEIGHT 75

@implementation GSFSpinner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .6; // semi transparent
        [self.layer setCornerRadius:5.0];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.spinner.hidesWhenStopped = YES;
        [self addSubview:self.spinner];
    }
    return self;
}

@end
