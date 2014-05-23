//
//  GSFMainViewButton.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/21/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Button class that allows for sleek user interface for the root view controller.
 */
@interface GSFMainViewButton : UIButton

/**
 *  Creates a main button view with custom size and custom location.
 *
 *  @param frame The frame for the new view to be used.
 *
 *  @return A new main button with custom frame.
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  Creates a main button view with custom size and custom location.
 *
 *  @param frame The frame for the new view to be used.
 *  @param row   The row in the view that the button is displayed. Can be used for segueing.
 *
 *  @return A new main button with custom frame and row.
 */
- (id)initWithFrame:(CGRect)frame andRow:(NSUInteger)row;

/**
 *  Sets the image inside the imageview.
 *
 *  @param image The image to set inside the imageView.
 */
- (void)setButtonImage:(UIImage *)image;

/**
 *  The row the button is in. In this app its row 0, 1, or 2.
 */
@property (nonatomic) NSUInteger row;

@end
