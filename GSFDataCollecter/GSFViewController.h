//
//  GSFViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"

/**
 *  The main class used to collect image data for the GSFDataCollector application.
 */
@interface GSFViewController : GSFTaggedVCViewController

/**
 *  Property to store all collected data in.
 */
@property (nonatomic, weak) NSMutableArray *collectedData;

@end
