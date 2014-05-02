//
//  GSFDataTransfer.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/24/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSFData.h"

/**
 *  Protocol for returning the HTTP status code to objects that conform.
 */
@protocol GSFDataTransferDelegate <NSObject, NSURLSessionTaskDelegate>

@optional

/**
 *  If implmented this will be the easiest way to check the status code of an HTTP request from a class that uses a GSFDataTransfer object.
 *
 *  @param statusCode The status code the the HTTP request returns.
 */
- (void)checkHttpStatus:(NSInteger)statusCode;

/**
 *  Periodically informs the delegate of the progress of sending body content to the server.
 *
 *  @param percent A float between 0.0 and 1.0 that specifies the upload progress.
 */
- (void)uploadPercentage:(float)percent;

/**
 *  Sends the download task data through to the implmenting class.
 *
 *  @param data A GEOJSON Geometry collection object.
 */
- (void)getRouteFromServer:(NSDictionary *)data;

@end

/**
 *  Class to be used for data transfer throughout the GSFDataCollector app.
 */
@interface GSFDataTransfer : NSObject

/**
 *  Creates a new GSFDataTransfer object with the url provided. Use this when you want to transfer one collection to the server. Or download one route collection from the server.
 *
 *  @param url Url of the file to be transfered.
 *
 *  @return The new GSFDataTransfer object ready for use.
 */
- (GSFDataTransfer *)initWithURL:(NSString *)url;

/**
 *  Creates a new GSFDataTransfer object with the urls provided. Use this when you want to transfer more than one collection to the server.
 *
 *  @param urls Urls of the files to be transfered.
 *
 *  @return The new GSFDataTransfer object ready for use.
 */
- (GSFDataTransfer *)initWithURLs:(NSArray *)urls;

/**
 *  Takes each GSFData object and converts it into a JSON object in GEOJSON fomat.
 *
 *  @param dataArray An array of GSFData objects in Apple JSON conformant dictionaries.
 *  @param option    The option used to package the array of dictionaries into JSON. Passing 1 will package only the OpenCV images. Passing 2 will package only the Original images. Passing 3 will package both option 1 and 2.
 *
 *  @return The GEOJSON data as an NSData object.
 */
- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray;

/**
 *  A data concatenation function that runs at O(n^2) speed. Takes a list of feature collections and turns them into one feature collection.
 *
 *  @param collectionlist The list of feature collections to be concatenated.
 *
 *  @return One feature collection containing all features from the collectionlist.
 */
- (NSData *)createFeatureCollectionFromFreatureCollections:(NSArray *)collectionlist;

/**
 *  Uploads the GEOJSON objects containing the collected data to the GSF Team Server.
 *
 *  @param data The data to be sent. Must be in GEOJSON format for the returned HTTP status to be successful.
 */
- (void)uploadDataArray:(NSData *)data;

/**
 *  Deletes the file at a given file path or url.
 *
 *  @param url The url to the file to be deleted from the file system.
 */
- (void)deleteFile:(NSString*)url;

/**
 *  If an upload is in progres, this will cancel the upload.
 */
- (void)cancelUpload;

/**
 *  Gets a collection route that a GSF admin creates.
 */
- (void)getCollectionRoute:(NSString *)component;

/**
 *  The delegate object.
 */
@property (nonatomic, weak) id <GSFDataTransferDelegate> delegate;

@end
