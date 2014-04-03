//
//  GSFSensorIOController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/30/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSensorIOController.h"
#import "GSFDataViewController.h"

#define kInputBus   0
#define kOutputBus  1

// UIView to attach master volume slider subview to.
GSFDataViewController* dataView;

static OSStatus inputCallback(void *inRefCon,
                                   AudioUnitRenderActionFlags 	*ioActionFlags,
                                   const AudioTimeStamp 		*inTimeStamp,
                                   UInt32 						inBusNumber,
                                   UInt32 						inNumberFrames,
                                   AudioBufferList              *ioData) {
    return noErr;
}

static OSStatus outputCallback(void *inRefCon,
                              AudioUnitRenderActionFlags 	*ioActionFlags,
                              const AudioTimeStamp          *inTimeStamp,
                              UInt32 						inBusNumber,
                              UInt32 						inNumberFrames,
                              AudioBufferList               *ioData) {
    return noErr;
}

@implementation GSFSensorIOController

@synthesize ioUnit = _ioUnit;
@synthesize inBuffer = _inBuffer;
@synthesize outBuffer = _outBuffer;
@synthesize powerTone = _powerTone;
@synthesize sensorAlert = _sensorAlert;

/**
 *  Initializes the audio session and audio units when class is instantiated.
 *
 *  @return The class instance with initailized audio session and units
 */
- (id) init {
    self = [super init];
    if (!self) return nil;
    
    // Set up AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL success;
    NSError *error;
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	if (!success) NSLog(@"ERROR viewDidLoad: AVAudioSession failed overrideOutputAudio- %@", error);
    
    success = [session setActive:YES error:&error];
    if(!success) NSLog(@"ERROR viewDidLoad: AVAudioSession failed activating- %@", error);
    
    // Set up master volume controller
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.showsRouteButton = NO;
    volumeView.showsVolumeSlider = NO;
    [dataView.view addSubview:volumeView];
    
    // Bind master volume slider to class volume slider
    __weak __typeof(self)weakSelf = self;
    [[volumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UISlider class]]) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.volumeSlider = obj;
            *stop = YES;
        }
    }];
    
    // Add volume change callback
    [self.volumeSlider addTarget:self action:@selector(handleVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    
    return self;
}


/**
 *  Auto adjuct iOS devices master volume when the sensor is attached.
 *
 *  @param sender NSNotification containing the master volume slider.
 */
- (void)handleVolumeChanged:(id)sender{
    if (self.ioUnit) self.volumeSlider.value = 1.0f;
}


- (void) setUpSensorIO {
    // Audio component description
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Output;
    desc.componentSubType       = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    desc.componentFlags         = 0;
    desc.componentFlagsMask     = 0;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get Audio units
    AudioComponentInstanceNew(inputComponent, &ioUnit);
    
    // Enable input, which disabled by default. Output enable by default
    UInt32 enableInput = 1;
    AudioUnitSetProperty(ioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &enableInput,
                         sizeof(enableInput)
                         );
    
    // Mono stream format for input
    SInt32 bytesPerSample = sizeof(AudioUnitSampleType);    // This obtains the byte size of the type that is used in filling
    AudioStreamBasicDescription monoStreamFormat;
    monoStreamFormat.mSampleRate          = 44100.00;
    monoStreamFormat.mFormatID            = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags         = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket      = bytesPerSample;
    monoStreamFormat.mBytesPerFrame       = bytesPerSample;
    monoStreamFormat.mFramesPerPacket     = 1;
    monoStreamFormat.mChannelsPerFrame    = 1;
    monoStreamFormat.mBitsPerChannel      = 8 * bytesPerSample;
    
    // Apply format to input of ioUnit
    AudioUnitSetProperty(ioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &monoStreamFormat,
                         sizeof(monoStreamFormat)
                         );
    
    
    // Stereo stream format for output
    bytesPerSample = sizeof(AudioUnitSampleType);    // This obtains the byte size of the type that is used in filling
    AudioStreamBasicDescription stereoStreamFormat;
    stereoStreamFormat.mSampleRate          = 44100.00;
    stereoStreamFormat.mFormatID            = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags         = kAudioFormatFlagsAudioUnitCanonical;
    stereoStreamFormat.mBytesPerPacket      = bytesPerSample;
    stereoStreamFormat.mBytesPerFrame       = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket     = 1;
    stereoStreamFormat.mChannelsPerFrame    = 2;
    stereoStreamFormat.mBitsPerChannel      = 8 * bytesPerSample;
    
    // Apply format to output of ioUnit
    AudioUnitSetProperty(ioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &stereoStreamFormat,
                         sizeof(stereoStreamFormat)
                         );
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = inputCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    AudioUnitSetProperty(ioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kInputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
    
    // Set output callback
    callbackStruct.inputProc = outputCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    AudioUnitSetProperty(ioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kOutputBus,
                         &callbackStruct,
                         sizeof(callbackStruct)
                         );
}


- (void) monitorSensors: (BOOL) enable {
    if (enable && self.isSensorConnected) {
        // Register audio route change listner with notification callback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListener:) name:AVAudioSessionRouteChangeNotification object:nil];
        
        // Start IO communication
        [self startCollecting];
    } else {
        // Unregister notification callbacks
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        // Stop IO communication
        if (self.ioUnit) {
            [self stopCollecting];
        }
        
        // Dismiss any existing alert
        if (self.sensorAlert) {
            [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
        
        // Set up image for Alert View
        UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
        
        // Set up Alert View
        self.sensorAlert =
        [[SDCAlertView alloc]
         initWithTitle:@"Sensor Removed"
         message:@"Please insert the GSF sensor to collect this data. Pressing \"Cancel\" will end sensor data collection."
         delegate:self
         cancelButtonTitle:nil
         otherButtonTitles:@"Cancel", nil];
        
        [alertImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.sensorAlert.contentView addSubview:alertImageView];
        [alertImageView sdc_horizontallyCenterInSuperview];
        [self.sensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[alertImageView]|"
                                                                                             options:0
                                                                                             metrics:nil
                                                                                               views:NSDictionaryOfVariableBindings(alertImageView)]];
        
        // Show Alert
        [self.sensorAlert show];

    }
}


- (void) startCollecting {
    [self setUpSensorIO];
    
    // Initialize audio unit
    OSErr err = AudioUnitInitialize(self.ioUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
    
    // Set Master Volume to 100%
    self.volumeSlider.value = 1.0f;
    
    // Start audio IO
    err = AudioOutputUnitStart(self.ioUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
}


- (void) stopCollecting {
    // Set Master Volume to 50%
    self.volumeSlider.value = 0.5f;
    
    // Stop and release audio unit
    AudioOutputUnitStop(self.ioUnit);
    AudioUnitUninitialize(self.ioUnit);
    AudioComponentInstanceDispose(self.ioUnit);
    self.ioUnit = nil;
}

/**
 *  Detects sensor connection
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
 *  Audio route change listener callback, for GSFSensorIOController class, that is invoked whenever a change occurs in the audio route.
 *
 *  @param notification A notification containing audio change reason
 */
- (void)audioRouteChangeListener: (NSNotification*)notification {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    // Set up image for alert View
    UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
    
    switch (routeChangeReason) {
        // Sensor inserted
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // Dismiss any existing alert
            if (self.sensorAlert) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
            }
            // Start IO communication
            [self startCollecting];
            break;
            
        // Sensor removed
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // Dismiss any existing alert
            if (self.sensorAlert) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
            }
            
            // Stop IO audio unit
            [self stopCollecting];
            
            // Set up alert View
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Sensor Removed"
             message:@"Please insert the GSF sensor to collect this data. Pressing \"Cancel\" will end sensor data collection."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", nil];
            
            [alertImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.sensorAlert.contentView addSubview:alertImageView];
            [alertImageView sdc_horizontallyCenterInSuperview];
            [self.sensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[alertImageView]|"
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:NSDictionaryOfVariableBindings(alertImageView)]];
            
            // Show Alert
            [self.sensorAlert show];
            break;
            
        // Category changed from PlayAndRecord
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // Dismiss any existing alert
            if (self.sensorAlert) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
            }
            
            // Stop IO audio unit
            [self stopCollecting];
            
            // Set up Alert View
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Source Changed"
             message:@"The audio input has changed from the GSF App. To continue collecting sensor data press \"Continue\". Pressing \"Cancel\" will end sensor data collection."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", @"Continue", nil];
            
            // Show Alert
            [self.sensorAlert show];
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
            
            // Stop IO audio unit
            [self stopCollecting];
            break;
            
        // Continue
        case 1:
            // Start IO communication
            [self startCollecting];
            break;
            
        default:
            NSLog(@"Blowing It In- alertView: Button index not handled: %ld", (long)buttonIndex);
            break;
    }
}


- (void) processIO: (AudioBufferList*) bufferList {
    AudioBuffer sourceBuffer = bufferList->mBuffers[0];
	
	// fix tempBuffer size if it's the wrong size
	if (inBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
		free(inBuffer.mData);
		inBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		inBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
	
	// copy incoming audio data to temporary buffer
	memcpy(inBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
    
    SInt16 *buffer = (SInt16 *) bufferList->mBuffers[0].mData;
    
    /**** DEBUG: Prints contents of input buffer to consol ****/
    for (int i = 0; i < (inBuffer.mDataByteSize / sizeof(inBuffer)); i++) {
        NSLog(@"%d", buffer[i]);
    }
}

@end
