//
//  GSFSensorIOController.h
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/30/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>               // Audio Session APIs
#import <MediaPlayer/MPVolumeView.h>                // For Master Volume control
#import <AudioUnit/AudioUnit.h>                     // Audio Unit access
#import <AudioToolbox/AudioToolbox.h>               // Audio unit control
#import <Accelerate/Accelerate.h>                   // DSP functions

#import <SDCAlertView.h>                            // Custom Alert View
#import <UIView+SDCAutoLayout.h>                    // Layout Control for custom Alert View

@class GSFSensorIOController;

@protocol GSFSensorIOControllerDelgate <NSObject>

- (void) endCollection:(GSFSensorIOController *) sensorIOController;
- (void) popVCSensorIO:(GSFSensorIOController *) sensorIOController;

@end


// Public interface
@interface GSFSensorIOController : NSObject

// Public control properties
@property SDCAlertView *sensorAlert;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic) int audioChangeReason;
@property BOOL audioSetup;

// Public function prototypes
/**
 *  Initializes sensor object.
 *
 *  @param view         Takes the calling UIViews view for alert messages.
 *  @return id          The class instance with initailized audio session and units
 */
- (id) initWithView: (UIView *) view;

/**
 *  Start/Stops the monitoring of an attached sensor
 *
 *  @param bool         A flag representing the whether to enable or disable sensor monitoring tools.
 */
- (void) monitorSensors: (BOOL) enable;     // Starts the power and communication with micro


/**
 *  Averages sample readings from micro and returns an NSMutableArray of the results.
 *
 *  @return nsmuableArray An NSMutableArray containing the decoded sensor data.
 */
- (NSMutableArray*) collectSensorData;      // Returns an array of sensor readings

// Delegate to limit number of sensor packets collected
@property (nonatomic, weak) id <GSFSensorIOControllerDelgate> delegate;

@end
