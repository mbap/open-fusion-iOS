//
//  GSFNoiseLevelController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/31/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFNoiseLevelController.h"

@interface GSFNoiseLevelController ()

// Private variables
@property AVAudioRecorder *noiseRecorder;
@property AVAudioSession *noiseAudioSession;

@property BOOL readyToCollect;

- (BOOL) isSensorConnected;
- (void) addAlertViewToView:(NSInteger) changeReason;

@end
    
@implementation GSFNoiseLevelController

- (id) initWithView :(UIView *) view {
    self = [super init];
    if (!self) return nil;
    
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
    self.noiseRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    
    if (self.noiseRecorder) {
        [self.noiseRecorder prepareToRecord];
        self.noiseRecorder.meteringEnabled = YES;
        [self.noiseRecorder record];
    } else
        NSLog(@"%@",[err description]);
    
    // Set up AVAudioSession
    self.noiseAudioSession = [AVAudioSession sharedInstance];
    BOOL success;
    NSError *error;
    
    success = [self.noiseAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	if (!success) NSLog(@"ERROR initNoiseRecorder: AVAudioSession failed overrideOutputAudio- %@", error);
    
    success = [self.noiseAudioSession setActive:YES error:&error];
    if (!success) NSLog(@"ERROR initNoiseRecorder: AVAudioSession failed activating- %@", error);
    
    // Init audio route change reason
    self.readyToCollect = true;
    
    self.associatedView = view;
    
    return self;
}

- (void) startNoiseRecorder {
    BOOL success;
    NSError *error;
    success = [self.noiseAudioSession setActive:YES error:&error];
    if (!success) {
        NSLog(@"ERROR startNoiseRecorder: AVAudioSession failed activating- %@", error);
        self.readyToCollect = false;
    }
    else
        self.readyToCollect = true;
}

/**
 *  Takes a boolean value that if true will initialize the microphone recorder and if false will unregister from the notification center as an observer of audio route changes.
 *
 *  @param enable Boolean value that if true enables noise monitoring and if false disbales the noise monitoring.
 */
- (void) mointorNoise: (BOOL) enable {
    if (enable) {
        // Start recorder
        [self startNoiseRecorder];
        
        // Add audio route change listner callback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noiseAudioRouteChangeListener:) name:AVAudioSessionRouteChangeNotification object:nil];
        
        NSLog(@"Noise monitor STARTED");
    }
    else {
        // Remove audio route change listener callback
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        self.readyToCollect = false;
        
        NSLog(@"Noise monitor STOPPED");
    }
}


- (void) checkAudioStatus {
    if (self.isSensorConnected){
        [self addAlertViewToView:SENSOR_INSERTED];
    }
}

/**
 *  Audio route change listener callback, for GSFNoiseLevelController class, that is invoked whenever a change occurs in the audio route
 *
 *  @param notification A notification containing audio change reason
 */
- (void) noiseAudioRouteChangeListener: (NSNotification*)notification {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        // Sensor inserted
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // Stop recorder and throw alert
            self.readyToCollect = false;
            [self addAlertViewToView:SENSOR_INSERTED];
            
            NSLog(@"Sensor INSERTED");
            break;
            
        // Sensor removed
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // Start recorder
            [self startNoiseRecorder];
            
            NSLog(@"Sensor REMOVED");
            break;
            
        // Category changed from PlayAndRecord
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // Stop recorder and throw alert
            self.readyToCollect = false;
            NSLog(@"Category CHANGED");
            // Start recorder
            [self startNoiseRecorder];
            break;
            
        default:
            NSLog(@"Blowing it in- audioRouteChangeListener with route change reason: %ld", (long)routeChangeReason);
            break;
    }
}

- (void) addAlertViewToView:(NSInteger) changeReason {
    // Dismiss any existing alert
    if (self.removeSensorAlert) {
        [self.removeSensorAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    /**** UPDATE IMAGE WITH ARROW FACING AWAY FROM iPHONE ****/
    // Setup image for Alert View
    UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
    
    switch (changeReason) {
        case SENSOR_INSERTED:
            // Set up Alert View
            self.removeSensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Sensor/Headset Found"
             message:@"Please remove the GSF sensor or headset adn try collecting the sound data again."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Try Again", nil];
            
            [alertImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.removeSensorAlert.contentView addSubview:alertImageView];
            [alertImageView sdc_horizontallyCenterInSuperview];
            [self.removeSensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[alertImageView]|"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:NSDictionaryOfVariableBindings(alertImageView)]];
            
            break;
        case 2:
            // Set up Alert View
            self.removeSensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Source Changed"
             message:@"The audio input has changed from the GSF App. Please try collecting the data again."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Try Again", nil];
            break;
        default:
            NSLog(@"Blowing It In- addAlertViewToView");
    }
    
    // Add alertView to current view
    [self.associatedView addSubview:self.removeSensorAlert];
    
    // Show Alert
    [self.removeSensorAlert show];
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
            self.readyToCollect = false;
            [[NSNotificationCenter defaultCenter] removeObserver: self];
            [self.delegate popVCNoiseLevel:self];
            break;
            
        // Continue
        case 1:
            // Initialize recorder
            [self startNoiseRecorder];
            break;
            
        default:
            NSLog(@"Blowing It In- alertView: Button index not handled: %ld", (long)buttonIndex);
            break;
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
    if (self.readyToCollect) {
        // Grab current noise levels
        for (int i = 0; i < 1000; i++) {
            [self.noiseRecorder updateMeters];
        }
    
        // Set current avg and peak dB levels
        self.avgDBInput = [self.noiseRecorder averagePowerForChannel:0];
        self.peakDBInput = [self.noiseRecorder peakPowerForChannel:0];
    }
}

@end
