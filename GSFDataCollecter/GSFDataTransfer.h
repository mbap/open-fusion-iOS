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


// takes an array of dictionarys and converts it
// into its JSON representation. Each JSON string will be inserted
// into the array, which is then inserted into a dictionary,
// which is then turned into json NSData, which will then be returned.
- (NSData *)formatDataAsJSON:(NSMutableArray *)dataArray withFlag:(NSNumber *)option;

// sends the NSData from above to gsf server.
- (void)uploadDataArray:(NSData *)data;


@end
