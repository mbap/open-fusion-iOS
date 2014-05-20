//
//  GSFData.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFData.h"

@implementation GSFData

- (GSFData*)initWithImage:(UIImage*)image {
    self = [super init];
    if (self) {
        self.gsfImage = [[GSFImage alloc] initWithImage:image];
    }
    return self;
}

- (void)convertToISO8601:(CLLocation *)coords
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    self.date = [dateFormatter stringFromDate:self.coords.timestamp];
}

- (void)convertToUTC:(CLLocation *)coords;
{
    // convert date to a string.
    self.date = [NSString stringWithFormat:@"%f", [self.coords.timestamp timeIntervalSince1970]];
}

// dictionary can only contain  NSString, NSNumber, NSArray, NSDictionary, or NSNull.
// all keys must be NSStrings.
// converts to proper geojson feature object for our data visualist use.
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata
{
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    [jsonData setObject:@"Feature" forKey:@"type"];
    
    NSMutableDictionary *geometry = [[NSMutableDictionary alloc] init];
    [geometry setObject:@"Point" forKey:@"type"];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.longitude]];
    [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.latitude]];
    [geometry setObject:temp forKey:@"coordinates"];
    [jsonData setObject:geometry forKey:@"geometry"];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:gsfdata.date forKey:@"time"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.altitude] forKey:@"altitude"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.horizontalAccuracy] forKey:@"h_accuracy"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.verticalAccuracy] forKey:@"v_accuracy"];

    
    if (gsfdata.gsfImage.highResImage) {
        NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.highResImage);
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        [properties setObject:imageString forKey:@"image"]; // set image in dict
    }
    
    // add temp data.
    if (gsfdata.temp) {
        [properties setObject:gsfdata.temp forKey:@"temperature"];
    }
    
    // add humidity data
    if (gsfdata.humidity) {
        [properties setObject:gsfdata.humidity forKey:@"humidity"];
    }
    
    if (gsfdata.gsfImage.faceDetectionNumber) {
        [properties setObject:gsfdata.gsfImage.faceDetectionNumber forKey:@"faces_detected"];
    }
    if (gsfdata.gsfImage.personDetectionNumber) {
        [properties setObject:gsfdata.gsfImage.personDetectionNumber forKey:@"people_detected"];
    }
    
    // noise level
    if (gsfdata.noiseLevel) {
        [properties setObject:gsfdata.noiseLevel forKey:@"noise_level"];
    }
    
    [jsonData setObject:properties forKey:@"properties"];
    return jsonData;
}

@end

