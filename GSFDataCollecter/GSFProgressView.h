//
//  GSFProgressView.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/6/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFProgressView : UIView

/**
 *  Creates a default progess view in the middle of the screen.
 *
 *  @return A new GSFSpinner.
 */
- (id)init;

/**
 *  Creates a progress view with custom size and custom location.
 *
 *  @param frame The frame for the new GSFSpinner to be used.
 *
 *  @return A new GSFSpinner with custom frame.
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  The actual progress view itself that is inside the custom view. Since this is a regular UIActivity spinner. The developer can customize it how ever they want.
 */
@property (nonatomic) UIProgressView *progressBar;

/**
 *  Label that says why their is a progress view.
 */
@property (nonatomic) UILabel *label;

/**
 *  Width of the view containing the progress view.
 */
@property (nonatomic) NSUInteger width;

/**
 *  Height of the view containing the progress view.
 */
@property (nonatomic) NSUInteger height;

/**
 *  Sets the label text to white system font of size 16.
 *
 *  @param text The text to be inserted into the label.
 */
- (void)setLabelText:(NSString*)text;

@end
