//
//  GSFPhotoSelector.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFPhotoSelector.h"
#import "GSFImageCollectionViewCell.h"
#import "GSFImageSelectorPreview.h"



@interface GSFPhotoSelector () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *more;

@property (nonatomic) UIImageView *imagePreview;
@property (nonatomic) GSFImageCollectionViewCell *imagecell;
@property (nonatomic) NSIndexPath *index;

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
    return self.capturedImages.count;
}

// specifies which item goes in the cell the index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if ([self.capturedImages objectAtIndex:indexPath.item] != nil) {
        UIImage *image = [self.capturedImages objectAtIndex:indexPath.item];
        if ([cell isKindOfClass:[GSFImageCollectionViewCell class]]) {
            UIImageView *imgview = ((GSFImageCollectionViewCell *)cell).imageView;
            if ([[self.capturedImages objectAtIndex:indexPath.item] isKindOfClass:[UIImage class]]) {
               imgview.image = image;
            }
        }
    }
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"selectorImagePreviewSegue"]) {
        GSFImageSelectorPreview *preview = (GSFImageSelectorPreview *)segue.destinationViewController;
        preview.image = [[UIImage alloc] init];
        preview.image = self.imagecell.imageView.image;
        preview.index = [[NSIndexPath alloc] init];
        preview.index = self.index;
        preview.delagate = self;
    }
}

- (IBAction)viewPhotoPreview:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.collectionView];
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (index) {
        self.imagecell = (GSFImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
        self.index = index;
        [self performSegueWithIdentifier:@"selectorImagePreviewSegue" sender:self];
    }
    
}

- (IBAction)takeMorePictures:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addItemViewController:(id)controller didFinishEnteringItem:(NSIndexPath *)indexPath{
    if (indexPath.item < self.capturedImages.count) {
        [self.capturedImages removeObjectAtIndex:indexPath.item];
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}

@end
