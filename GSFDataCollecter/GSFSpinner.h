//
//  GSFSpinner.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/13/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFSpinner : UIView

/**
 *  Creates a default spinner in the middle of the screen.
 *
 *  @return A new GSFSpinner.
 */
- (id)init;

/**
 *  Creates a spinner with custom size and custom location.
 *
 *  @param frame The frame for the new GSFSpinner to be used.
 *
 *  @return A new GSFSpinner with custom frame.
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  The actual spinner itself that is inside the custom view. Since this is a regular UIActivity spinner. The developer can customize it how ever they want.
 */
@property (nonatomic) UIActivityIndicatorView *spinner;

/**
 *  Label that says why the spinner is spinning.
 */
@property (nonatomic) UILabel *label;

/**
 *  Width of the view containing the spinner.
 */
@property (nonatomic) NSUInteger width;

/**
 *  Height of the view containing the spinner.
 */
@property (nonatomic) NSUInteger height;

/**
 *  Sets the label text to white system font of size 14.
 *
 *  @param text The text to be inserted into the label.
 */
- (void)setLabelText:(NSString*)text;

@end
