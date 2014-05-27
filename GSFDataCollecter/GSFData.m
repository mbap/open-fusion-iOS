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
    if (gsfdata == nil) {
        return nil;
    }
    
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    [jsonData setObject:@"Feature" forKey:@"type"];
    
    NSMutableDictionary *geometry = [[NSMutableDictionary alloc] init];
    [geometry setObject:@"Point" forKey:@"type"];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    if (gsfdata.coords) {
        [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.longitude]];
        [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.latitude]];
        [geometry setObject:temp forKey:@"coordinates"];
    }
    [jsonData setObject:geometry forKey:@"geometry"];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    if (gsfdata.date) {
        [properties setObject:gsfdata.date forKey:@"time"];
    }
    if (gsfdata.coords) {
        [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.altitude] forKey:@"altitude"];
        [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.horizontalAccuracy] forKey:@"h_accuracy"];
        [properties setObject:[NSNumber numberWithDouble:gsfdata.coords.verticalAccuracy] forKey:@"v_accuracy"];
    }
    
    if (gsfdata.gsfImage.oimage) {
        NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.oimage);
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

+ (GSFData *)convertFeatureDictToGSFData:(NSDictionary *)dict;
{
    if (dict == nil) {
        return nil;
    }
    
    // create the data object that will be returned.
    GSFData *data = [[GSFData alloc] init];
    
    // get the lat and long which will be used later.
    NSNumber *longitude = nil;
    NSNumber *latitude = nil;
    NSNumber *altitude = nil;
    NSNumber *horizontal = nil;
    NSNumber *vertical = nil;
    if ([dict objectForKey:@"geometry"]) {
        if ([[dict objectForKey:@"geometry"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *geometry = [dict objectForKey:@"geometry"];
            if ([geometry objectForKey:@"coordinates"]) {
                if ([[geometry objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]) {
                    NSArray *coords = [geometry objectForKey:@"coordinates"];
                    if (coords) {
                        longitude = [coords objectAtIndex:0];
                        latitude = [coords objectAtIndex:1];
                    }
                }
            }
        }
    }
    
    // get properties dict from main dict
    NSDictionary *properties = nil;
    if ([dict objectForKey:@"properties"]) {
        if ([[dict objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            properties = [dict objectForKey:@"properties"];
        }
    }
    
    // parse through the properties dict
    if (properties) {
        
        // get timestamp
        if([properties objectForKey:@"time"]) {
            if ([[properties objectForKey:@"time"] isKindOfClass:[NSString class]]) {
                data.date = [properties objectForKey:@"time"];
            }
        }
        
        // get altitude.
        if ([properties objectForKey:@"altitude"]) {
            if ([[properties objectForKey:@"altitude"] isKindOfClass:[NSNumber class]]) {
                altitude = [properties objectForKey:@"altitude"];
            }
        }
        
        // get horizontal accuracy
        if ([properties objectForKey:@"h_accuracy"]) {
            if ([[properties objectForKey:@"h_accuracy"] isKindOfClass:[NSNumber class]]) {
                horizontal = [properties objectForKey:@"h_accuracy"];
            }
        }
        
        // get vertical accuracy
        if ([properties objectForKey:@"v_accuracy"]) {
            if ([[properties objectForKey:@"v_accuracy"] isKindOfClass:[NSNumber class]]) {
                horizontal = [properties objectForKey:@"v_accuracy"];
            }
        }
        
        // add coords field to gsfdata
        data.coords = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue) altitude:altitude.doubleValue horizontalAccuracy:horizontal.doubleValue verticalAccuracy:vertical.doubleValue timestamp:nil];
        
        // get the image from the base64 encoded string.
        if ([properties objectForKey:@"image"]) {
            if([[properties objectForKey:@"image"] isKindOfClass:[NSString class]]) {
                NSData *imageData =  [[NSData alloc] initWithBase64EncodedString:[properties objectForKey:@"image"] options:0];
                if (imageData) {
                    data.gsfImage = [[GSFImage alloc] initWithImage:[UIImage imageWithData:imageData]];
                }
            }
        }
        
        // add ambient noise
        if ([properties objectForKey:@"noise_level"]) {
            if([[properties objectForKey:@"noise_level"] isKindOfClass:[NSNumber class]]) {
                data.noiseLevel = [properties objectForKey:@"noise_level"];
            }
        }
        
        // temp data.
        if ([properties objectForKey:@"temperature"]) {
            if([[properties objectForKey:@"temperature"] isKindOfClass:[NSNumber class]]) {
                data.temp = [properties objectForKey:@"temperature"];
            }
        }
        
        // humidty data
        if ([properties objectForKey:@"humidity"]) {
            if([[properties objectForKey:@"humidity"] isKindOfClass:[NSNumber class]]) {
                data.humidity = [properties objectForKey:@"humidity"];
            }
        }
        
        // faces detected
        if ([properties objectForKey:@"faces_detected"]) {
            if([[properties objectForKey:@"faces_detected"] isKindOfClass:[NSNumber class]]) {
                data.gsfImage.faceDetectionNumber = [properties objectForKey:@"faces_detected"];
            }
        }
        
        // persons detected
        if ([properties objectForKey:@"people_detected"]) {
            if([[properties objectForKey:@"people_detected"] isKindOfClass:[NSNumber class]]) {
                data.gsfImage.personDetectionNumber = [properties objectForKey:@"people_detected"];
            }
        }
    }
    
    return data;
}

@end

