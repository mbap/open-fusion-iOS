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


@interface GSFData : NSObject

@property (nonatomic) GSFImage *gsfImage; 
@property (nonatomic) CLLocation *coords;               // this contains all of the below
@property (nonatomic) NSString *date;


// allocate a GSFData Object before calling this
// sets the image property of an GSFData Object
- (GSFData*)initWithImage:(UIImage*)image;

// fills all properties with data
- (void)convertToUTC:(CLLocation *)coords;

// converts a GSFData Object into a dictionary that can be turned into json.
+ (NSDictionary *)convertGSFDataToDict:(GSFData *)gsfdata;

@end
