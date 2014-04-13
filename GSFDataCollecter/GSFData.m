//
//  GSFData.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFData.h"

#define OPENCV 1
#define ORIG   2
#define BOTH   3

@implementation GSFData

- (GSFData*)initWithImage:(UIImage*)image {
    self.gsfImage = [[GSFImage alloc] initWithImage:image];
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
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata withFlag:(NSNumber *)option
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
    [properties setObject:gsfdata.date forKey:@"timestamp"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.altitude] forKey:@"altitude"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.horizontalAccuracy] forKey:@"h_accuracy"];
    [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.verticalAccuracy] forKey:@"v_accuracy"];
    
    /******
     ADD USER INPUT TEXT HERE IF WE GET TO THAT
     ******/
    
    if ((option.intValue == ORIG || option.intValue == BOTH) && gsfdata.gsfImage.oimage) {
        NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.oimage);
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        [properties setObject:imageString forKey:@"oimage"]; // set image in dict
    }
    if ((option.intValue == OPENCV || option.intValue == BOTH)) {
        if (gsfdata.gsfImage.fimage) {
            NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.fimage);
            NSString *imageString = [imageData base64EncodedStringWithOptions:0];
            [properties setObject:imageString forKey:@"fimage"]; // set image in dict
        }
        if (gsfdata.gsfImage.pimage) {
            NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.pimage);
            NSString *imageString = [imageData base64EncodedStringWithOptions:0];
            [properties setObject:imageString forKey:@"pimage"]; // set image in dict
        }
    }
    
    /*****
      ADD JSON OBJECTS FOR TEMP, NOISE, and HUMIDY HERE when they are added to the .h file as properties
    ******/
    
    if (gsfdata.gsfImage.faceDetectionNumber) {
        [properties setObject:gsfdata.gsfImage.faceDetectionNumber forKey:@"faces_detected"];
    }
    if (gsfdata.gsfImage.personDetectionNumber) {
        [properties setObject:gsfdata.gsfImage.personDetectionNumber forKey:@"people_detected"];
    }
    
    if (gsfdata.noiseLevel) {
        [properties setObject:[NSNumber numberWithDouble:gsfdata.noiseLevel] forKey:@"noise_level"];
    }
    
    [jsonData setObject:properties forKey:@"properties"];
    return jsonData;
}

@end

