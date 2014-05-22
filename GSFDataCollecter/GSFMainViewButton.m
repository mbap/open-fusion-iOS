//
//  GSFMainViewButton.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/21/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFMainViewButton.h"

@implementation GSFMainViewButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.imageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andRow:(NSUInteger)row
{
    self = [self initWithFrame:frame];
    self.row = row;
    return self;
}

- (void)setButtonImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

@end
