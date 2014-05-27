//
//  GSFDataSelectionViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Class that allows a selection of data type to collect.
 */
@interface GSFDataSelectionViewController : UIViewController

/**
 *  The array that contains all the collected data.
 */
@property (nonatomic, weak) NSMutableArray *collectedData;

@end
