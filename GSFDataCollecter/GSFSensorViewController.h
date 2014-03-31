//
//  ViewController.h
//  Headset Sensors
//
//  Created by Mick on 1/24/14.
//  Copyright (c) 2014 Mick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPVolumeView.h>
//#import <AudioToolbox/AudioToolbox.h>

#import <SDCAlertView.h>
#import <UIView+SDCAutoLayout.h>


@interface GSFSensorViewController : UIViewController

// input properties
@property NSTimer *secondTimer;
@property int runningTotal;
@property int lastBit;
@property double cutOff;
@property (weak, nonatomic) IBOutlet UISwitch *headsetSwitch;
@property SDCAlertView *sensorAlert;

// output properties
@property AudioComponentInstance powerTone;
@property double frequency;
@property double amplitude;
@property double sampleRate;
@property double theta;
@property (nonatomic, strong) UISlider *volumeSlider;

// function prototypes
- (void)secondTimerCallBack:(NSTimer *) timer;
- (BOOL)isHeadsetPluggedIn;
- (IBAction)flippedHeadset:(id)sender;

- (void)toggleIO:(BOOL)powerOn;
- (void) processInput: (AudioBufferList*) bufferList;

@end

// global audioIO variable to be accessed in callbacks
extern GSFSensorViewController* audioIO;
