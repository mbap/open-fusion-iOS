//
//  GSFViewController.h
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSMutableArray *capturedImages;

@end
