//
//  GSFPhotoSelector.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFPhotoSelector.h"
#import "GSFImageCollectionViewCell.h"


@interface GSFPhotoSelector () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *done;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *more;

@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *discardAll;

@end

@implementation GSFPhotoSelector

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Erorr\n");
    // Dispose of any resources that can be recreated.
}

// specifies number of collection view cells to allocate.
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)self.capturedImages.count);
    return self.capturedImages.count;
}

// specifies which item goes in the cell the index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImage *image = [self.capturedImages objectAtIndex:indexPath.item];
    if ([cell isKindOfClass:[GSFImageCollectionViewCell class]]) {
        UIImageView *imgview = ((GSFImageCollectionViewCell *)cell).imageView;
        if ([[self.capturedImages objectAtIndex:indexPath.item] isKindOfClass:[UIImage class]]) {
            imgview.image = image;
        }
    }
    return cell;
    
}


@end
