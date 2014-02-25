//
//  GSFDataTransfer.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/24/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDataTransfer.h"
#import "GSFData.h"

@implementation GSFDataTransfer

- (NSMutableArray *)formatDataAsJSON:(NSMutableArray *)dataArray
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    for (GSFData *data in dataArray) {
        NSDictionary *jsondict = [GSFData convertGSFDataToDict:data];
        if ([NSJSONSerialization isValidJSONObject:jsondict]) {
            [jsonArray addObject:[NSJSONSerialization dataWithJSONObject:jsondict options:NSJSONWritingPrettyPrinted error:nil]];
            // still needs to be converted from nsdata to nsstring...
            // then should be in json format.
        }
    }
    return jsonArray;
}

- (NSInteger)uploadDataArray:(NSMutableArray *)dataArray
{
    NSLog(@"%@", dataArray);
    return 0;
}
    
    
@end
