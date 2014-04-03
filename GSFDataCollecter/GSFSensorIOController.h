//
//  GSFSensorIOController.h
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/30/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MediaPlayer/MPMusicPlayerController.h>   // Not sure ATM.
#import <AVFoundation/AVFoundation.h>               // Audio session APIs
#import <MediaPlayer/MPVolumeView.h>                // For master volume control
#import <AudioToolbox/AudioToolbox.h>               // Audio unit control
#import <Accelerate/Accelerate.h>                   // DSP functions

#import <SDCAlertView.h>                            // Custom alert view
#import <UIView+SDCAutoLayout.h>                    // Layout Control for custom alert view


@interface GSFSensorIOController : NSObject {
    // Private variables
    AudioComponentInstance ioUnit;
    AudioBuffer inBuffer;
    AudioBuffer outBuffer;
    AudioBuffer powerTone;
}

// Property declarations correspoding to instance variables above
@property AudioComponentInstance ioUnit;
@property (readonly) AudioBuffer inBuffer;
@property AudioBuffer outBuffer;
@property AudioBuffer powerTone;

// Public control properties
@property SDCAlertView *sensorAlert;
@property (nonatomic, strong) UISlider *volumeSlider;

// Function prototypes
- (void) monitorSensors: (BOOL) enable;
- (void) processIO: (AudioBufferList*) bufferList;

@end
