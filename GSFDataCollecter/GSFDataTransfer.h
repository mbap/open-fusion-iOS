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
// into the array which will then be returned.
- (NSMutableArray *)formatDataAsJSON:(NSMutableArray *)dataArray;

// uses NSURLSession object to upload data to a database.
// returns 0 if success nonzero if failure
- (NSInteger)uploadDataArray:(NSMutableArray *)dataArray;

@end
