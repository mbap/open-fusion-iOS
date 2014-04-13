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

@interface GSFViewController : GSFTaggedVCViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) BOOL faceDetect;
@property (nonatomic) BOOL personDetect;
@property (nonatomic) GSFNoiseLevelController *noiseMonitor;
@property (nonatomic) GSFSensorIOController *sensorIO;

@end
