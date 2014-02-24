//
//  GSFDirectionService.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDirectionService.h"

@interface GSFDirectionService ()

@property BOOL sensor;
@property BOOL alternatives;
@property (nonatomic) NSURL *directionsURL;
@property (nonatomic, weak) NSArray *waypoints;

@end


@implementation GSFDirectionService

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

- (void)setDirectionsQuery:(NSDictionary *)query withSelector:(SEL)selector
              withDelegate:(id)delegate{
    self.waypoints = [query objectForKey:@"waypoints"];  // get object out of dictionary for key waypoints
    NSString *origin = [self.waypoints objectAtIndex:0]; // get first object in the array
    NSUInteger destinationPos = [self.waypoints count] - 1;       // get last element of array index.
    NSString *destination = [self.waypoints objectAtIndex:destinationPos];
    NSString *sensor = [query objectForKey:@"sensor"];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@", kMDDirectionsURL, origin, destination, sensor];
    NSLog(@"%@", url);
    if ([self.waypoints count] > 2) {
        [url appendString:@"&waypoints=optimize:true"];
        NSUInteger wpCount = [self.waypoints count] - 2;
        for(int i = 1; i < wpCount; i++){
            [url appendString: @"|"];
            [url appendString:[self.waypoints objectAtIndex:i]];
            NSLog(@"%@", url);
        }
    }
    url = (NSMutableString*)[url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    self.directionsURL = [NSURL URLWithString:url];
    [self retrieveDirections:selector withDelegate:delegate];
}

- (void)retrieveDirections:(SEL)selector withDelegate:(id)delegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data = [NSData dataWithContentsOfURL:self.directionsURL];
        [self fetchedData:data withSelector:selector withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data withSelector:(SEL)selector withDelegate:(id)delegate{
    
    NSError* error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [delegate performSelector:selector withObject:json]; // fix this warning. cannot be ignored.
}


@end
