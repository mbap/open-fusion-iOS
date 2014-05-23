//
//  GSFTableButton.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/11/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Custom button class for the saved data table.
 */
@interface GSFTableButton : UIButton

/**
 *  Creates a new button with a frame to be used in a section of a tableview.
 *
 *  @param frame   The frame that contains the button.
 *  @param section The section of the tableview.
 *
 *  @return A new GSFTableButton object.
 */
- (id)initWithFrame:(CGRect)frame forSection:(NSInteger)section;

/**
 *  Seciton Property. Should be set to the section for which the button is created for.
 */
@property (nonatomic) NSInteger section;

@end
