//
//  GSFDirectionService.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol for the Google Maps route planner.
 */
@protocol GSFDirectionServer <NSObject>

@optional
/**
 *  Passes the results from one google maps query through. To be used with setDirectionsQuery:
 *
 *  @param data The data that google returns.
 */
- (void)checkJSONResults:(NSDictionary *)data;

/**
 *  Method that passes the solved traveling salesman route through to the calling class.
 *
 *  @param data The optimized route.
 */
- (void)getTSPResults:(NSDictionary *)data;

@end


@interface GSFDirectionService : NSObject

/**
 *  The delegate property.
 */
@property (nonatomic, weak) id <GSFDirectionServer> delegate;

/**
 *  Init override. Creates this class with additional properties set.
 *
 *  @param gpsCoords       The google map markers to be used in computation.
 *  @param waypointStrings The google maps markers as strings to be used.
 *
 *  @return A GSFDirectionService object with data from parameters.
 */
- (GSFDirectionService*)initWithGPSCoords:(NSArray *)gpsCoords andWithWaypointStrings:(NSArray *)waypointStrings;

/**
 *  Creates a url string that will query google maps direction service.
 *
 *  @param origin      The starting location.
 *  @param destination The final location.
 *  @param stops       Stops that will be between the start and final location.
 *
 *  @return A url that can be used to query data from google maps direction service.
 */
- (NSURL *)createURLStringWithOrigin:(NSString *)origin withDestination:(NSString *)destination withStops:(NSArray *)stops;


/**
 *  Depricated method that querys the google maps direction service for the points on the map. Unoptimized. Use delegate methods now and solve tsp.
 *
 *  @param object The google maps markers to solve for.
 */
- (void)setDirectionsQuery:(NSDictionary *)object;

/**
 *  Solved the tsp problem for the waypoints that are passed in the init function for this class.
 *
 *  @param aToZ If yes then this will solve the tsp using the last marker as the destination. If no then it will route round trip to the users current location.
 */
- (void)solveTSP:(BOOL)aToZ;

@end

