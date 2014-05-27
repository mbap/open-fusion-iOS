//
//  GSFNoiseLevelController.h
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/31/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>

#import <SDCAlertView.h>
#import <UIView+SDCAutoLayout.h>

#define NO_CHANGE               0
#define SENSOR_INSERTED         1
#define AUDIO_CATEGORY_CHANGE   2

@interface GSFNoiseLevelController : NSObject{
    // Private variables
    AVAudioRecorder *noiseRecorder;
    AVAudioSession *noiseAudioSession;
}

// Public control properties
@property SDCAlertView* removeSensorAlert;
@property double avgDBInput;
@property double peakDBInput;
@property int audioChangeReason;
@property BOOL readyToCollect;

// Public fuction prototypes
- (void) mointorNoise: (BOOL) enable;
- (void) collectNoise;
- (BOOL) isSensorConnected;
- (void) addAlertViewToView:(UIView*) view :(NSInteger) changeReason;

@end
