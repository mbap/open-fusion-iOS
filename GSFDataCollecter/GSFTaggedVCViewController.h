//
//  GSFTaggedVCViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  Wrapper controller for a normal UIViewController. Just adds GPS capabilities.
 */
@interface GSFTaggedVCViewController : UIViewController <CLLocationManagerDelegate>

/**
 *  A lococation manager so that gps data can be taken.
 */
@property (nonatomic) CLLocationManager *locationManager;

/**
 *  Toggles gps on or off. Currenly not used.
 */
@property (nonatomic) BOOL locationToggle;

@end
