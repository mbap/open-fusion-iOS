//
//  GSFCreds.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class to hide you credentials. The user of this code must make their own GSFCreds.m file with their own google maps api key.
 */
@interface GSFCreds : NSObject

/**
 *  Returns the Google Maps Api Key from your Google Maps console.
 *
 *  @return Your Google Maps iOS API Key
 */
+ (NSString *)GoogleMapsApiKey;

@end
