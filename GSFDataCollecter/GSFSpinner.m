//
//  GSFSpinner.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSpinner.h"

#define WIDTH  150
#define HEIGHT 100

@implementation GSFSpinner

- (id)init
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    self = [super initWithFrame:CGRectMake((screen.width/2 - WIDTH/2), (screen.height/2 - HEIGHT/2), WIDTH, HEIGHT)];
    if (self) {
        // Initialization code
        self.height = HEIGHT;
        self.width = WIDTH;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4, (self.bounds.size.height*3 / 4), self.bounds.size.width/2, self.bounds.size.height/4)];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .7; // semi transparent
        [self.layer setCornerRadius:5.0];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.spinner.hidesWhenStopped = YES;
        [self addSubview:self.spinner];
        [self addSubview:self.label];
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.height = frame.size.height;
        self.width = frame.size.width;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4, (self.bounds.size.height*3 / 4), self.bounds.size.width/2, self.bounds.size.height/4)];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .7; // semi transparent
        [self.layer setCornerRadius:5.0];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.spinner.hidesWhenStopped = YES;
        [self addSubview:self.spinner];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setLabelText:(NSString*)text;
{
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.textColor = [UIColor whiteColor];
    self.label.text = text;
}


@end
