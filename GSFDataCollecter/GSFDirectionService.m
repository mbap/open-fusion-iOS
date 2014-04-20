//
//  GSFDirectionService.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "GSFDirectionService.h"
#include <math.h>

#define MAXSIZE 8

@interface GSFDirectionService ()

@property (nonatomic) NSURL *directionsURL;
@property (nonatomic, weak) NSArray *waypoints; // filled with strings
@property (nonatomic, weak) NSArray *gpsCoords; // filled with map markers.

@property (nonatomic) NSMutableArray *waysGPS; // array for the tsp solver.
@property (nonatomic) NSMutableArray *wayStrings; // array for the tsp solver.

// theses are properties to hold the data from the get Chunk function.
@property (nonatomic) NSMutableArray *legsTmp;
@property (nonatomic) NSMutableArray *distances;
@property (nonatomic) NSMutableArray *durations;

// theses are properties to hold the data during the tsp algorithms.
@property (nonatomic) NSMutableArray *legs;
@property (nonatomic) NSMutableArray *dist;
@property (nonatomic) NSMutableArray *dur;

@property (nonatomic) NSNumber *chunkNum;
@property (nonatomic) NSNumber *okChunkNum;

// tsp functions
- (void)getWayArr:(int)curr;
- (void)getChunk;
- (void)readyTsp;
- (void)getDistanceTableAtCurr:(int)curr andInd:(int)currInd andDistInd:(int)distInd;
- (void)doTsp;
- (void)prepareSolutionWithBestPath:(NSMutableArray*)bestPath;

//- (void)tspAntColonyK2WithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSMutableArray*)bestTrip;

//-(void)tspK3WithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSMutableArray*)bestTrip;

- (void)tspGreedyWithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSNumber*)bestTrip;


// old methods before tsp
- (void)setDirectionsQuery:(NSDictionary *)query;
- (void)retrieveDirections;
- (void)fetchedData:(NSData *)data;

- (NSURL *)createURLStringWithOrigin:(NSString *)origin withDestination:(NSString *)destination withStops:(NSArray *)stops;

@end


@implementation GSFDirectionService

static NSString *kMDDirectionsURL = @"https://maps.googleapis.com/maps/api/directions/json?";

- (GSFDirectionService*)initWithGPSCoords:(NSArray *)gpsCoords andWithWaypointStrings:(NSArray *)waypointStrings
{
    self = [super init];
    if (self) {
        self.waypoints = waypointStrings;
        self.gpsCoords = gpsCoords;
    }
    return self;
}

// tsp attempt below.
- (void)solveTSP
{
    // add caching check here if this gets used a lot. otherwise we will hit our rate limit most likely.
    self.chunkNum = [NSNumber numberWithInt:0];
    self.okChunkNum = [NSNumber numberWithInt:0];
    self.legsTmp = [[NSMutableArray alloc] init];
    self.durations = [[NSMutableArray alloc] init];
    self.distances = [[NSMutableArray alloc] init];
    self.waysGPS = [[NSMutableArray alloc] init];
    self.wayStrings = [[NSMutableArray alloc] init];
    [self.waysGPS addObject:[self.gpsCoords objectAtIndex:0]];
    [self.wayStrings addObject:[self.waypoints objectAtIndex:0]];
    [self getWayArr:0];
    [self getChunk];
}

- (void)getWayArr:(int)curr {
    int nextAbove = -1;
    for (int i = curr + 1; i < self.waypoints.count; ++i) {
        if (nextAbove == -1) {
            nextAbove = i;
        } else {
            [self.waysGPS addObject:[self.gpsCoords objectAtIndex:i]];
            [self.wayStrings addObject:[self.waypoints objectAtIndex:i]];
            [self.waysGPS addObject:[self.gpsCoords objectAtIndex:curr]];
            [self.wayStrings addObject:[self.waypoints objectAtIndex:curr]];
        }
    }
    if (nextAbove != -1) {
        [self.waysGPS addObject:[self.gpsCoords objectAtIndex:nextAbove]];
        [self.wayStrings addObject:[self.waypoints objectAtIndex:nextAbove]];
        [self getWayArr:nextAbove];
        [self.waysGPS addObject:[self.gpsCoords objectAtIndex:curr]];
        [self.wayStrings addObject:[self.waypoints objectAtIndex:curr]];    }
}

// get data from google for tsp algorithm.
- (void)getChunk
{
    // get data from google here.
    self.chunkNum = self.okChunkNum;
    
    if (self.chunkNum.intValue < self.wayStrings.count) {
        NSMutableArray *wayChunk = [[NSMutableArray alloc] init];
        for (int i = 0; i < MAXSIZE && i + self.chunkNum.intValue < self.wayStrings.count; ++i) {
            [wayChunk addObject:[self.wayStrings objectAtIndex:(self.chunkNum.intValue + i)]];
        }
        NSString *origin = [[NSString alloc] initWithString:[wayChunk objectAtIndex:0]];
        NSString *finaldest = [[NSString alloc] initWithString:[wayChunk lastObject]];
        NSMutableArray *wayChunk2 = [[NSMutableArray alloc] init];
        for (int i = 1; i < (wayChunk.count - 1); ++i) {
            wayChunk2[i-1] = wayChunk[i];
        }
        self.chunkNum = [NSNumber numberWithInt:(self.chunkNum.intValue + MAXSIZE)];
        if (self.chunkNum.intValue < (self.waypoints.count - 1)) {
            self.chunkNum = [NSNumber numberWithInt:(self.chunkNum.intValue - 1)];
        }
        
        // use the above information to get json data from google.
        NSURL *query = [self createURLStringWithOrigin:origin withDestination:finaldest withStops: wayChunk2];
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:query];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        // process the data recieved from google.
        if (json) {
            if ([[json objectForKey:@"routes"][0] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *routes = [json objectForKey:@"routes"][0];
                if ([[routes objectForKey:@"legs"] isKindOfClass:[NSArray class]]) {
                    NSArray *legs = [routes objectForKey:@"legs"];
                    for (int i = 0; i < legs.count; ++i) {
                        NSDictionary *leg = [legs objectAtIndex:i];
                        [self.legsTmp addObject:leg];
                        NSDictionary *dur = [leg objectForKey:@"duration"];
                        NSNumber *duration = [NSNumber numberWithInt:[[dur objectForKey:@"value"] intValue]];
                        [self.durations addObject:duration];
                        NSDictionary *dist = [leg objectForKey:@"distance"];
                        NSNumber *distance = [NSNumber numberWithInt:[[dist objectForKey:@"value"] intValue]];
                        [self.distances addObject:distance];
                    }
                }
            }
            self.okChunkNum = self.chunkNum;
            [self getChunk];
        } else {
            NSLog(@"Error: Request Failed. Google Service was either denied or returned with no data.\n");
            NSLog(@"Error:%@", error);
        }
    } else {
        // ready data structure for tsp.
        [self readyTsp];
    }
}

- (void)readyTsp
{
    self.legs = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    self.dist = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    self.dur  = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    for (int i = 0; i < self.waypoints.count; ++i) {
        [self.legs addObject:[[NSMutableArray alloc] initWithCapacity:self.waypoints.count]];
        [self.dist addObject:[[NSMutableArray alloc] initWithCapacity:self.waypoints.count]];
        [self.dur addObject:[[NSMutableArray alloc] initWithCapacity:self.waypoints.count]];
    }
    for (int x = 0; x < self.waypoints.count; ++x) {
        NSMutableArray *leg = [self.legs objectAtIndex:x];
        NSMutableArray *dis = [self.dist objectAtIndex:x];
        NSMutableArray *dur = [self.dur objectAtIndex:x];
        for (int i = 0; i < self.waypoints.count; ++i) {
            [leg addObject:[NSNull null]];
            [dis addObject:@0];
            [dur addObject:@0];
        }
    }
    [self getDistanceTableAtCurr:0 andInd:0 andDistInd:0];
    [self doTsp];
}

- (void)getDistanceTableAtCurr:(int)curr andInd:(int)currInd andDistInd:(int)distInd
{
    int nextAbove = -1;
    int distIndex = distInd;
    int index = currInd;
    for (int i = curr + 1; i < self.waypoints.count; ++i) {
        index++;
        if (nextAbove == -1) {
            nextAbove = i;
        } else {
            self.legs[currInd][index] = self.legsTmp[distIndex];
            self.dist[currInd][index] = self.distances[distIndex];
            self.dur[currInd][index] = self.durations[distIndex++];
            self.legs[index][currInd] = self.legsTmp[distIndex];
            self.dist[index][currInd] = self.distances[distIndex];
            self.dur[index][currInd] = self.durations[distIndex++];
        }
    }
    if (nextAbove != -1) {
        self.legs[currInd][currInd+1] = self.legsTmp[distIndex];
        self.dist[currInd][currInd+1] = self.distances[distIndex];
        self.dur[currInd][currInd+1] = self.durations[distIndex++];
        [self getDistanceTableAtCurr:nextAbove andInd:currInd+1 andDistInd:distIndex];
        self.legs[currInd+1][currInd] = self.legsTmp[distIndex];
        self.dist[currInd+1][currInd] = self.distances[distIndex];
        self.dur[currInd+1][currInd] = self.durations[distIndex++];
    }
}

- (void)doTsp
{
    NSMutableArray *visited = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    NSMutableArray *currPath = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    NSMutableArray *bestPath = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    NSNumber *bestTrip = [[NSNumber alloc] initWithInt:INT_MAX];
    
    for(int i = 0; i < self.waypoints.count; ++i) {
        visited[i] = @NO;
    }
    visited[0] = @YES;
    currPath[0] = [NSNumber numberWithInt:0];
    
    //[self tspAntColonyK2WithVisited:visited currPath:currPath bestPath:bestPath bestTrip:bestTrip];
    //[self tspK3WithVisited:visited currPath:currPath bestPath:bestPath bestTrip:bestTrip];
    
    [self tspGreedyWithVisited:visited currPath:currPath bestPath:bestPath bestTrip:bestTrip];
    [self prepareSolutionWithBestPath:bestPath];
}

/*
- (void)tspAntColonyK2WithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSMutableArray*)bestTrip
{
    double alfa = 0.1; // The importance of the previous trails
    double beta = 2.0; // The importance of the durations
    double rho = 0.1;  // The decay rate of the pheromone trails
    double asymptoteFactor = 0.9; // The sharpness of the reward as the solutions approach the best solution
    NSMutableArray *pher = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    NSMutableArray *nextPher = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    NSMutableArray *prob = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    int numAnts = 20;
    int numWaves = 20;
    for (int i = 0; i < self.waypoints.count; ++i) {
        pher[i] = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
        nextPher[i] = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    }
    for (int i = 0; i < self.waypoints.count; ++i) {
        for (int j = 0; j < self.waypoints.count; ++j) {
            pher[i][j] = [NSNumber numberWithInt:1];
            nextPher[i][j] = [NSNumber numberWithFloat:0.0];
        }
    }
    
    int lastNode = 0;
    int startNode = 0;
    int numSteps = self.waypoints.count - 1;
    int numValidDests = self.waypoints.count;
    for (int wave = 0; wave < numWaves; ++wave) {
        for (int ant = 0; ant < numAnts; ++ant) {
            int curr = startNode;
            int currDist = 0;
            for (int i = 0; i < self.waypoints.count; ++i) {
                visited[i] = [NSNumber numberWithInt:NO];
            }
            currPath[0] = [NSNumber numberWithInt:curr];
            for (int step = 0; step < numSteps; ++step) {
                visited[curr] = [NSNumber numberWithInt:YES];
                double cumProb = 0.0;
                for (int next = 1; next < numValidDests; ++next) {
                    NSNumber *nextVisited = visited[next];
                    if (!nextVisited.intValue) {
                        NSNumber *tmp = pher[curr][next];
                        NSNumber *durtmp = self.dur[curr][next];
                        double solution = pow(tmp.doubleValue, alfa) * pow(durtmp.doubleValue, (0.0 - beta));
                        prob[next] = [NSNumber numberWithDouble:solution];
                        cumProb += solution;
                    }
                }
                double random = (arc4random() % 74) / 74;
                double guess = random * cumProb;
                int nextI = -1;
                for (int next = 1; next < numValidDests; ++next) {
                    NSNumber *temp = visited[next];
                    if (!temp.intValue) {
                        nextI = next;
                        NSNumber *temp = prob[next];
                        guess -= temp.doubleValue;
                        if (guess < 0) {
                            nextI = next;
                            break;
                        }
                    }
                }
                NSNumber *durtmp = self.dur[curr][nextI];
                currDist += durtmp.intValue;
                currPath[step+1] = [NSNumber numberWithInt:nextI];
                curr = nextI;
            }
            currPath[numSteps+1] = [NSNumber numberWithInt:lastNode];
            NSNumber *durtmp = self.dur[curr][lastNode];
            currDist += durtmp.intValue;
            
            // k2-rewire:
            int lastStep = self.waypoints.count;
            NSNumber *changed = [NSNumber numberWithInt:YES];;
            int i = 0;
            while (changed.intValue) {
                changed = [NSNumber numberWithInt:NO];
                for (; i < lastStep - 2 && !changed.intValue; ++i) {
                    NSNumber *durtmp =
                    var cost = dur[currPath[i+1]][currPath[i+2]];
                    var revCost = dur[currPath[i+2]][currPath[i+1]];
                    var iCost = dur[currPath[i]][currPath[i+1]];
                    var tmp, nowCost, newCost;
                    for (var j = i+2; j < lastStep && !changed; ++j) {
                        nowCost = cost + iCost + dur[currPath[j]][currPath[j+1]];
                        newCost = revCost + dur[currPath[i]][currPath[j]]
                        + dur[currPath[i+1]][currPath[j+1]];
                        if (nowCost > newCost) {
                            currDist += newCost - nowCost;
                            // Reverse the detached road segment.
                            for (var k = 0; k < Math.floor((j-i)/2); ++k) {
                                tmp = currPath[i+1+k];
                                currPath[i+1+k] = currPath[j-k];
                                currPath[j-k] = tmp;
                            }
                            changed = true;
                            --i;
                        }
                        cost += dur[currPath[j]][currPath[j+1]];
                        revCost += dur[currPath[j+1]][currPath[j]];
                    }
                }
            }
            
            if (currDist < bestTrip) {
                bestPath = currPath;
                bestTrip = currDist;
            }
            for (var i = 0; i <= numSteps; ++i) {
                nextPher[currPath[i]][currPath[i+1]] += (bestTrip - asymptoteFactor * bestTrip) / (numAnts * (currDist - asymptoteFactor * bestTrip));
            }
        }
        for (var i = 0; i < numActive; ++i) {
            for (var j = 0; j < numActive; ++j) {
                pher[i][j] = pher[i][j] * (1.0 - rho) + rho * nextPher[i][j];
                nextPher[i][j] = 0.0;
            }
        }
    }
}

-(void)tspK3WithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSMutableArray*)bestTrip
{
    
}
*/

- (void)tspGreedyWithVisited:(NSMutableArray*)visited currPath:(NSMutableArray*)currPath bestPath:(NSMutableArray*)bestPath bestTrip:(NSNumber*)bestTrip {
    int curr = 0;
    int currDist = 0;
    int numSteps = self.waypoints.count - 1;
    int lastNode = 0;
    int numToVisit = self.waypoints.count;
    for (int step = 0; step < numSteps; ++step) {
        visited[curr] = @YES;
        bestPath[step] = [NSNumber numberWithInt:curr];
        int nearest = INT_MAX;
        int nearI = -1;
        for (int next = 1; next < numToVisit; ++next) {
            NSNumber *v = visited[next];
            NSNumber *d = self.dur[curr][next];
            if (!v.boolValue && d.intValue < nearest) {
                nearest = d.intValue;
                nearI = next;
            }
        }
        NSNumber *d = self.dur[curr][nearI];
        currDist += d.intValue;
        curr = nearI;
    }
    bestPath[numSteps] = [NSNumber numberWithInt:curr];
    NSNumber *d = self.dur[curr][lastNode];
    currDist += d.intValue;
    bestTrip = [NSNumber numberWithInt:currDist];
}


- (void)prepareSolutionWithBestPath:(NSMutableArray*)bestPath
{
    NSMutableArray *wpInd = [[NSMutableArray alloc] initWithCapacity:self.waypoints.count];
    for (int i = 0; i < self.waypoints.count; ++i) {
            wpInd[i] = [NSNumber numberWithInt:i];
    }
    NSMutableString *bestPathLatLngStr = [[NSMutableString alloc] init];
    [bestPathLatLngStr stringByAppendingString:@""];
    NSMutableArray *directionsResultLegs = [[NSMutableArray alloc] init];
    NSMutableArray *directionsResultOverview = [[NSMutableArray alloc] init];
    GMSCoordinateBounds *directionsResultBounds = [[GMSCoordinateBounds alloc] init];
    for (int i = 1; i < bestPath.count; ++i) {
        NSNumber *x = bestPath[i-1];
        NSNumber *y = bestPath[i];
        [directionsResultLegs addObject:self.legs[x.intValue][y.intValue]];
    }
    for (int i = 0; i < bestPath.count; ++i) {
        NSNumber *y = bestPath[i];
        NSNumber *z = wpInd[y.intValue];
        [bestPathLatLngStr stringByAppendingString:self.waypoints[z.intValue]];
        [bestPathLatLngStr stringByAppendingString:@"\n"];
        GMSMarker *extender = self.gpsCoords[z.intValue];
        [directionsResultBounds includingCoordinate:extender.position];
        [directionsResultOverview addObject:self.gpsCoords[z.intValue]];
    }
    
    NSDictionary *directionsResultRoutes = @{ @"legs": directionsResultLegs,
                                              @"bounds": directionsResultBounds,
                                              @"overview_path": directionsResultOverview,
                                              @"bestPath" : bestPath
                                            };
    [self.delegate getTSPResults:directionsResultRoutes];
}

- (void)setDirectionsQuery:(NSDictionary *)query {
    self.waypoints = [query objectForKey:@"waypoints"];  // get object out of dictionary for key waypoints
    NSString *origin = [self.waypoints objectAtIndex:0]; // get first object in the array
    NSUInteger destinationPos = [self.waypoints count] - 1;       // get last element of array index.
    NSString *destination = [self.waypoints objectAtIndex:destinationPos];
    NSString *sensor = [query objectForKey:@"sensor"];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@", kMDDirectionsURL, origin, destination, sensor];
    if ([self.waypoints count] > 2) {
        [url appendString:@"&waypoints=optimize:true"];
        NSUInteger wpCount = [self.waypoints count] - 2;
        for(int i = 1; i < wpCount; i++){
            [url appendString: @"|"];
            [url appendString:[self.waypoints objectAtIndex:i]];
        }
    }
    url = (NSMutableString*)[url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    self.directionsURL = [NSURL URLWithString:url];
    [self retrieveDirections];
}

- (void)retrieveDirections {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data = [NSData dataWithContentsOfURL:self.directionsURL];
        [self fetchedData:data];
    });
}

- (void)fetchedData:(NSData *)data {
    NSError* error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [self.delegate checkJSONResults:json];
}

- (NSURL *)createURLStringWithOrigin:(NSString *)origin withDestination:(NSString *)destination withStops:(NSArray *)stops
{
    NSString *sensor = @"false";
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@", kMDDirectionsURL, origin, destination, sensor];
    if ([stops count] > 0) {
        [url appendString:@"&waypoints=optimize:true"];
        NSUInteger wpCount = [stops count];
        for(int i = 0; i < wpCount; i++){
            [url appendString: @"|"];
            [url appendString:[stops objectAtIndex:i]];
        }
    }
    url = (NSMutableString*)[url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    return [NSURL URLWithString:url];
}

@end
