//
//  GSFGMapViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/12/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"

/**
 *  The Google Maps route planner class. This can be used to find a near optimal route for traveling to many locations.
 */
@interface GSFGMapViewController : GSFTaggedVCViewController 

/**
 *  Data that may be passed through via a url scheme.
 */
@property (nonatomic, weak) NSDictionary *serverData;

@end

