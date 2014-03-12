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

@property (nonatomic) NSURL *url;

@end

@implementation GSFDataTransfer

- (GSFDataTransfer *)initWithURL:(NSURL*)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray withFlag:(NSNumber *)option
{
    NSMutableDictionary *featureCollection = [[NSMutableDictionary alloc] init];
    [featureCollection setObject:@"FeatureCollection" forKey:@"type"];
    NSMutableArray *features = [[NSMutableArray alloc] init]; // mutable array to hold all json objects.
    for (GSFData *data in dataArray) {
        NSDictionary *feature = [GSFData convertGSFDataToDict:data withFlag:option]; //convert gsfdata into dictionary for json parsing
        [features addObject:feature];
    }
    [featureCollection setObject:features forKey:@"features"];
    NSData *JSONPacket;
    if ([NSJSONSerialization isValidJSONObject:featureCollection]) {
        JSONPacket = [NSJSONSerialization dataWithJSONObject:featureCollection options:NSJSONWritingPrettyPrinted error:nil];
    }
    return JSONPacket;
}

- (void)uploadDataArray:(NSData *)data
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
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response = %@\nerror = %@\ndata = %@", response, error, data);
        if (error) {
            NSLog(@"There was a network error saving the file.\n.");
            NSFileManager *man = [[NSFileManager alloc] init];
            NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
            NSURL *url = [urls objectAtIndex:0];
            url = [url URLByAppendingPathComponent:@"GSFSaveData"];
            NSLog(@"%@", [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]]);
            NSError *error = nil;
            [data writeToURL:[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]] options:NSDataWritingAtomic error:&error];
            if (error) {
                NSLog(@"Problem writing to filesystem.\n");
            } else {
                NSLog(@"Write to filesystem succeeded.\n");
            }
        } else {
#warning this is priviative. wee need to check status codes if we really want to delete data.
            if (self.url) {
                NSFileManager *man = [[NSFileManager alloc] init];
                NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
                NSURL *url = [urls objectAtIndex:0];
                url = [url URLByAppendingPathComponent:@"GSFSaveData"];
                NSLog(@"%@", [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]]);
                NSError *error = nil;
                [man removeItemAtURL:self.url error:&error];
                if (error) {
                    NSLog(@"Problem removing file at url:%@.\n", self.url);
                } else {
                    NSLog(@"File at URL: %@ removed.\n", self.url);
                }
            }
        }
    }];
    [postDataTask resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"gsf.soe.ucsc.edu"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}



@end

