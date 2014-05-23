//
//  GSFLiveDataTableViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/17/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFData.h"

/**
 *  Tableview for loading in live data details.
 */
@interface GSFLiveDataTableViewController : UITableViewController

/**
 *  The GSFData object to view the details of.
 */
@property (nonatomic, weak) GSFData *data;

@end
