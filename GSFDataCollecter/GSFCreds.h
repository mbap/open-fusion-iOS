//
//  GSFCreds.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 4/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSFCreds : NSObject

/**
 *  Returns your Crashlytics API Key
 *
 *  @return Crashlytics API Key
 */
+ (NSString *)crashlyticsApiKey;


/**
 *  Returns the Google Maps Api Key from your Google Maps console.
 *
 *  @return Your Google Maps iOS API Key
 */
+ (NSString *)GoogleMapsApiKey;

@end
