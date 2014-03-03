//
//  GSFDataTransfer.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/24/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFDataTransfer.h"
#import "GSFData.h"

@interface GSFDataTransfer() <NSURLSessionDelegate, NSURLSessionTaskDelegate>
@end

@implementation GSFDataTransfer

- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init]; // mutable array to hold all json objects.
    for (GSFData *data in dataArray) {
        NSDictionary *jsondict = [GSFData convertGSFDataToDict:data]; //convert gsfdata into dictionary for json parsing
        [jsonArray addObject:jsondict];
    }
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:jsonArray] forKeys:[NSArray arrayWithObject:@"mapdata"]]; // may want to change key to api key
    // here we return ar array of dictionarys containing json objects.
    // each entry is a utf8stringencoding json object.
    NSData *jsondata;
    if ([NSJSONSerialization isValidJSONObject:mapData]) {
        jsondata = [NSJSONSerialization dataWithJSONObject:mapData options:NSJSONWritingPrettyPrinted error:nil];
    }
    return jsondata;
}

- (NSInteger)uploadDataArray:(NSData *)data
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://gsf.soe.ucsc.edu/api/upload/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    __block NSError *err = [[NSError alloc] init];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response = %@\nerror = %@\ndata = %@", response, error, data);
        err = error;
    }];
    
    [postDataTask resume];
    if (err) return 1;
    return 0;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"gsf.soe.ucsc.edu"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}


/*- (NSMutableArray *)formatDataAsJSON:(NSMutableArray *)dataArray
 {
 NSMutableArray *jsonArray = [[NSMutableArray alloc] init]; // mutable array to hold all json objects.
 for (GSFData *data in dataArray) {
 NSDictionary *jsondict = [GSFData convertGSFDataToDict:data]; //convert gsfdata into dictionary for json parsing
 if ([NSJSONSerialization isValidJSONObject:jsondict]) {
 NSData *stringify = [NSJSONSerialization dataWithJSONObject:jsondict options:NSJSONWritingPrettyPrinted error:nil];
 //[jsonArray addObject:[[NSString alloc] initWithData:stringify encoding:NSUTF8StringEncoding]];
 [jsonArray addObject:stringify];
 }
 }
 // here we return ar array of dictionarys containing json objects.
 // each entry is a utf8stringencoding json object.
 return jsonArray;
 }*/

/*- (NSInteger)uploadDataArray:(NSMutableArray *)dataArray
 {
 NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
 configuration.allowsCellularAccess = YES;
 
 NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
 NSURL *url = [NSURL URLWithString:@"https://gsf.soe.ucsc.edu/api/upload/"];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
 cachePolicy:NSURLRequestUseProtocolCachePolicy
 timeoutInterval:30.0];
 
 [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [request setHTTPMethod:@"POST"];
 
 NSDictionary *mapData = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:dataArray] forKeys:[NSArray arrayWithObject:@"mapdata"]]; // may want to change key to api key
 
 //[request setHTTPBody:[NSData data]]
 if ([NSJSONSerialization isValidJSONObject:mapData]) {
 [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:mapData options:NSJSONWritingPrettyPrinted error:nil]];
 }
 
 NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 NSLog(@"response = %@\nerror = %@\ndata = %@", response, error, data);
 }];
 
 [postDataTask resume];
 return 0;
 }*/

@end

