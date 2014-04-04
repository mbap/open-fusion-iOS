//
//  GSFImageCollectionViewCell.h
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/26/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Subclass of UICollectionViewCell used for the GSFViewController collection view.
 */
@interface GSFImageCollectionViewCell : UICollectionViewCell

/**
 *  Imageview for the collection view cells.
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
