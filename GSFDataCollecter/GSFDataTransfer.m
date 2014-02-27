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
    //NSLog(@"%@", dataArray);
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"https://gsf.soe.ucsc.edu/api/upload"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"TEST IOS", @"name",
                             @"IOS TYPE", @"typemap",
                             nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    
    [postDataTask resume];
    return 0;
}
    
    
@end
