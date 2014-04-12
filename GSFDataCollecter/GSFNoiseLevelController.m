//
//  GSFNoiseLevelController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/31/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFNoiseLevelController.h"

@implementation GSFNoiseLevelController

- (id) init {
    self = [super init];
    if (!self) return nil;
    
    [self initNoiseRecorder];
    
    return self;
}

- (void) initNoiseRecorder {
    // MIC Input Setup
    NSURL *url = [NSURL fileURLWithPath:@"dev/null"];
    NSDictionary *settings =  [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:44100.0],
                               AVSampleRateKey,
                               [NSNumber numberWithInt:kAudioFormatAppleLossless],
                               AVFormatIDKey,
                               [NSNumber numberWithInt:1],
                               AVNumberOfChannelsKey,
                               [NSNumber numberWithInt:AVAudioQualityMax],
                               AVEncoderAudioQualityKey,
                               nil];
    NSError *err;
    noiseRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    
    if (noiseRecorder) {
        [noiseRecorder prepareToRecord];
        noiseRecorder.meteringEnabled = YES;
        [noiseRecorder record];
    } else
        NSLog(@"%@",[err description]);
    
    // Set up AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL success;
    NSError *error;
    
    success = [session setCategory:AVAudioSessionCategoryRecord error:&error];
	if (!success) NSLog(@"ERROR initNoiseRecorder: AVAudioSession failed overrideOutputAudio- %@", error);
    
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"ERROR initNoiseRecorder: AVAudioSession failed activating- %@", error);
    
    // Add audio route change listner
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListener::) name:AVAudioSessionRouteChangeNotification object:nil];
}

/**
 *  Audio route change listener callback, for GSFNoiseLevelController class, that is invoked whenever a change occurs in the audio route
 *
 *  @param notification A notification containing audio change reason
 */
- (void) audioRouteChangeListener: (NSNotification*)notification : (UIView*) view {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        // Sensor inserted
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            break;
            
        // Sensor removed
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // Dismiss any existing alert
            if (self.removeSensorAlert) {
                [self.removeSensorAlert dismissWithClickedButtonIndex:0 animated:YES];
            }
            // Initialize recorder
            [self initNoiseRecorder];
            break;
            
        // Category changed from Record
        case AVAudioSessionRouteChangeReasonCategoryChange:
            
            break;
            
        default:
            NSLog(@"Blowing it in- audioRouteChangeListener with route change reason: %ld", (long)routeChangeReason);
            break;
    }
}

/**
 *  Custom alert view callback handler that responds to user button selection
 *
 *  @param alertView   A SDCAlertView instance
 *  @param buttonIndex The button index selected by user.
 */
- (void)alertView:(SDCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // Cancel Button pushed
        case 0:
            // Unregister notification center observer
            [[NSNotificationCenter defaultCenter] removeObserver: self];
            break;
            
        // Continue
        case 1:
            // Initialize recorder
            [self initNoiseRecorder];
            break;
            
        default:
            NSLog(@"Blowing It In- alertView: Button index not handled: %ld", (long)buttonIndex);
            break;
    }
}

/**
 *  Takes a boolean value that if true will initialize the microphone recorder and if false will unregister from the notification center as an observer of audio route changes.
 *
 *  @param enable Boolean value that if true enables noise monitoring and if false disbales the noise monitoring.
 */
- (void) mointorNoise: (BOOL) enable {
    if (enable && !self.isSensorConnected) [self initNoiseRecorder];
    else {
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }
}

/**
 *  Detects sensor/headset connection
 *
 *  @return True if audio route is the one used by sensor system and false otherwise
 */
- (BOOL) isSensorConnected {
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    NSString *portNameOut = [[outputs objectAtIndex:0] portName];
    NSArray *inputs = [[AVAudioSession sharedInstance] currentRoute].inputs;
    NSString *portNameIn = [[inputs objectAtIndex:0] portName];
    
    /* Known routes-
     Headset Microphone
     Headphones
     iPhone Microphone
     Receiver
     */
    
    /*************
     *** Debug:
     ***    Shows current audio in/out routes iDevice
     *************/
    //NSLog(@"%@", portNameOut);
    //NSLog(@"%@", portNameIn);
    
    if ([portNameOut isEqualToString:@"Headphones"] && [portNameIn isEqualToString:@"Headset Microphone"])
        return YES;
    
    return NO;
}

/**
 *  Collects current average and peak dB levels when invoked and adds these results to the data collection packet that can be saved or sent to the server.
 */
- (void) collectNoise {
    // Grab current noise levels
    [noiseRecorder updateMeters];
    
    // Set current avg and peak dB levels
    avgDBInput = [noiseRecorder averagePowerForChannel:0];
    peakDBInput = [noiseRecorder peakPowerForChannel:0];
    
    /**** ADD COLLECTION PACKAGE ****/
    // Add levels to collection suit
}

- (void) addAlertViewToView:(UIView*) view :(NSInteger) changeReason {
    // Dismiss any existing alert
    if (self.removeSensorAlert) {
        [self.removeSensorAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    /**** UPDATE IMAGE WITH ARROW FACING AWAY FROM iPHONE ****/
    // Setup image for Alert View
    UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
    
    switch (changeReason) {
        case 0:
            // Set up Alert View
            self.removeSensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Sensor/Headset Found"
             message:@"Please remove the GSF sensor or headset to collect noise data. Pressing \"Cancel\" will end noise level data collection."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", nil];
            
            [alertImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.removeSensorAlert.contentView addSubview:alertImageView];
            [alertImageView sdc_horizontallyCenterInSuperview];
            [self.removeSensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[alertImageView]|"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:NSDictionaryOfVariableBindings(alertImageView)]];
            
            // Add alertView to current view
            [view addSubview:self.removeSensorAlert];
            
            // Show Alert
            [self.removeSensorAlert show];            break;
        case 1:
            // Set up Alert View
            self.removeSensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Source Changed"
             message:@"The audio input has changed from the GSF App. To continue collecting noise level data press \"Continue\". Pressing \"Cancel\" will end noise level data collection."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", @"Continue", nil];
            break;
        default:
            NSLog(@"Blowing It In- addAlertViewToView");
    }
    
    // Add alertView to current view
    [view addSubview:self.removeSensorAlert];
    
    // Show Alert
    [self.removeSensorAlert show];
}

@end
