//
//  GSFSavedDataDetailViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFSavedDataDetailViewController : UITableViewController

// contains one feature from GEOJSON featureCollection parentViewController
@property (nonatomic) NSDictionary *feature;

@end
