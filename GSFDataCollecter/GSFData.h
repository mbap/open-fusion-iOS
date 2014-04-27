//
//  GSFData.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GSFImage.h"

/**
 *  The model for the GSFDataCollector application.
 */
@interface GSFData : NSObject

/**
 * Double used to store the noise level at a given GPS location given in dB.
 */
@property (nonatomic) double noiseLevel;

/**
 *  A GSFImage object used to store picture data.
 */
@property (nonatomic) GSFImage *gsfImage;

/**
 *  A GPS object used to GEO-Tag a GSFData object.
 */
@property (nonatomic) CLLocation *coords;

/**
 *  String used to store the timestamp in a particular format.
 */
@property (nonatomic) NSString *date;

// add properties for noise level, temperature, humidity and other data here.

/**
 *  Creates a GSFData obejct and sets the gsfimage property using the image passed in.
 *
 *  @param image The image used to initialize the gsfImage property.
 *
 *  @return The newly created GSFData object.
 */
- (GSFData*)initWithImage:(UIImage*)image;

/**
 *  Converts a timestamp to UTC time.
 *
 *  @param coords The GPS object containing the timestamp. Often times this is the coords property.
 */
- (void)convertToUTC:(CLLocation *)coords;

/**
 *  Converts a timestamp to ISO8601 timestamp to be GSOJSON conformant.
 *
 *  @param coords The GPS object containing the timestamp. Often times this is the coords property.
 */
- (void)convertToISO8601:(CLLocation *)coords;

/**
 *  Converts a GSFData Object into a dictionary that is Apple JSON conformant.
 *
 *  @param gsfdata The GSFData object to be converted into a dictionary.
 *  @param option  The option used to package the GSFData into dictionaries. Passing 1 will package only the OpenCV images. Passing 2 will package only the Original images. Passing 3 will package both option 1 and 2.
 *
 *  @return A Apple JSON conformant dictionary containing a GSFData object.
 */
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata;

@end
