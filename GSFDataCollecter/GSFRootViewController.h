//
//  GSFRootViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/21/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Root view controller for the GSFDataCollecter App.
 */
@interface GSFRootViewController : UIViewController

/**
 *  Handles a url scheme request.
 *
 *  @param url The url passed in from the source application.
 */
- (void)handleUrlRequest:(NSString *)url;

@end
