//
//  GSFAudioController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFAudioController.h"

@implementation GSFAudioController
static OSStatus	AudioUnitRenderCallback (void *inRefCon,
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp,
                                         UInt32 inBusNumber,
                                         UInt32 inNumberFrames,
                                         AudioBufferList *ioData) {
    
    OSStatus err = AudioUnitRender(audioUnitWrapper->audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    if(err != 0) NSLog(@"AudioUnitRender status is %d", err);
    // These values should be in a more conventional location for a bunch of preprocessor defines in your real code
#define DBOFFSET -74.0
    // DBOFFSET is An offset that will be used to normalize the decibels to a maximum of zero.
    // This is an estimate, you can do your own or construct an experiment to find the right value
#define LOWPASSFILTERTIMESLICE .001
    // LOWPASSFILTERTIMESLICE is part of the low pass filter and should be a small positive value
    
    SInt16* samples = (SInt16*)(ioData->mBuffers[0].mData); // Step 1: get an array of your samples that you can loop through. Each sample contains the amplitude.
    
    Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
    Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude; // We'll need these in the low-pass filter
    Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
    
    for (int i=0; i < inNumberFrames; i++) {
        
        Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
        
        // Step 3: for each sample's absolute value, run it through a simple low-pass filter
        // Begin low-pass filter
        currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
        previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
        Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
        // End low-pass filter
        
        Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
        // Step 4: for each sample's filtered absolute value, convert it into decibels
        // Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
        
        if((sampleDB == sampleDB) && (sampleDB != -DBL_MAX)) { // if it's a rational number and isn't infinite
            
            if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
            decibels = peakValue; // final value
        }
    }
    
    NSLog(@"decibel level is %f", decibels);
    
    for (UInt32 i=0; i < ioData->mNumberBuffers; i++) { // This is only if you need to silence the output of the audio unit
        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize); // Delete if you need audio output as well as input
    }
    
    return err;
}
}
@end
