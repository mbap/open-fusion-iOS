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

@class GSFNoiseLevelController;
@protocol GSFNoiseLevelControllerDelgate <NSObject>

- (void) popVCNoiseLevel:(GSFNoiseLevelController *) noiseLevelController;

@end

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

@property UIView *associatedView;               // *** View for ONE view alert system ***

// Public fuction prototypes
- (id) initWithView: (UIView *) view;       // Initializes noise object. Takes the calling UIViews view for alert messages
- (void) mointorNoise: (BOOL) enable;
- (void) collectNoise;
- (void) checkAudioStatus;
- (BOOL) isSensorConnected;
- (void) addAlertViewToView:(NSInteger) changeReason;

// Delegate to pop viewcontroller when an alert occurs
@property (nonatomic, weak) id popVCNoiseLevelDelegate;

@end
