//
//  GSFTrackerHelper.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface GSFTrackerHelper : NSObject

@property (nonatomic) NSMutableDictionary *gpsPlacesToCollect; // keys are gps strings, values are bools
@property (nonatomic) NSMutableDictionary *collectedData;      // keys are gps strings, values are gsfdata objects.

- (void)moveGpsToCollected:(CLLocationCoordinate2D)coord;

@end
