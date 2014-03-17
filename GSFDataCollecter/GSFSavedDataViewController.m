//
//  GSFSavedDataViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/7/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataViewController.h"
#import "GSFSavedDataDetailViewController.h"
#import "GSFOpenCvImageProcessor.h"
#import "GSFTableButton.h"
#import "GSFDataTransfer.h"
#import "GSFSpinner.h"
#import "GSFLoginViewController.h"

#define headHeight 25
#define imageWidth 150


@interface GSFSavedDataViewController () <GSFDataTransferDelegate>
{
    void (^_completionHandler)(int someParameter);
}

// takes paths of files saved in GSF Directory.
- (void)buildSavedDataListWithContents:(NSArray *)paths; // helper function for building the list.

// array filled with files from the GSFSavedData Directory
@property (nonatomic) NSArray *fileList;

// array for the data in file system.
// index into this for data is same as fileList index for url
@property (nonatomic) NSMutableArray *datasource;

// property for caching the images in the file system.
@property (nonatomic) NSMutableDictionary *imageCache;

// dictionary that will get passed to the segued view Controller.
@property (nonatomic) NSDictionary *selectedFeature;

// property for the selected section in the custom header view
@property (nonatomic) NSInteger selectedFeatureSection;

// load images into a cache to remove the thread bombing i was doing haha.
- (void)cacheImagesWithCompletionHandler:(void(^)(void))handler;

// spinner for network transactions.
@property (nonatomic) GSFSpinner *uploadSpinner;

@end

@implementation GSFSavedDataViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set datasource and delegate to self.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelection = YES;
    
    // add image for background
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent.png"]];
        
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"GSFSaveData"];
    __block GSFSpinner *spinner = [[GSFSpinner alloc] init];
    [spinner setLabelText:@"Loading..."];
    [self.view addSubview:spinner];
    [spinner.spinner startAnimating];
    dispatch_queue_t fileQueue = dispatch_queue_create("fileQueue", NULL);
    dispatch_async(fileQueue, ^{
        self.fileList = [man contentsOfDirectoryAtPath:[url path] error:nil];
        [self buildSavedDataListWithContents:self.fileList];
        self.imageCache = [[NSMutableDictionary alloc] init];
        [self cacheImagesWithCompletionHandler:^{
            [self.tableView reloadData];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner.spinner stopAnimating];
            [spinner removeFromSuperview];
            spinner = nil;
            [self.tableView reloadData];
        });
    });
    
    [self.tableView setContentInset:UIEdgeInsetsMake(headHeight, 0, 0, 0)];

}

//build the festival arrays using an array PATHS of NSStrings.
- (void)buildSavedDataListWithContents:(NSArray *)paths
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
        NSFileManager *man = [[NSFileManager alloc] init];
        NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *url = [urls objectAtIndex:0];
        url = [url URLByAppendingPathComponent:@"GSFSaveData"];
        url = [url URLByAppendingPathComponent:path];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:NSJSONReadingMutableContainers error:&error];
        if (json != nil && error == nil) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                [list addObject:(NSDictionary*)json];
            }
        }
    }
    // load the list of GEOJSON Feature Collection Items into the datasource array
    self.datasource = [NSMutableArray arrayWithArray:list];
}

// build an image cache and reload the table when complete.
// cache one of the images in the background for the cell image view
// refresh the table with a call back after ward?
// n^2 algorithm for caching an image a bit slow but good for now.
- (void)cacheImagesWithCompletionHandler:(void(^)(void))handler
{
    NSArray *features = nil;
    for (NSDictionary *data in self.datasource) {
        if ([data isKindOfClass:[NSMutableDictionary class]]) {
            if ([[data objectForKey:@"features"] isKindOfClass:[NSArray class]]) {
                features = [data objectForKey:@"features"];
                NSUInteger iter = 0;
                NSMutableArray *images = [[NSMutableArray alloc] init];
                NSString *key = nil;
                if ([[features objectAtIndex:iter] isKindOfClass:[NSDictionary class]]) {
                    for (NSDictionary *feature in features) {
                        if ([[feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *properties = [feature objectForKey:@"properties"];
                            key = [NSString stringWithFormat:@"Section%lu", (unsigned long)iter++];
                            UIImage *image = nil;
                            if ([properties objectForKey:@"oimage"]) {
                                NSString *oimage = [properties objectForKey:@"oimage"];
                                NSData *imageData =  [[NSData alloc] initWithBase64EncodedString:oimage options:0];
                                if (imageData) {
                                    GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
                                    image = [pro rotateImage:[[UIImage alloc] initWithData:imageData] byDegrees:90];
                                }
                            } else if ([properties objectForKey:@"fimage"]) {
                                NSString *fimage = [properties objectForKey:@"fimage"];
                                NSData *imageData =  [[NSData alloc] initWithBase64EncodedString:fimage options:0];
                                if (imageData) {
                                    image = [UIImage imageWithData:imageData];
                                }
                            } else if ([properties objectForKey:@"pimage"]) {
                                NSString *pimage = [properties objectForKey:@"pimage"];
                                NSData *imageData =  [[NSData alloc] initWithBase64EncodedString:pimage options:0];
                                if (imageData) {
                                    image = [UIImage imageWithData:imageData];
                                }
                            }
                            [images addObject:image];
                        }
                    }
                    [self.imageCache setObject:images forKey:key];
                }
            }
        }
    }
    if (handler) handler();
}



#pragma mark - Table view data source
// return numbef of GEOJSON featureCollection object in the datasource array
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.datasource.count;
}

// method to specify number of rows in the table
// return number of features in a single GEOJSON featureCollection
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableDictionary *dict = nil;
    NSArray *features = nil;
    if ([[self.datasource objectAtIndex:section] isKindOfClass:[NSMutableDictionary class]]) {
        dict = [self.datasource objectAtIndex:section];
        if ([[dict objectForKey:@"features"] isKindOfClass:[NSArray class]]) {
            features = [dict objectForKey:@"features"];
        }
    }
    return features.count;
}

// fills the rows with data from each feature.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"]; // dequeue cell
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSMutableDictionary *dict = nil;
    NSArray *features = nil;
    if ([[self.datasource objectAtIndex:[indexPath section]] isKindOfClass:[NSMutableDictionary class]]) {
        dict = [self.datasource objectAtIndex:[indexPath section]];
        if ([[dict objectForKey:@"features"] isKindOfClass:[NSArray class]]) {
            features = [dict objectForKey:@"features"];
        }
    }
    
    NSDictionary *feature = [features objectAtIndex:[indexPath row]]; // get the feature for this row.
    
    // set the detailtextLabel with coordinates of the feature
    NSArray *coords = nil;
    if ([[feature objectForKey:@"geometry"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *geometry = [feature objectForKey:@"geometry"];
        if ([[geometry objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]) {
            coords = [geometry objectForKey:@"coordinates"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [coords objectAtIndex:0], [coords objectAtIndex:1]];
        }
    }
    
    // set main text view with the timestamp of the feature
    if ([[feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *properties = [feature objectForKey:@"properties"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[properties objectForKey:@"timestamp"] doubleValue]];
        cell.textLabel.text = [date description];
    }
    
    NSArray *images = [self.imageCache objectForKey:[NSString stringWithFormat:@"Section%ld", (long)indexPath.section]];
    cell.imageView.image = [images objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = nil;
    NSArray *features = nil;
    if ([[self.datasource objectAtIndex:[indexPath section]] isKindOfClass:[NSMutableDictionary class]]) {
        dict = [self.datasource objectAtIndex:[indexPath section]];
        if ([[dict objectForKey:@"features"] isKindOfClass:[NSArray class]]) {
            features = [dict objectForKey:@"features"];
        }
    }
    
    self.selectedFeature = [features objectAtIndex:[indexPath row]]; // get the feature for this row.
    [self performSegueWithIdentifier:@"viewSavedFileDetails" sender:self];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewSavedFileDetails"]) {
        // get selected content and pass it to the next controller
        GSFSavedDataDetailViewController *controller = (GSFSavedDataDetailViewController*)segue.destinationViewController;
        controller.feature = self.selectedFeature;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return headHeight;
}


// if the header button gets touched we upload the data to the server.
- (void)headerTapped:(GSFTableButton*)button
{
    // send data to the server. deletion of file on success handled by GSFDataTransfer object
    GSFDataTransfer *uploader = [[GSFDataTransfer alloc] initWithURL:[self.fileList objectAtIndex:button.section]];
    uploader.delegate = self;
    dispatch_queue_t networkQueue = dispatch_queue_create("networkQueue", NULL);
    self.uploadSpinner = [[GSFSpinner alloc] init];
    [self.uploadSpinner setLabelText:@"Sending..."];
    [self.view addSubview:self.uploadSpinner];
    [self.view bringSubviewToFront:self.uploadSpinner];
    [self.uploadSpinner.spinner startAnimating];
    dispatch_async(networkQueue, ^{
        NSDictionary *featureCollection = [self.datasource objectAtIndex:button.section];
        self.selectedFeatureSection = button.section;
        if ([NSJSONSerialization isValidJSONObject:featureCollection]) {
            [uploader uploadDataArray:[NSJSONSerialization dataWithJSONObject:featureCollection options:NSJSONWritingPrettyPrinted error:nil]];
        }
    });
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, headHeight)];
    GSFTableButton *button = [[GSFTableButton alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - imageWidth, 0, imageWidth, headHeight) forSection:section];
    [button setImage:[UIImage imageNamed:@"upload.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(headerTapped:)  forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    NSString * string = [NSString stringWithFormat:@"Feature Collection %ld", (long)section + 1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(headHeight, 0, tableView.bounds.size.width - (headHeight * 3), headHeight)];
    label.text = string;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    return view;
}

// delegate method that sends message reguarding the status
- (void)checkHttpStatus:(NSInteger)statusCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (statusCode == 200 || statusCode == 201) {
            [self.datasource removeObjectAtIndex:self.selectedFeatureSection];
            [self.tableView reloadData];
        } else if (statusCode == 403){
            [self.navigationController pushViewController:[[GSFLoginViewController alloc] init] animated:YES];
        }
        [self.uploadSpinner.spinner stopAnimating];
        [self.uploadSpinner removeFromSuperview];
        self.uploadSpinner = nil;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
