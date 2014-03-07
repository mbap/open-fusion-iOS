//
//  GSFData.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/3/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFData.h"

#define OPENCV 0
#define ORIG   1
#define BOTH   2

@implementation GSFData

- (GSFData*)initWithImage:(UIImage*)image {
    self.gsfImage = [[GSFImage alloc] initWithImage:image];
    return self;
}

- (void)convertToUTC:(CLLocation *)coords;
{
    // convert date to a string.
    self.date = [NSString stringWithFormat:@"%f", [self.coords.timestamp timeIntervalSince1970]];
}

// dictionary can only contain  NSString, NSNumber, NSArray, NSDictionary, or NSNull.
// all keys must be NSStrings.
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata withFlag:(NSNumber *)option
{
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    if ((option.intValue == ORIG || option.intValue == BOTH) && gsfdata.gsfImage.oimage) {
        NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.oimage);
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        [jsonData setObject:imageString forKey:@"oimage"]; // set image in dict
    }
    if ((option.intValue == OPENCV || option.intValue == BOTH)) {
        if (gsfdata.gsfImage.fimage) {
            NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.fimage);
            NSString *imageString = [imageData base64EncodedStringWithOptions:0];
            [jsonData setObject:imageString forKey:@"fimage"]; // set image in dict
        }
        if (gsfdata.gsfImage.pimage) {
            NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.pimage);
            NSString *imageString = [imageData base64EncodedStringWithOptions:0];
            [jsonData setObject:imageString forKey:@"pimage"]; // set image in dict
        }
    }
    if (gsfdata.gsfImage.faceDetectionNumber) {
        [jsonData setObject:gsfdata.gsfImage.faceDetectionNumber forKey:@"faces_detected"];
    }
    if (gsfdata.gsfImage.faceDetectionNumber) {
        [jsonData setObject:gsfdata.gsfImage.personDetectionNumber forKey:@"people_detected"];
    }
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    [location setObject:@"Point" forKey:@"type"];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.longitude]];
    [temp addObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.latitude]];
    [location setObject:[NSArray arrayWithArray:temp] forKey:@"coordinates"];
    [jsonData setObject:location forKey:@"location"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.altitude] forKey:@"altitude"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.horizontalAccuracy] forKey:@"h_accuracy"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.verticalAccuracy] forKey:@"v_accuracy"];
    [jsonData setObject:gsfdata.date forKey:@"timestamp"];
    return jsonData;
}

@end

