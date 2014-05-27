//
//  GSFGeoTagger.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GSFGeoTaggerDelegate <NSObject>

@optional

/**
 *  Delegate method to send a message when the location manager stops updating, thus having completed gathering coordinates.
 *
 *  @param coords The coordinates corresponding to the best effort of the location manager.
 */
- (void)gpsLocationHasBeenCollected:(CLLocation *)coords;

@end

/**
 *  Geotagging class build on top of CLLocationManager.
 */
@interface GSFGeoTagger : NSObject

/**
 *  Contains the most accurate gps coordinate that could be gathered for the session.
 */
@property (nonatomic) CLLocation *bestEffort;

/**
 *  The delegate property.
 */
@property (nonatomic, weak) id <GSFGeoTaggerDelegate> delegate;

/**
 *  Allocates a GSFGeoTagger object with a given accuracy.
 *
 *  @param accuracy The accuracy to use with the cllocationmanager object.
 *
 *  @return A new GSFGeoTagger object with a given accuracy.
 */
- (id)initWithAccuracy:(CLLocationAccuracy)accuracy;

/**
 *  Starts updating the cllocation manager. Simply a wrapper around the CLLocation manager update.
 */
- (void)startUpdatingGeoTagger;

/**
 *  Stops updating the cllocation manager. Simply a wrapper around the CLLocation manager update.
 */
- (void)stopUpdatingGeoTagger;

@end
