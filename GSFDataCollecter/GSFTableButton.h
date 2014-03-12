//
//  GSFTableButton.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/11/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFTableButton : UIButton

// init with frame for section button should be placed in.
- (id)initWithFrame:(CGRect)frame forSection:(NSInteger)section;

// should be set to the section for which the button is created for.
@property (nonatomic) NSInteger section;

@end
