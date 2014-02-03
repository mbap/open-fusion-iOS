//
//  GSFViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist - LLNL on 1/10/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFViewController.h"
#import "GSFPhotoSelector.h"
#import "GSFOpenCvImageProcessor.h"


@interface GSFViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSMutableArray *newImages;
@property (nonatomic) BOOL showDetectionImages;

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
        GSFOpenCvImageProcessor *processor = [[GSFOpenCvImageProcessor alloc] init];
        self.newImages = [processor detectPeopleUsingImageArray:self.capturedImages];
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
    
    if ([self.capturedImages count] > 0)
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
            if ([self.newImages count] == 1)
            {
                // Camera took a single picture.
                [self.imagePreview setImage:[self.newImages objectAtIndex:0]];
            }
            else
            {
                // Camera took multiple pictures; use the list of images for animation.
                self.imagePreview.animationImages = self.newImages;
                self.imagePreview.animationDuration = 3.0;    // Show each captured photo for 3 seconds.
                self.imagePreview.animationRepeatCount = 0;   // Animate forever (show all photos).
                [self.imagePreview startAnimating];
            }
        }
    }
    
    self.imagePickerController = nil;
    [self.view bringSubviewToFront:self.toolbar];

}


// This method is called when an image has been chosen from the library or taken from the camera.
// we segue here to the collection view.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImages addObject:image];
    [self performSegueWithIdentifier:@"selectorsegue" sender:self];
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


// called before the segue happens
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectorsegue"]) {
        GSFPhotoSelector *selector = (GSFPhotoSelector*)segue.destinationViewController;
        selector.capturedImages = [[NSMutableArray alloc] initWithArray:self.capturedImages];
    }
}


// if remove button is pushed in the grandchild view controller remove the picture and shift everything into position.
- (void)removeObjectFromImagePickerControllerAtIndex:(NSUInteger)index
{
    UIImage *clear = [self.capturedImages objectAtIndex:index];
    clear = nil;
}

- (void)removeItemFromCapturedImageArrayAtIndex:(NSUInteger)index
{
    if (index < self.capturedImages.count) {
        [self.capturedImages removeObjectAtIndex:index];
    }
}


@end
