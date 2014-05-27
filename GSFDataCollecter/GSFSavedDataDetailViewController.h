//
//  GSFSavedDataDetailViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Class used to present one collected GSFData object.
 */
@interface GSFSavedDataDetailViewController : UITableViewController

/**
 *  Contains one feature from GEOJSON featureCollection parentViewController.
 */
@property (weak, nonatomic) NSDictionary *feature;

@end
