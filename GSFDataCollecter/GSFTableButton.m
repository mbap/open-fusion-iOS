//
//  GSFTableButton.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/11/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFTableButton.h"

@implementation GSFTableButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame forSection:(NSInteger)section
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.section = section;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
