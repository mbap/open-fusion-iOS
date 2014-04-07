//
//  GSFProgressView.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/6/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFProgressView.h"

#define WIDTH 300
#define HEIGHT 100

@implementation GSFProgressView

- (id)init
{
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    self = [super initWithFrame:CGRectMake((screen.width/2 - WIDTH/2), (screen.height/2 - HEIGHT/2), WIDTH, HEIGHT)];
    if (self) {
        // Initialization code
        self.height = HEIGHT;
        self.width = WIDTH;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.4, (self.frame.size.height*.6), self.frame.size.width/2, self.frame.size.height/3)];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .7; // semi transparent
        [self.layer setCornerRadius:5.0];
        self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressBar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.progressBar];
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
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/4, (self.frame.size.height*2 / 3), self.frame.size.width/2 + HEIGHT/2, self.frame.size.height/3)];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .7; // semi transparent
        [self.layer setCornerRadius:5.0];
        self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressBar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.progressBar];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setLabelText:(NSString*)text;
{
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.textColor = [UIColor whiteColor];
    self.label.text = text;
}

@end
