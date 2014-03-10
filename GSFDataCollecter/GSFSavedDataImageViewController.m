//
//  GSFSavedDataImageViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataImageViewController.h"
#import "GSFPageControllerContentViewController.h"
#import "GSFOpenCvImageProcessor.h"

@interface GSFSavedDataImageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSArray *vcs;

@end

@implementation GSFSavedDataImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    GSFPageControllerContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (GSFPageControllerContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    GSFPageControllerContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GSFPageContent"];
    GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
    pageContentViewController.imageView = [[UIImageView alloc] init];
    if (index == 0) {
        pageContentViewController.image = [pro rotateImage:[self.images objectAtIndex:index] byDegrees:90];
    } else {
        pageContentViewController.image = [self.images objectAtIndex:index];
    }
    pageContentViewController.imageView.contentMode = UIViewContentModeScaleAspectFit;
    pageContentViewController.index = index;
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GSFPageControllerContentViewController*) viewController).index;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((GSFPageControllerContentViewController*) viewController).index;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.images count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.images.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
