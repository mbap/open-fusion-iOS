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

@interface GSFNoiseLevelController : NSObject{
    // Private variables
    AVAudioRecorder *noiseRecorder;
    double avgDBInput;
    double peakDBInput;
}

// Public control properties
@property SDCAlertView* removeSensorAlert;

// Public fuction prototypes
- (void) mointorNoise: (BOOL) enable;
- (void) collectNoise;
- (BOOL) isSensorConnected;
- (void) addAlertViewToView:(UIView*) view :(NSInteger) changeReason;

@end
