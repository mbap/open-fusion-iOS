//
//  GSFCollectViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Main data collection interface class.
 */
@interface GSFCollectViewController : UIViewController

/**
 *  Array to hold one feature collection of data.
 */
@property (nonatomic) NSMutableArray *collectedData;

@end
