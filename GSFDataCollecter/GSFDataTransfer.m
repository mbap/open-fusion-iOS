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

@property (nonatomic) NSString *url;

@property (nonatomic) NSInteger httpResponse;

@end

@implementation GSFDataTransfer

- (GSFDataTransfer *)initWithURL:(NSString *)url
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
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *reqeustData, NSURLResponse *response, NSError *error) {
        NSLog(@"response = %@\nerror = %@\ndata = %@", response, error, reqeustData);
        if (error) {
            [self saveData:data];
        } else {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response; // according to the apple documentation this is a safe cast.
            if ([resp statusCode] == 200) { // OK: request has succeeded
                NSLog(@"Response: 200 Success.\n");
                if (self.url) {
                    [self deleteFile:self.url];
                }
                [self.delegate checkHttpStatus:[resp statusCode]];
            } else if ([resp statusCode] == 201){ // Created: Request Fulfilled resource created.
                NSLog(@"Response: 201 Resouce Created.\n");
                if (self.url) {
                    [self deleteFile:self.url];
                }
                [self.delegate checkHttpStatus:[resp statusCode]];
            } else if ([resp statusCode] == 400) { // bad request, syntax incorrect
                NSLog(@"Response: 400 Bad Request.\n");
            } else if ([resp statusCode] == 403 || [resp statusCode] == 500) { // forbidden: server understood request but denyed anyway
                if ([resp statusCode] == 500) {                                // server error: something bad happened on the server
                    NSLog(@"Response: 500 Server Error.\n");
                } else {
                    NSLog(@"Response: 403 Forbidden.\n");
                }
                [self saveData:data];
            } else {
                NSLog(@"Response: %ld Not Yet Supported.\n", (long)[resp statusCode]);
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

- (void)saveData:(NSData *)data
{
    if (nil == self.url) { // already saved if url was passed in.
        NSLog(@"There was a network error. Saving the data to disk.\n.");
        NSFileManager *man = [[NSFileManager alloc] init];
        NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *url = [urls objectAtIndex:0];
        url = [url URLByAppendingPathComponent:@"GSFSaveData"];
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
        NSLog(@"%@", url);
        NSError *error = nil;
        if (![man fileExistsAtPath:[url path]]) {
            [data writeToURL:url options:NSDataWritingAtomic error:&error];
            if (error) {
                NSLog(@"Problem writing to filesystem.\nError:%@.\n", error);
            } else {
                NSLog(@"Write to filesystem succeeded.\n");
            }
        } else {
            NSLog(@"File Already Exists With Path: %@", url.path); // should never occur
        }
    }
}

- (void)deleteFile:(NSString*)url
{
    NSFileManager *man = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *mainUrl = [urls objectAtIndex:0];
    mainUrl = [mainUrl URLByAppendingPathComponent:@"GSFSaveData"];
    mainUrl = [mainUrl URLByAppendingPathComponent:self.url];
    [man removeItemAtURL:mainUrl error:&error];
    if (error) {
        NSLog(@"Problem removing file at url:%@.\n", mainUrl);
    } else {
        NSLog(@"File at URL: %@ removed.\n", mainUrl);
    }
}

@end

