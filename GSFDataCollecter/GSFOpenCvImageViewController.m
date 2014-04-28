//
//  GSFOpenCvImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 2/5/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageViewController.h"
#import "GSFImage.h"
#import "GSFDataTransfer.h"
#import "GSFOpenCVPageViewController.h"

@interface GSFOpenCvImageViewController () <NSURLSessionTaskDelegate, NSURLSessionDelegate, UIActionSheetDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GSFOpenCVPageViewControllerDelegate>

// properties of the page controller;
@property (nonatomic) NSMutableArray *cvImages;
@property (nonatomic) NSMutableArray *cvNums;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSArray *vcs;

@end


@implementation GSFOpenCvImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self parseOpenImages];
    
    GSFOpenCVPageViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)parseOpenImages {
    self.cvImages = [[NSMutableArray alloc] init];
    self.cvNums = [[NSMutableArray alloc] init];
    for (GSFData *data in self.originalData) {
        if (data.gsfImage.fimage) {
           [self.cvImages addObject:data.gsfImage.fimage];
           [self.cvNums addObject:data.gsfImage.faceDetectionNumber];
        }
        if (data.gsfImage.pimage) {
            [self.cvImages addObject:data.gsfImage.pimage];
            [self.cvNums addObject:data.gsfImage.personDetectionNumber];
        }
    }
}

- (GSFOpenCVPageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    GSFOpenCVPageViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cvpager"];
    pageContentViewController.imageView = [[UIImageView alloc] init];
    UIImage *image = [self.cvImages objectAtIndex:index];
    pageContentViewController.image = image;
    pageContentViewController.imageView.contentMode = UIViewContentModeScaleAspectFit;
    pageContentViewController.index = index;
    pageContentViewController.delegate = self;
    NSNumber *num = [self.cvNums objectAtIndex:index];
    pageContentViewController.quantity = [[NSNumber alloc] initWithInt:num.intValue];
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GSFOpenCVPageViewController*) viewController).index;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GSFOpenCVPageViewController*) viewController).index;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.cvImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.cvImages.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)sendData
{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Discard", @"Send Original(s)", nil];
    [menu showInView:self.view];
}

- (void)saveData
{
    GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
    NSData *saveMe = [driver formatDataAsJSON:self.originalData];
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"GSFSaveData"];
    NSLog(@"%@", [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]]);
    NSError *error = nil;
    [saveMe writeToURL:[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]] options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"Problem writing to filesystem.\n");
    } else {
        NSLog(@"Write to filesystem succeeded.\n");
    }
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[viewControllers objectAtIndex:1] animated:YES];
}

- (void)updateResult:(NSNumber *)update atIndex:(NSUInteger)index
{
    [self.cvNums replaceObjectAtIndex:index withObject:update];
    if (self.originalData.count == self.cvNums.count) {         // we know that only face or person happened.
       GSFData *data = [self.originalData objectAtIndex:index];
        if (data.gsfImage.fimage) {
            data.gsfImage.faceDetectionNumber = update;
        } else {
            data.gsfImage.personDetectionNumber = update;
        }
    } else {                                                    // we know that both are on.
       GSFData *data = [self.originalData objectAtIndex:index/2];
        if (index%2 == 0) {
            data.gsfImage.faceDetectionNumber = update;
        } else {
            data.gsfImage.personDetectionNumber = update;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
    if (0 == buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (2 == buttonIndex) {
        // do nothing
    } else {
        dispatch_queue_t networkQueue = dispatch_queue_create("networkQueue", NULL);
        dispatch_async(networkQueue, ^{
            [driver uploadDataArray:[driver formatDataAsJSON:self.originalData]];
        });
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//
//    GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
//    NSMutableArray *cycler = [[NSMutableArray alloc] init];
//    int i = 0;
//    for (GSFData *data in self.originalData) {
//        NSNumber *num = [self.originalOrientation objectAtIndex:i];
//        if (num.intValue == UIImageOrientationLeft) { // requires 90 clockwise rotation
//            if (data.gsfImage.fimage) {
//                [cycler addObject:data.gsfImage.fimage];
//            }
//            if (data.gsfImage.pimage) {
//                [cycler addObject:data.gsfImage.pimage];
//            }
//        } else if (num.intValue == UIImageOrientationUp) { // 90 counter clock
//            if (data.gsfImage.fimage) {
//                data.gsfImage.fimage = [pro rotateImage:data.gsfImage.fimage byDegrees:-90];
//                [cycler addObject:data.gsfImage.fimage];
//            }
//            if (data.gsfImage.pimage) {
//                data.gsfImage.pimage = [pro rotateImage:data.gsfImage.pimage byDegrees:-90];
//                [cycler addObject:data.gsfImage.pimage];
//            }
//        } else if (num.intValue == UIImageOrientationDown) { // 180 rotation.
//            if (data.gsfImage.fimage) {
//                data.gsfImage.fimage = [pro rotateImage:data.gsfImage.fimage byDegrees:-90];
//                [cycler addObject:data.gsfImage.fimage];
//            }
//            if (data.gsfImage.pimage) {
//                data.gsfImage.pimage = [pro rotateImage:data.gsfImage.pimage byDegrees:-90];
//                [cycler addObject:data.gsfImage.pimage];
//            }
//        } else {
//            if (data.gsfImage.fimage) {
//                [cycler addObject:data.gsfImage.fimage];
//            }
//            if (data.gsfImage.pimage) {
//                [cycler addObject:data.gsfImage.pimage];
//            }
//        }
//        ++i;
//    }
//
//    self.imageView.animationImages = cycler;
//    self.imageView.animationDuration = 4;
//    self.imageView.animationRepeatCount = 0;
//    [self.imageView startAnimating];
//    [self.view bringSubviewToFront:self.toolbar];
//}

@end
