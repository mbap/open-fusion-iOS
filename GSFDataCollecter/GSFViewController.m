//
//  GSFViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFViewController.h"
#import "GSFOpenCvImageProcessor.h"
#import "GSFImageCollectionViewCell.h"
#import "GSFOpenCvImageViewController.h"
#import "GSFData.h"



@interface GSFViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GSFImageSelectorDelegate>


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) NSTimer *cameraTimer;

@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSMutableArray *cvCapturedImages;
@property (nonatomic) BOOL showDetectionImages;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIImageView *imagePreview;
@property (nonatomic) GSFImageCollectionViewCell *imagecell;
@property (nonatomic) NSIndexPath *index;

@property (nonatomic, weak) NSMutableArray *locationMeasurements;
@property (nonatomic, weak) CLLocation *bestEffort;
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
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // select accuracy for the gps. we can go even higher in accuracy.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
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
        GSFOpenCvImageProcessor *processor = [[GSFOpenCvImageProcessor alloc] init];
        dispatch_queue_t hogQueue = dispatch_queue_create("hogQueue", NULL);
        [self.view bringSubviewToFront:self.spinner];
        [self.spinner startAnimating];
        self.navigationItem.hidesBackButton = YES;
        dispatch_async(hogQueue, ^{
            //self.cvCapturedImages = [processor detectPeopleUsingImageArray:self.capturedImages];
            self.cvCapturedImages = [processor detectFacesUsingImageArray:self.capturedImages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner stopAnimating];
                self.navigationItem.hidesBackButton = NO;
                [self performSegueWithIdentifier:@"viewOpenCvImages" sender:self];
            });
        });
    }
}

// loads the image picker for the camera.
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePickerController.showsCameraControls = YES;
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

// add gps location stuff in here.
- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    [self.view bringSubviewToFront:self.toolbar];
    if ([[self.capturedImages lastObject] isKindOfClass:[GSFData class]]){
        GSFData *data = [self.capturedImages lastObject];
        data.coords = [[CLLocation alloc] init];
        [self.locationManager startUpdatingLocation];
    }

}

// delegate for super class location manager
// gets called several times while the location manager is update gps coords.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // store all of the measurements, just so we can see what kind of data we might receive
    [self.locationMeasurements addObject:newLocation];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    
    if (self.bestEffort == nil || self.bestEffort.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffort = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [self.locationManager stopUpdatingLocation];
            GSFData *data = [self.capturedImages lastObject];
            data.coords = self.bestEffort;
        }
    }
}

// This method is called when an image has been chosen from the library or taken from the camera.
// we segue here to the collection view.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    GSFData *newdata = [[GSFData alloc] initWithImage:image];
    [self.capturedImages addObject:newdata];
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
        if ([[self.capturedImages objectAtIndex:indexPath.item] isKindOfClass:[GSFData class]]) {
            GSFData *data = [self.capturedImages objectAtIndex:indexPath.item];
            UIImage *image = data.image;
            if ([cell isKindOfClass:[GSFImageCollectionViewCell class]]) {
                UIImageView *imgview = ((GSFImageCollectionViewCell *)cell).imageView;
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
    } else if ([[segue identifier] isEqualToString:@"viewOpenCvImages"]) {
        GSFOpenCvImageViewController *controller = (GSFOpenCvImageViewController*)segue.destinationViewController;
        controller.cvCapturedImages = [[NSMutableArray alloc] init];
        controller.cvCapturedImages = self.cvCapturedImages;
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
