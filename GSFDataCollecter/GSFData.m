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
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata
{
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    NSData *imageData = UIImagePNGRepresentation(gsfdata.gsfImage.image);
    NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [jsonData setObject:imageString forKey:@"gsfimage"]; // set image in dict
    [jsonData setObject:gsfdata.gsfImage.faceDetectionNumber forKey:@"facesDetected"];
    [jsonData setObject:gsfdata.gsfImage.personDetectionNumber forKey:@"peopleDetected"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.latitude] forKey:@"latitude"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.coordinate.longitude] forKey:@"longitude"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.altitude] forKey:@"altitude"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.horizontalAccuracy] forKey:@"horizontalAccuracy"];
    [jsonData setObject:[NSNumber numberWithDouble:gsfdata.coords.verticalAccuracy] forKey:@"verticalAccuracy"];
    [jsonData setObject:gsfdata.date forKey:@"timestamp"];
    return jsonData;
}

@end
