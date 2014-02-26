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
            NSData *stringify = [NSJSONSerialization dataWithJSONObject:jsondict options:NSJSONWritingPrettyPrinted error:nil];
            [jsonArray addObject:[[NSString alloc] initWithData:stringify encoding:NSUTF8StringEncoding]];
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
