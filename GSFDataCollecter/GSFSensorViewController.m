//
//  ViewController.m
//  Headset Sensors
//
//  Created by Mick on 1/24/14.
//  Copyright (c) 2014 Mick. All rights reserved.
//

#import "GSFSensorViewController.h"

GSFSensorViewController *audioIO;

void checkStatus(int status){
	if (status) {
		printf("Status not 0! %d\n", status);
//        exit(1);
	}
}

static OSStatus renderToneCallback(void *inRefCon,
                                   AudioUnitRenderActionFlags 	*ioActionFlags,
                                   const AudioTimeStamp 		*inTimeStamp,
                                   UInt32 						inBusNumber,
                                   UInt32 						inNumberFrames,
                                   AudioBufferList              *ioData) {
    
	// Get the tone parameters out of the view controller
	GSFSensorViewController *viewController =
    (__bridge GSFSensorViewController *)inRefCon;
	double theta = viewController.theta;
	double theta_increment = 2.0 * M_PI * viewController.frequency / viewController.sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
		buffer[frame] = sin(theta) * viewController.amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI) {
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController.theta = theta;
    
	return noErr;
}

@implementation GSFSensorViewController

@synthesize runningTotal = _runningTotal;
@synthesize lastBit = _lastBit;
@synthesize cutOff = _cutOff;
@synthesize headsetSwitch = _headsetSwitch;
@synthesize sensorAlert = _sensorAlert;

@synthesize powerTone = _powerTone;
@synthesize frequency = _frequency;
@synthesize amplitude = _amplitude;
@synthesize sampleRate = _sampleRate;
@synthesize theta = _theta;
@synthesize volumeSlider = _volumeSlider;

/**
 *  Initializes pluggable sensor IO components when the application view loads.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Set up AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL success;
    NSError *error;
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	if (!success) NSLog(@"ERROR viewDidLoad: AVAudioSession failed overrideOutputAudio- %@", error);
    
    success = [session setActive:YES error:&error];
    if(!success) NSLog(@"ERROR viewDidLoad: AVAudioSession failed activating- %@", error);
    
    // Add audio route change listner
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListener:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // MIC input variables initialize
    _runningTotal = 0;
    _lastBit = 0;
    _cutOff = -31.0f;
    
    // Power tone variables initialize
    _sampleRate = 44100;
    _frequency = 20000;
    _amplitude = 0.5f;
    
    // Setup master volume controller
    MPVolumeView *volumeView = [MPVolumeView new];
    volumeView.showsRouteButton = NO;
    volumeView.showsVolumeSlider = NO;
    [self.view addSubview:volumeView];
    
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
}

/**
 *  Audio route change listener callback that is invoked whenever a change occurs in the audio route
 *
 *  @param notification A notification containing audio change reason
 */
- (void)audioRouteChangeListener: (NSNotification*)notification {
    // Initiallize dictionary with notification and grab route change reason
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    // Setup image for Alert View
    UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
    
    switch (routeChangeReason) {
        // Sensor inserted
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // Dismiss any existing alert and set headsetswitch to on
            if (self.sensorAlert) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:YES];
            }
            self.headsetSwitch.on = YES;
            
            // Call flippHeadset to start transmission functionallity
            [self flippedHeadset:self];
            break;
            
        // Sensor removed
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // Dismiss any existing alert
            if (self.sensorAlert) {
                [self.sensorAlert dismissWithClickedButtonIndex:0 animated:NO];
            }
            
            // Stop Timer
            [self.secondTimer invalidate];
            self.secondTimer = nil;
            
            // Kill power Tone
            [self toggleIO:NO];
            
            // Setup Alert View
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"No Sensor"
             message:@"Please insert the GSF sensor to collect this data."
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", nil]; // removed , @"Use Mic"
            
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
            
            // Stop Timer
            [self.secondTimer invalidate];
            self.secondTimer = nil;
            
            // Kill power Tone
            [self toggleIO:NO];
            
            // Setup Alert View
            self.sensorAlert =
            [[SDCAlertView alloc]
             initWithTitle:@"Audio Source Change"
             message:@"A new "
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"Cancel", nil]; // removed , @"Use Mic"
            
            // Show Alert
            [self.sensorAlert show];
            break;
            
        default:
            NSLog(@"Blowing it in- audioRouteChangeListener with route change reason: %ld", (long)routeChangeReason);
            break;
    }
}

/**
 *  Sets up audio components for pluggable sensor IO.
 */
- (void)setupIOUnits {
	// Configure the search parameters to find the default playback output unit
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &_powerTone);
	NSAssert1(_powerTone, @"Error creating unit: %hd", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = renderToneCallback;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(_powerTone,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %hd", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = _sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (_powerTone,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

/**
 *  Handles the toggleing of the IO audio instances.
 *
 *  @param powerOn Boolean value that identifies the change to the output state.
 */
- (void)toggleIO:(BOOL)powerOn {
	if (!powerOn) {
        // Set Master Volume to 50%
        self.volumeSlider.value = 0.5f;
        
		// Stop and release power tone
        AudioOutputUnitStop(self.powerTone);
		AudioUnitUninitialize(self.powerTone);
		AudioComponentInstanceDispose(self.powerTone);
		self.powerTone = nil;
	} else {
		[self setupIOUnits];
		
		// Initialize audio unit
		OSErr err = AudioUnitInitialize(self.powerTone);
		NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
		
        // Set Master Volume to 100%
        self.volumeSlider.value = 1.0f;
        
		// Start playback
		err = AudioOutputUnitStart(self.powerTone);
		NSAssert1(err == noErr, @"Error starting unit: %hd", err);
	}
}

/**
 *  Auto adjuct iOS devices master volume when the sensor is attached.
 *
 *  @param sender NSNotification containing the master volume slider.
 */
- (void)handleVolumeChanged:(id)sender{
    if (self.powerTone) self.volumeSlider.value = 1.0f;
}

// debug helper method for checking throughput
- (void)secondTimerCallBack:(NSTimer *)timer {
    self.runningTotal = 0;
    //NSLog(@"                    *** One Second");
}

/**
 *  Custom alert view callback handler that responds to user button selection
 *
 *  @param alertView   A SDCAlertView instance
 *  @param buttonIndex The button index selected by user.
 */
- (void)alertView:(SDCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // Set switch to off and change input label text
            self.headsetSwitch.on = NO ;
            break;
        case 1:
            // Start level timer
            self.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(secondTimerCallBack:) userInfo:nil repeats:YES];
            break;
        default:
            NSLog(@"Blowing It In- alertView: Button index not handled: %ld", (long)buttonIndex);
            break;
    }
}

// OLD way of detecting sensor connection
- (BOOL) isHeadsetPluggedIn {
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
 *  Collect sensor data switch handler
 *
 *  @param sender The UIView controller containing the button
 */
- (IBAction)flippedHeadset:(id)sender {
    if (self.headsetSwitch.on && self.isHeadsetPluggedIn) {
        // Start sampler
        self.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(secondTimerCallBack:) userInfo:nil repeats:YES];
        
        // Start Power Tone
        [self toggleIO:YES];
    } else if (!self.headsetSwitch.on){
        // Stop sampler
        [self.secondTimer invalidate];
        self.secondTimer = nil;
        
        // Stop Power Tone
        [self toggleIO:NO];
    } else {
        // Stop sampler
        [self.secondTimer invalidate];
        self.secondTimer = nil;
        
        // Stop Power Tone
        [self toggleIO:NO];
        
        // Setup image for Alert View
        UIImageView *alertImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GSF_Insert_sensor_alert-v2.png"]];
        
        // Setup Alert View
        self.sensorAlert =
        [[SDCAlertView alloc]
         initWithTitle:@"No Sensor"
         message:@"Please insert the GSF sensor to collect this data."
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
        
        [self.sensorAlert show];
    }
}

/**
 *  Process input from mic line using recordingCallback function
 *
 *  @param bufferList list of audio buffers holding mic data
 */
- (void) processInput: (AudioBufferList*) bufferList {
    int currentBit = 0;
    double ampIn = 0.0f;
    
    if (ampIn < self.cutOff) { // set inital cutoff to high value.
        currentBit = 1;
    }
    
    if (currentBit != self.lastBit) {
        self.runningTotal++;
        self.lastBit = currentBit;
        NSLog(@"                    Bit Flipped");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
