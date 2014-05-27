//
//  GSFSensorViewController.h
//  GSFDataCollecter
//
//  Created by Mick Bennett on 5/27/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFSensorIOController.h"

@interface GSFSensorViewController : UIViewController


/**
 *  Property to store all collected data in.
 */
@property (nonatomic, weak) NSMutableArray *collectedData;


@end
