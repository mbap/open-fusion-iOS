//
//  MTBAppDelegate.m
//  rateMyFestival
//
//  Created by Michael Baptist on 8/19/13.
//  Copyright (c) 2013 Michael Baptist. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Crashlytics/Crashlytics.h>
#import "GSFAppDelegate.h"
#import "GSFCreds.h"
@implementation GSFAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // add api keys for services (google maps and crashlytics)
    [GMSServices provideAPIKey:[GSFCreds GoogleMapsApiKey]];
    [Crashlytics startWithAPIKey:[GSFCreds crashlyticsApiKey]];
    
    // create directory in documents for storing GEOJSON feature collection objects as NSData.
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"GSFSaveData"];
    if (![man fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        BOOL success = [man createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
        if (success) {
            NSLog(@"Dir Created at %@", [url path]);
        } else {
            NSLog(@"Dir Creation Error: %@", error);
        }
    }
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
