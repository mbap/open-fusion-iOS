//
//  GSFSpinner.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFSpinner : UIView

// creates default spinner in the middle of the screen.
- (id)init;

// creates a spinner with custom size and custom location.
- (id)initWithFrame:(CGRect)frame;

//  since this is a regular uiactivity spinner.
//  you can customize it how ever you want
@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) UILabel *label;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

// sets the label text to white system font of size 14
- (void)setLabelText:(NSString*)text;

@end
