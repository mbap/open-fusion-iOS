//
//  GSFDirectionService.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSFDirectionServer <NSObject>

@optional
- (void)checkJSONResults:(NSDictionary *)data;
- (void)getTSPResults:(NSDictionary *)data;

@end


@interface GSFDirectionService : NSObject

// custom delegate
@property (nonatomic, weak) id <GSFDirectionServer> delegate;

// init override.
- (GSFDirectionService*)initWithGPSCoords:(NSArray *)gpsCoords andWithWaypointStrings:(NSArray *)waypointStrings;

// create url from gps strings.
- (NSURL *)createURLStringWithOrigin:(NSString *)origin withDestination:(NSString *)destination withStops:(NSArray *)stops;

// add comments for this function
- (void)setDirectionsQuery:(NSDictionary *)object;

// solves the tsp for the waypoints.
- (void)solveTSP;

@end

