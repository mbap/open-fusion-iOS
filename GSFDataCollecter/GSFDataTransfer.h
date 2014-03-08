//
//  GSFDataTransfer.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/24/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSFData.h"

@interface GSFDataTransfer : NSObject


// takes each gsfdata object and converts it into its json format specified by
// the JSON Format for Upload API found on the google docs documentation section.
- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray withFlag:(NSNumber *)option;

// sends the NSData from above to gsf server.
- (void)uploadDataArray:(NSData *)data;


@end
