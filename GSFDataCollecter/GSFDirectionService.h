//
//  GSFDirectionService.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSFDirectionService : NSObject

// add comments for this function
- (void)setDirectionsQuery:(NSDictionary *)object withSelector:(SEL)selector
              withDelegate:(id)delegate;

// add comments for this function
- (void)retrieveDirections:(SEL)sel withDelegate:(id)delegate;

// add comments for this function
- (void)fetchedData:(NSData *)data withSelector:(SEL)selector
       withDelegate:(id)delegate;

@end

