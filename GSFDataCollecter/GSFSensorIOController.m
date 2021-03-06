//
//  GSFSensorIOController.m
//  GSFDataCollecter
//
//  Created by Mick Bennett on 3/30/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSensorIOController.h"

// Comment out to remove DEBUG prints
//#define DEBUG_AVG         //  Prints average sample reading
//#define DEBUG_SUM         //  Prints sumation of average sample reading
#define DEBUG_PACKETS     //  Prints the packets recieved
#define DEBUG_WRITE       //  Creates new file that will contain raw input form mic
//#define DEBUG_REMOVE      //  Removes last file containing raw input from mic

// Code Macros
#define OUTPUTBUS          0
#define INPUTBUS           1
#define SAMPLERATE         44100

#define MAX_BUF                 1000000
#define HIGH_MIN_AVG            175000
#define LOW_STATE               0
#define HIGH_STATE              1
#define UNKNOWN_STATE           -1
#define HALF_PERIOD_TC          216     // Tested working for multi bytes/packet
#define NUM_SAMPLES_PER_PERIOD  8       // Tested working for multi bytes/packet
#define SAMPLES_PER_CHECK       HALF_PERIOD_TC / NUM_SAMPLES_PER_PERIOD

#define UNSET_STATE         -1
#define SENSOR_CONNECTED    0
#define SENSOR_DISCONNECTED 1
#define APP_CHANGE          2
#define VOLUME_FAILURE      3
#define CHANNEL_FAILURE     4

// Private interface
@interface GSFSensorIOController () {
    AUGraph auGraph;
    AUNode ioNode;
    AUNode highPassNode;
}
@property (assign) AudioUnit ioUnit;            // Audio unit handles in IO
@property AVAudioSession *sensorAudioSession;   // Pointer to sensor required audio session
@property double sampleRate;                    // Sample rate
@property double bufferDuration;
@property double sinPhase;                      // Latest point of sine wave for power tone

@property NSMutableArray *inputDataDecoded;     // Decoded input
@property NSMutableArray *sensorData;           // Final sensor data
@property NSMutableArray *rawInputData;         // Raw input data for DEBUG printing
@property NSMutableArray *temperatureReadings;      // All temperature readings
@property NSMutableArray *humidityReadings;         // All humidity readings
@property BOOL reqNewData;                      // Flag for new communication to micro
@property BOOL waitACycle;
@property BOOL badChannel;

@property BOOL startEdge;                       // First rise of input signal signifies start edge
@property BOOL firstHalfPeriod;                 // First half period for start edge
@property int curState;                         // Current input state value (HIGH or LOW)
@property int lastState;                        // Last input state to compare with current state
@property int lastSampleEdge;
@property int curWindowState;
@property int lastWindowState;
@property int secondLastWindowState;
@property int doubleState;                      // Marks last double state (HIGH-HIGH or LOW-LOW)
@property int halfPeriodCount;                  // Count for half of the expected input period
@property int halfPeriodSum;
@property int bit_num;
@property int checkSum;
@property int crc_index;
@property int first_sample;

@property UIView *associatedView;               // *** View for ONE view alert system ***

- (void) processIO: (AudioBufferList*) bufferList;
- (void) channelFailure;
- (void) checkAudioStatus;                  // Checks for changes in audio conditions that could disturb collection process.

@end

static OSStatus hardwareIOCallback(void                         *inRefCon,
                                   AudioUnitRenderActionFlags 	*ioActionFlags,
                                   const AudioTimeStamp 		*inTimeStamp,
                                   UInt32 						inBusNumber,
                                   UInt32 						inNumberFrames,
                                   AudioBufferList              *ioData) {
    // Scope reference to GSFSensorIOController class
    GSFSensorIOController *sensorIO = (__bridge GSFSensorIOController *) inRefCon;
    
    // Grab the samples and place them in the buffer list
    AudioUnit ioUnit = sensorIO.ioUnit;
    
    OSStatus result = AudioUnitRender(ioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      INPUTBUS,
                                      inNumberFrames,
                                      ioData);
    
    
    // Process input data
    [sensorIO processIO:ioData];
    
    // Set up power tone attributes
    float freq = 20000.00f;
    float sampleRate = sensorIO.sampleRate;
    float phase = sensorIO.sinPhase;
    float sinSignal;
    
    double phaseInc = 2 * M_PI * freq / sampleRate;
    
    if (!sensorIO.badChannel) {
        // Write to output buffers
        for(size_t i = 0; i < ioData->mNumberBuffers; ++i) {
            AudioBuffer buffer = ioData->mBuffers[i];
            for(size_t sampleIdx = 0; sampleIdx < inNumberFrames; ++sampleIdx) {
                // Grab sample buffer
                SInt16 *sampleBuffer = buffer.mData;
                
                // Generate power tone on left channel
                sinSignal = sin(phase);
                sampleBuffer[2 * sampleIdx] = (SInt16)((sinSignal * 60534.0f) /2);  // (SInt16)((sinSignal * 32767.0f) /2);
                
                // Write to commands to Atmel on right channel as necessary
                if(sensorIO.reqNewData)
                    sampleBuffer[2*sampleIdx + 1] = (SInt16)((sinSignal * 32767.0f) /2);     // (SInt16)((sinSignal * 32767.0f) /2);
                else
                    sampleBuffer[2*sampleIdx + 1] = 0;
                
                phase += phaseInc;
                if (phase >= 2 * M_PI * freq) {
                    phase -= (2 * M_PI * freq);
                }
            }
        }
        
        // Store sine wave phase for next callback
        sensorIO.sinPhase = phase;
    }
    
    return result;
}

@implementation GSFSensorIOController

@synthesize ioUnit = _ioUnit;

/**
 *  Initializes the audio session and audio units when class is instantiated.
 *
 *  @return The class instance with initailized audio session and units
 */
- (id) initWithView :(UIView *) view {
    self = [super init];
    if (!self) {
        NSLog(@"ERROR init: GSFSensorIOController Failed to initialize");
        return nil;
    }
    
    // Set up AVAudioSession
    self.sensorAudioSession = [AVAudioSession sharedInstance];
    BOOL success;
    NSError *error;
    
    // Set audio category
    success = [self.sensorAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	if (!success) NSLog(@"ERROR init: AVAudioSession failed setting category- %@", error);
    
    // Request preferred hardware sample rate
    self.sampleRate = SAMPLERATE;
    success = [self.sensorAudioSession setPreferredSampleRate:self.sampleRate error:&error];
	if (!success) NSLog(@"ERROR init: AVAudioSession failed setting sample rate- %@", error);
    
    // Set buffer duration. Idealy it would be 5 ms for low latency
    success = [self.sensorAudioSession setPreferredIOBufferDuration:0.005 error:&error];
	if (!success) NSLog(@"ERROR init: AVAudioSession failed setting buffer duration- %@", error);
    
    // Make the sensor AVAudioSession active
    success = [self.sensorAudioSession setActive:YES error:&error];
    if(!success) NSLog(@"ERROR init: AVAudioSession failed activating- %@", error);
    
    // Grab actual sample rate and buffer duration
    self.sampleRate = [self.sensorAudioSession sampleRate];
    if(self.sampleRate != 44100.00) NSLog(@"WARNING init: Actual sample rate is: %f", self.sampleRate);
    self.bufferDuration = [self.sensorAudioSession IOBufferDuration];
    if(self.bufferDuration != 0.005) NSLog(@"WARNING init: Actual buffer duration is: %f", self.bufferDuration);
    
    // Add pointer to associated UIView controlerr for alerts
    self.associatedView = view;
    
    // Set up master volume controller
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.showsRouteButton = NO;
    volumeView.showsVolumeSlider = NO;
    [self.associatedView addSubview:volumeView];
    
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
    
    // Initialize audio graph
    self.audioSetup = false;
    self->auGraph = nil;
    self.sensorAlert = nil;
    
    return self;
}


/**
 *  Auto adjuct iOS devices master volume when the sensor is attached.
 *
 *  @param sender NSNotification containing the master volume slider.
 */
- (void) handleVolumeChanged:(id)sender{
    if (self->auGraph != nil) {
        self.volumeSlider.value = 1.0f;   
    }
}


- (void) setUpSensorIO {
    // Initialize input data buffer/states
    self.reqNewData = true;
    self.startEdge = false;
    self.firstHalfPeriod = false;
    self.doubleState = LOW_STATE;
    self.curState = LOW_STATE;
    self.lastState = UNKNOWN_STATE;
    self.lastSampleEdge = 0;
    self.curWindowState = UNKNOWN_STATE;
    self.lastWindowState = UNKNOWN_STATE;
    self.secondLastWindowState = UNKNOWN_STATE;
    self.halfPeriodCount = 0;
    self.halfPeriodSum = 0;
    self.bit_num = 0;
    self.checkSum = 0;
    self.crc_index = 0;
    self.first_sample = 0;
    self.waitACycle = false;
    self.badChannel = false;
    
    // Free array's
    self.sensorData = nil;
    self.temperatureReadings = nil;
    self.humidityReadings = nil;
    self.inputDataDecoded = nil;
    self.rawInputData = nil;
    
    self.sensorData = [[NSMutableArray alloc] init];
    self.temperatureReadings = [[NSMutableArray alloc] init];
    self.humidityReadings = [[NSMutableArray alloc] init];
    self.inputDataDecoded = [[NSMutableArray alloc] init];
    self.rawInputData = [[NSMutableArray alloc] init];
    
    // RemoteIO component description
    AudioComponentDescription ioUnitdesc;
    bzero(&ioUnitdesc, sizeof(AudioComponentDescription));
    ioUnitdesc.componentType          = kAudioUnitType_Output;
    ioUnitdesc.componentSubType       = kAudioUnitSubType_RemoteIO;
    ioUnitdesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitdesc.componentFlags         = 0;
    ioUnitdesc.componentFlagsMask     = 0;
    
    // Stereo ASBD
    AudioStreamBasicDescription stereoStreamFormat;
    bzero(&stereoStreamFormat, sizeof(AudioStreamBasicDescription));
    stereoStreamFormat.mSampleRate          = SAMPLERATE;
    stereoStreamFormat.mFormatID            = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags         = kAudioFormatFlagsCanonical;
    stereoStreamFormat.mBytesPerPacket      = 4;
    stereoStreamFormat.mBytesPerFrame       = 4;
    stereoStreamFormat.mFramesPerPacket     = 1;
    stereoStreamFormat.mChannelsPerFrame    = 2;
    stereoStreamFormat.mBitsPerChannel      = 16;
    
    BOOL success;
    NSError *error;
    OSErr err = noErr;
    @try {
        // Make the sensor AVAudioSession active
        success = [self.sensorAudioSession setActive:YES error:&error];
        if(!success) NSLog(@"ERROR init: AVAudioSession failed activating- %@", error);
        
        // Create new AUGraph
        err = NewAUGraph(&auGraph);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to create AUGraph: %hd", err);
        
        // Add nodes to AUGraph
        err = AUGraphAddNode(auGraph,
                             &ioUnitdesc,
                             &ioNode);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to add AUNode: %hd", err);
        
        // Open AUGraph
        err = AUGraphOpen(auGraph);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to open AUGraph: %hd", err);
        
        // Add AUGraph nodes info
        err = AUGraphNodeInfo(auGraph,
                              ioNode,
                              NULL,
                              &_ioUnit);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to add node info: %hd", err);
        
        // Enable input, which is disabled by default.
        UInt32 enabled = 1;
        err = AudioUnitSetProperty(_ioUnit,
                             kAudioOutputUnitProperty_EnableIO,
                             kAudioUnitScope_Input,
                             INPUTBUS,
                             &enabled,
                             sizeof(enabled));
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to enable input: %hd", err);
        
        // Apply format to input of ioUnit
        err = AudioUnitSetProperty(_ioUnit,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Input,
                             OUTPUTBUS,
                             &stereoStreamFormat,
                             sizeof(stereoStreamFormat));
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to set input ASBD: %hd", err);
        
        // Apply format to output of ioUnit
        err = AudioUnitSetProperty(_ioUnit,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output,
                             INPUTBUS,
                             &stereoStreamFormat,
                             sizeof(stereoStreamFormat));
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to set output ASBD: %hd", err);
        
        // Set hardware IO callback
        AURenderCallbackStruct callbackStruct;
        callbackStruct.inputProc = hardwareIOCallback;
        callbackStruct.inputProcRefCon = (__bridge void *)(self);
        err = AUGraphSetNodeInputCallback(auGraph,
                                          ioNode,
                                          OUTPUTBUS,
                                          &callbackStruct);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to set IO callback: %hd", err);
        
        // Initialize AudioGraph
        err = AUGraphInitialize(auGraph);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to initialize AUGraph: %hd", err);
        
        // Start audio unit
        err = AUGraphStart(auGraph);
        NSAssert1(err == noErr, @"ERROR setUpSensorIO: failed to start AUGraph: %hd", err);
        
        self.audioSetup = true;
    }
    @catch (NSException *exception) {
        NSLog(@"setUpSensorIO- Failed with exception: %@", exception);
        self.audioSetup = false;
    }
}


- (void) monitorSensors: (BOOL) enable {
    if (enable){
        if (!self.audioSetup) {
            // Start IO communication
            [self startCollecting];
        }
        
        // Register audio route change listner with notification callback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListener:) name:AVAudioSessionRouteChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupt:) name:AVAudioSessionInterruptionNotification object:self.sensorAudioSession];
        
        // Check that audio route is correct
        [self checkAudioStatus];
        
        // **** DEBUG ****
        NSLog(@"Sensor monitor STARTED");
    } else {
        // Unregister notification callbacks
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        // Stop IO communication
        [self stopCollecting];
        
        // **** DEBUG ****
        NSLog(@"Sensor monitor STOPPED");
    }
}


- (void) startCollecting {
    // Set up audio associate sensor IO
    [self setUpSensorIO];
    
    // Set Master Volume to 100%
    self.volumeSlider.value = 1.0f;
    if (self.volumeSlider.value != 1.0f) {
        [self addAlertViewToView: VOLUME_FAILURE];
    }
}


- (void) stopCollecting {
    Boolean isRunning = false;
    AUGraphIsRunning (auGraph, &isRunning);
    
    if (isRunning) {
        // Stop and release audio unit
        AUGraphStop(self->auGraph);
        AUGraphUninitialize(self->auGraph);
        self->auGraph = nil;
        self.audioSetup = false;
    }
    
    // Set Master Volume to 50%
    if (self.volumeSlider.value != 0.5f) {
        self.volumeSlider.value = 0.5f;
    }
}


/**
 *  Checks for flags set by audioInterruptionCallback and by manual isSensorConnected function to determine if the audio route has changed in a way that will disrupt the collection process.
 */
- (void) checkAudioStatus {
    if (!self.isSensorConnected) {
        [self stopCollecting];
        [self addAlertViewToView: SENSOR_DISCONNECTED];
    }
}

/**
 *  Detects sensor (headset) connection by pulling the current input and output routes from the active AVAudioSession.
 *
 *  @return The function returns TRUE if audio route is the one used by sensor system and FALSE otherwise
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

- (void) audioInterrupt: (NSNotification *) notification {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger audioInterruptReason = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    switch (audioInterruptReason) {
        case AVAudioSessionInterruptionTypeBegan:
            // Stop IO audio unit
            [self stopCollecting];
            
            // Set State and dismiss alert if any
            [self addAlertViewToView: APP_CHANGE];
            
            NSLog(@"Audio Interruption Started\n");
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            [self startCollecting];
            NSLog(@"Audio Interruption Ended\n");
            break;
            
        default:
            NSLog(@"Unhandled Audio Interruption Event: %ld\n", (long)audioInterruptReason);
    }
}

/**
 *  Audio route change listener callback, for GSFSensorIOController class, that is invoked whenever a change occurs in the audio route.
 *
 *  @param notification A NSNotification containing audio change reason
 */
- (void) audioRouteChangeListener: (NSNotification *)notification {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        // Sensor inserted
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
/*            // Dismiss alert if any and begin collection
            if (self.sensorAlert != nil) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:YES];
                self.sensorAlert = nil;
            }
            
            // Start IO communication
            [self startCollecting];
*/            
            // **** DEBUG ****
            NSLog(@"Sensor INSERTED");
            break;
            
        // Sensor removed
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // Stop IO audio unit
            [self stopCollecting];
            
            // Set State and dismiss alert if any
            [self addAlertViewToView: SENSOR_DISCONNECTED];
            
            // **** DEBUG ****
            NSLog(@"Sensor REMOVED");
            break;
            
        // Category changed from PlayAndRecord
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // **** DEBUG ****
            NSLog(@"Category CHANGED");
            break;
            
        default:
            NSLog(@"Blowing it in- audioRouteChangeListener with route change reason: %ld", (long)routeChangeReason);
            break;
    }
}


/**
 *  Adds the alert view to the data staging area after an audio route change occurs
 *
 *  @param changeReason The NSInteger holding the reason why the audio route changed
 */
- (void) addAlertViewToView: (NSInteger) changeReason {
    // Dismiss any existing alert
    if (self.sensorAlert != nil) {
        [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
        self.sensorAlert = nil;
    }
    
    // Set up image for alert View
    UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
    
    switch (changeReason) {
        case SENSOR_DISCONNECTED:
            // Set up alert View for a disconnected sensor
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"No Sensor"
             message:@"Please insert the GSF sensor and try again."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Try Again", nil];
            
            [alertImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.sensorAlert.contentView addSubview:alertImageView];
            [alertImageView sdc_horizontallyCenterInSuperview];
            [self.sensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[alertImageView]|"
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:NSDictionaryOfVariableBindings(alertImageView)]];
            break;
            
        case APP_CHANGE:
            // Set up alert view audio source changed
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Source Changed"
             message:@"The audio input has changed from the GSF App. To continue collecting sensor data press \"Continue\". Pressing \"Cancel\" will end sensor data collection."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", @"Continue", nil];
            break;
            
        case VOLUME_FAILURE:
            // Set up alert view for volume malfunction
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Auto Power Failed"
             message:@"The sensor needs power. Please adjust the volume, using the volume buttons on the side of your iOS device, to the maximum amount and try collecting again."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Try Again", nil];
            
            [self.volumeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.sensorAlert.contentView addSubview:self.volumeSlider];
            [self.volumeSlider sdc_horizontallyCenterInSuperview];
            [self.sensorAlert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[self.volumeSlider]|"
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:NSDictionaryOfVariableBindings(self.volumeSlider)]];
            break;
            
        case CHANNEL_FAILURE:
            // Set up alert view audio source changed
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Channel"
             message:@"The audio input has interrupted from the GSF App and sensor. Please try collecting the sensor data again."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Try Again", nil];
            
            break;
            
        default:
            NSLog(@"Blowing It In- addAlertViewToView");
    }
    
    // Add alertView to associated view
    [self.associatedView addSubview:self.sensorAlert];
    
    // Show Alert
    [self.sensorAlert show];
}

/**
 *  Custom alert view callback handler that responds to user button selection
 *
 *  @param alertView   A SDCAlertView instance
 *  @param buttonIndex The button index selected by user.
 */
- (void) alertView:(SDCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // Cancel Button pushed
        case 0:
            // Stop IO audio unit
            [self stopCollecting];
            if ([self.delegate respondsToSelector:@selector(popVCSensorIO:)]) {
                [self.delegate popVCSensorIO:self];
            }
            break;
            
        // Continue
        case 1:
            // Start IO communication
            [self startCollecting];
            break;
     
        case 2:
            // Used to dismiss alert view when no button input is neccessary
            NSLog(@"Made it to standard dismiss\n");
            break;
  
        default:
            NSLog(@"Blowing It In- alertView: Button index not handled: %ld", (long)buttonIndex);
            break;
    }
}

- (void) alertView:(SDCAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // Checking for dismiss
            NSLog(@"Made it to standard dismiss\n");
            break;
            
        default:
            NSLog(@"Uncaught dismiss\n");
            break;
    }
}

/**
 *  Process Input readinga and fills right channel output buffer with any response
 *
 *  @param bufferList sensorIO is list of buffers containing the input from the mic line
 */
- (void) processIO: (AudioBufferList*) bufferList {
    
    if (self.waitACycle) {
        self.waitACycle = false;
        self.reqNewData = true;
    } else if (bufferList->mBuffers != nil) {
        @try {
            // Realtime decode
            int j = 0;
            int last_sample = 0;
            
            for (int j = 0 ; j < bufferList->mNumberBuffers ; j++) {
                AudioBuffer sourceBuffer = bufferList->mBuffers[j];
                SInt16 *buffer = (SInt16 *) bufferList->mBuffers[j].mData;
                
                for (int i = 0; i < (sourceBuffer.mDataByteSize / sizeof(sourceBuffer)); i++) {
                    // Array of raw data points for debug
                    [self.rawInputData addObject:[NSNumber numberWithInt:buffer[i]]];
                }
            }
            
            last_sample = (int)[self.rawInputData count];
            
            for (int i = self.first_sample; i < last_sample; i += SAMPLES_PER_CHECK) {
                int avgSampleNext = 0;
                int nextSamples = 0;
                
                // Find average value for the prev and next set of point around the expected edge
                for (j = 0; j < SAMPLES_PER_CHECK && i+j < last_sample && i+j > 0; j++) {
                    nextSamples += abs((int)self.rawInputData[i+j]);
                }
                avgSampleNext = nextSamples / j;
                
                // Associate current bit value based on min/max values and check if it's the start bit
                if ( avgSampleNext >= HIGH_MIN_AVG ) {
                    self.curState = HIGH_STATE;
                    // Only enters this statement for the rising edge of the start signal
                    if (!self.startEdge) {
                        
        #ifdef DEBUG_AVG
                        printf("    !!!!! Start between samples %d to %d\n\n\n",i ,i+j);
        #endif
                        
                        self.startEdge = true;
                        self.firstHalfPeriod = true;
                        self.halfPeriodCount = SAMPLES_PER_CHECK;
                        self.halfPeriodSum = 0;
                        self.doubleState = LOW_STATE;
                    }
                } else {
                    self.curState = LOW_STATE;
                }
                
                self.halfPeriodSum += avgSampleNext;
                
                
        #ifdef DEBUG_AVG
                printf("Avg for samples %d to %d: %d\n",i ,i+j , avgSampleNext);
        #endif
                
                // When start flag is set check for data
                if (self.startEdge) {
                    // Grab edge
                    if (self.curState != self.lastState) {
                        self.lastState = self.curState;
                        self.lastSampleEdge = i;
                    }
                    
                    // Increment and check if half period is finished
                    self.halfPeriodCount += j;
                    if (self.halfPeriodCount >= HALF_PERIOD_TC) {
                        // Assign window state and adjust off set from last edge
                        if ((self.halfPeriodSum / NUM_SAMPLES_PER_PERIOD) > HIGH_MIN_AVG) {
                            self.curWindowState = HIGH_STATE;
                        } else {
                            self.curWindowState = LOW_STATE;
                        }
                        
        #ifdef DEBUG_AVG
                        printf("Half Period Start- curState: %d doubleState: %d curWindowState:%d lastWindowState:%d secondLastWindowState:%d\n", self.curState, self.doubleState, self.curWindowState, self.lastWindowState, self.secondLastWindowState);
        #endif
                        
                        if (self.curWindowState != self.curState){
        #ifdef DEBUG_AVG
                            printf("Last sample starting point: %d\n", i);
        #endif
                            
                            i = self.lastSampleEdge - SAMPLES_PER_CHECK;
                            
        #ifdef DEBUG_AVG
                            printf("Next sample starting point: %d\n", i);
        #endif
                        }
                        
        #ifdef DEBUG_SUM
                        printf("Half period sum: %d\n", self.halfPeriodSum);
                        printf("Number of samples per period: %d\n", NUM_SAMPLES_PER_PERIOD);
                        printf("Half period Average: %d && Cutoff: %d\n", (self.halfPeriodSum / NUM_SAMPLES_PER_PERIOD), HIGH_MIN_AVG);
                        printf("Half period State: %d\n", (self.halfPeriodSum / NUM_SAMPLES_PER_PERIOD) > HIGH_MIN_AVG);
                        printf("Half Period Count: %d\n", self.halfPeriodCount);
        #endif
                        
                        // Reset half period count and sumation
                        self.halfPeriodSum = 0;
                        self.halfPeriodCount = 0;
                        
                        // Check if this is the first pass after the start edge
                        if (self.firstHalfPeriod) {
                            //if (curState == HIGH_STATE) doubleState = HIGH_STATE;
                            self.firstHalfPeriod = false;
                            
        #ifdef DEBUG_AVG
                            printf("    First Half Period- doubleState:%d curWindowState:%d lastWindowState:%d secondLastWindowState:%d\n", self.doubleState, self.curState, self.lastWindowState, self.secondLastWindowState);
        #endif
                            
                        }
                        // Check for bit flip
                        else if (self.curWindowState != self.lastWindowState &&
                                 self.doubleState != self.curWindowState) {
                            
        #ifdef DEBUG_AVG
                            printf("            ***** %d detected between samples %d to %d\n", self.curWindowState, i, i+j);
        #endif
                            
                            [self.inputDataDecoded addObject:[NSNumber numberWithInt:self.curWindowState]];
                            self.bit_num++;
                        }
                        // Check for non bit flip
                        else if (self.curWindowState == self.lastWindowState &&
                                 self.lastWindowState != self.secondLastWindowState) {
                            self.doubleState = self.curWindowState;
                            
        #ifdef DEBUG_AVG
                            printf("    NonFlip- doubleState: %d curWindowState:%d lastWindowState:%d secondLastWindowState:%d\n", self.doubleState, self.curWindowState, self.lastWindowState, self.secondLastWindowState);
        #endif
                            
                        }
                        // Reset input stream last three states are equivalent
                        else if (self.curWindowState == self.lastWindowState &&
                                 self.lastWindowState == self.secondLastWindowState) {
                            self.startEdge = false;
                            
        #ifdef DEBUG_AVG
                            printf("    !!!!! End of transmission detected between samples %d to %d\n", i, i+j);
                            printf("    !!!!! curWindowState:%d lastWindowState:%d secondLastWindowState:%d\n", self.curWindowState, self.lastWindowState, self.secondLastWindowState);
                            printf("\n\n");
        #endif
                            
                            // Convert resulting "bits" to bytes. data is Little Endian
        #ifdef DEBUG_PACKETS
                            printf("\nDecoded Bytes:\n");
        #endif
                            int byte_val = 0;
                            int power = 7;
                            int check_it = 0;
                            
                            for (int byte_itor = self.bit_num-1; byte_itor >= 0; byte_itor--) {
                                NSNumber *cur_bit = self.inputDataDecoded[byte_itor];
                                byte_val += (int)pow(2,power) * cur_bit.intValue;
                                if (check_it)
                                    self.checkSum += cur_bit.intValue;
                                power--;
                                if (power < 0) {
                                    if (byte_itor == self.bit_num - 8) {
        #ifdef DEBUG_PACKETS
                                        printf("Recieved Check Sum: ");
        #endif
                                        check_it = 1;
                                    }
        #ifdef DEBUG_PACKETS
                                    printf("0x%x\n",byte_val);
        #endif
                                    [self.sensorData addObject:[NSNumber numberWithInt:byte_val]];
                                    power = 7;
                                    byte_val = 0;
                                }
                            }
        #ifdef DEBUG_PACKETS
                            printf("Actual Check Sum: 0x%x\n\n", self.checkSum);
                            printf("    Little Endian Binary Input:\n");
                            for(int bit_itor = 0; bit_itor < self.bit_num; bit_itor++) {
                                NSNumber *cur_bit = self.inputDataDecoded[bit_itor];
                                printf("%d", cur_bit.intValue);
                                if (bit_itor%8 == 7) printf(" ");
                            }
                            printf("\n");
        #endif
                            
                            // Clear binary input array
                            [self.inputDataDecoded removeAllObjects];
                            
                            // Verify checksum
                            NSNumber *calc_check_sum = self.sensorData[self.crc_index];
                            if (calc_check_sum.intValue != self.checkSum) {
    #ifdef DEBUG_PACKETS
                                printf("Bad CRC - Discarding Packet\n");
    #endif
                                self.reqNewData = false;
                                self.waitACycle = true;
                                self.bit_num = 0;
                                self.checkSum = 0;
                                
                                for (int k = (int)[self.sensorData count]; k != self.crc_index; k--) {
                                    [self.sensorData removeLastObject];
                                }
                            } else {
                                // Convert chipcap bytes into sensor reading values
                                int chipcapData[4];
                                int rawHumidData[2];
                                int rawTempData[2];
                                float humidData = 0.0;
                                float tempData = 0.0;
                                
                                for (int k = self.crc_index+1, i = 0; k < self.crc_index+5; k++, i++) {
                                    NSNumber *cur_byte = self.sensorData[k];
                                    chipcapData[i] = cur_byte.intValue;
                                }
                                
                                // Get raw data from chipcapData array
                                rawHumidData[0] = chipcapData[0];
                                rawHumidData[1] = chipcapData[1];
                                
                                rawTempData[0] = chipcapData[2];
                                rawTempData[1] = chipcapData[3];
                                
                                // Conversion equations from ChipCap2 data sheet
                                humidData = (((rawHumidData[0] >> 2)*256 + rawHumidData[1])/pow(2,14)) * 100;
                                tempData = ((rawTempData[0]*64 + (rawTempData[1] >> 2))/pow(2,14)) * 165 - 40;
                                
                                // Add the converted data to reading arrays
                                [self.humidityReadings addObject:[NSNumber numberWithFloat:humidData]];
                                [self.temperatureReadings addObject:[NSNumber numberWithFloat:tempData]];
                                
                                self.crc_index += 5;
                                self.bit_num = 0;
                                self.checkSum = 0;
                            }
                        }
                        
                        // Push state down the line
                        self.secondLastWindowState = self.lastWindowState;
                        self.lastWindowState = self.curWindowState;
                        
        #ifdef DEBUG_AVG
                        printf("Half Period count: %d\n",self.halfPeriodCount);
                        printf("Half Period sum: %d\n", self.halfPeriodSum);
                        printf("Half Period End- doubleState: %d curWindowState:%d lastWindowState:%d secondLastWindowState:%d\n\n\n", self.doubleState, self.curWindowState, self.lastWindowState, self.secondLastWindowState);
        #endif
                    }
                    // When two packets have been successfully collected stop collecting
                    if (self.crc_index == 10) {
                        if ([self.delegate respondsToSelector:@selector(endCollection:)]) {
                            [self.delegate endCollection:self];
                        }
                    }
                }
            }
            self.first_sample = last_sample;
        }
        @catch (NSException *exception) {
            NSLog(@"processIO- Failed with exception: %@", exception);
            self.badChannel = true;
            [self performSelectorInBackground:@selector(channelFailure) withObject:nil];
        }

    }
}

- (void) channelFailure {
    [self stopCollecting];
    [self addAlertViewToView:CHANNEL_FAILURE];
}


/**
 *  Averages sample readings from micro and returns an NSMutableArray of the results.
 *
 *  @return An NSMutableArray containing the decoded sensor data.
 */
- (NSMutableArray*) collectSensorData {
    self.reqNewData = false;
    [self monitorSensors: NO];
    
    /***************************************************************************
     **** DEBUG: Prints contents of input buffer to file.                   ****
     ***************************************************************************/
    // Grabs Document directory path and file name
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *docs_dir = [paths objectAtIndex:0];
#ifdef DEBUG_REMOVE
    
    // Remove last File
    NSError *err;
    NSString *lastPath = [NSString stringWithFormat:@"%@/HeadsetSensor_in_25Hz_15kHzOne_SensorReading_CRC_SE_PCB_ObjC_44kSR_i5s.txt",docs_dir];
    [[NSFileManager defaultManager] removeItemAtPath:lastPath error:&err];
    
    if (err != noErr) {
        NSLog(@"ERROR: %@- Failed to delete last file: %@", err, lastPath);
    }
#endif
#ifdef DEBUG_WRITE
    // New file to add
    NSString *path = [NSString stringWithFormat:@"%@/HeadsetSensor_in_25Hz_15kHzOne_SensorReading_ObjC_RT_44kSR_i5s.txt",docs_dir];
    const char *file = [path UTF8String];

    // Open and write to new file
    FILE *fp;
    fp = fopen(file, "w+");
    if (fp == NULL) {
        printf("ERROR processIO: Couldn't open file \"inputData.txt\"\n");
        exit(0);
    }
    int buf_indx = 0;
    for (buf_indx = 0; buf_indx < [self.rawInputData count]; buf_indx++) {
        fprintf(fp, "%d\n", (int)self.rawInputData[buf_indx]);
    }
    fclose(fp);
#endif
    /***************************************************************************
     **** DEBUG: Prints contents of input buffer to file. Doing this in     ****
     ***************************************************************************/
    
    float humAvg = 0.0;
    float tempAvg = 0.0;
    int count = (int)[self.humidityReadings count];
    
    // Get avarage humidity and temperature readings
    for (int k = 0; k < count; k++){
        NSNumber *hum = self.humidityReadings[k];
        humAvg += hum.floatValue;
        
        NSNumber *tem = self.temperatureReadings[k];
        tempAvg += tem.floatValue;
    }
    
    NSMutableArray *readings = [[NSMutableArray alloc] init];
    [readings addObject:[NSNumber numberWithFloat:(humAvg/count)]];
    [readings addObject:[NSNumber numberWithFloat:(tempAvg/count)]];
    [readings addObject:[NSNumber numberWithInt:count]];
    
    // Return average of readings 
    return readings;
}

@end
