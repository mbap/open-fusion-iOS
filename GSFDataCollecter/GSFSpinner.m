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


//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGSize screen = [[UIScreen mainScreen] bounds].size;
//    CGRect rectangle = CGRectMake(((screen.width / 2) - WIDTH/2), ((screen.height / 2) - HEIGHT/2), WIDTH, HEIGHT);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBFillColor(context, 0, 0, 0, .6);
//    CGContextSetRGBStrokeColor(context, 0, 0, 0, .6);
//    CGContextFillRect(context, rectangle);
//    CGContextStrokeRect(context, rectangle);
//}


@end
