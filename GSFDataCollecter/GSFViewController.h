//
//  GSFViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"
#import "GSFImageSelectorPreview.h"
#import "GSFSensorIOController.h"
#import "GSFNoiseLevelController.h"

/**
 *  The main class used to collect image data for the GSFDataCollector application.
 */
@interface GSFViewController : GSFTaggedVCViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/**
 *  Property to determine if facial detection is to be used.
 */
@property (nonatomic) BOOL faceDetect;

/**
 *  Property to determine if pedestrian (people) detection is to be used.
 */
@property (nonatomic) BOOL personDetect;
@property (nonatomic) GSFNoiseLevelController *noiseMonitor;
@property (nonatomic) GSFSensorIOController *sensorIO;

@end
