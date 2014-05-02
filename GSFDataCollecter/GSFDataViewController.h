//
//  GSFDataViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/23/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFTaggedVCViewController.h"


/**
 *  Main menu View Controller for the GSFDataCollector Application.
 */
@interface GSFDataViewController : GSFTaggedVCViewController

/**
 *  Handles a url scheme request.
 *
 *  @param url The url passed in from the source application.
 */
- (void)handleUrlRequest:(NSString *)url;

@end

