//
//  GSFDataTransfer.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/24/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSFData.h"

@protocol GSFDataTransferDelegate <NSObject>

@optional

- (void)checkHttpStatus:(NSInteger)statusCode;

@end

@interface GSFDataTransfer : NSObject


// use this when you want to transfer data from the file system
// so it can delete the file when transfered
- (GSFDataTransfer *)initWithURL:(NSString *)url;

// use this when you want to transfer data from the file system
// this is different from initWithURL:(NSString*)url
// because this should only be used in an upload all case.
// this will set the url array to a list of urls
// if transfer is complete all files in the urls array will be deleted.
- (GSFDataTransfer *)initWithURLs:(NSArray *)urls;

// takes each gsfdata object and converts it into its json format specified by
// the JSON Format for Upload API found on the google docs documentation section.
- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray withFlag:(NSNumber *)option;

// this is a data concatenation function: runs at O(n^2)
// takes a list of feature collections and turns them into one feature collection to send.
- (NSData *)createFeatureCollectionFromFreatureCollections:(NSArray *)collectionlist;

// sends the NSData from above to gsf server.
- (void)uploadDataArray:(NSData *)data;

// deletes the file at a given url
// mainly in here so other classes done have to copy the code all over the place.
- (void)deleteFile:(NSString*)url;


// delegate property
@property (nonatomic, weak) id <GSFDataTransferDelegate> delegate;

@end
