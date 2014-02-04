//
//  GSFViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFViewController.h"
//#import "GSFOpenCvImageProcessor.h"
#import "GSFImageCollectionViewCell.h"


@interface GSFViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GSFImageSelectorDelegate>


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSMutableArray *cvCapturedImages;
@property (nonatomic) BOOL showDetectionImages;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIImageView *imagePreview;
@property (nonatomic) GSFImageCollectionViewCell *imagecell;
@property (nonatomic) NSIndexPath *index;

@end

@implementation GSFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //allocate the images array.
    self.capturedImages = [[NSMutableArray alloc] init];
    
    // check for a camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        [toolbarItems removeObjectAtIndex:1];
        [self.toolbar setItems:toolbarItems animated:NO];
    }
    
}

// button action for showing the camera
- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


// button action for done. here the images get processed by detecting number of
// people in the image.
- (IBAction)doneWithPhotoPicker:(id)sender
{
    if (self.capturedImages.count) {
        self.showDetectionImages = YES;
        //GSFOpenCvImageProcessor *processor = [[GSFOpenCvImageProcessor alloc] init];
        //self.cvCapturedImages = [processor detectPeopleUsingImageArray:self.capturedImages];
    }
}

// loads the image picker for the camera.
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    if (self.imagePreview.isAnimating)
    {
        [self.imagePreview stopAnimating];
    }
    /*
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    */
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface.
         */
        imagePickerController.showsCameraControls = YES;
        
        /* Set up our custom overlay view for the camera.
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        
        /*
        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
        */
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    /*if ([self.capturedImages count] > 0)
    {
        if (!self.showDetectionImages)
        {
            if ([self.capturedImages count] == 1)
            {
                // Camera took a single picture.
                [self.imagePreview setImage:[self.capturedImages objectAtIndex:0]];
            }
            else
            {
                // Camera took multiple pictures; use the list of images for animation.
                self.imagePreview.animationImages = self.capturedImages;
                self.imagePreview.animationDuration = 3.0;    // Show each captured photo for 3 seconds.
                self.imagePreview.animationRepeatCount = 0;   // Animate forever (show all photos).
                [self.imagePreview startAnimating];
            }
        } else {
            if ([self.cvCapturedImages count] == 1)
            {
                // Camera took a single picture.
                [self.imagePreview setImage:[self.cvCapturedImages objectAtIndex:0]];
            }
            else
            {
                // Camera took multiple pictures; use the list of images for animation.
                self.imagePreview.animationImages = self.cvCapturedImages;
                self.imagePreview.animationDuration = 3.0;    // Show each captured photo for 3 seconds.
                self.imagePreview.animationRepeatCount = 0;   // Animate forever (show all photos).
                [self.imagePreview startAnimating];
            }
        }
    }*/
    
    self.imagePickerController = nil;
    [self.view bringSubviewToFront:self.toolbar];

}


// This method is called when an image has been chosen from the library or taken from the camera.
// we segue here to the collection view.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

// delegate method for image selector.
- (void)addItemViewController:(id)controller didFinishEnteringItem:(NSIndexPath *)indexPath{
    if (indexPath.item < self.capturedImages.count) {
        [self.capturedImages removeObjectAtIndex:indexPath.item];
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}

@end
