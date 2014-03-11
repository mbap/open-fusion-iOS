//
//  GSFSavedDataViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/7/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataViewController.h"
#import "GSFSavedDataDetailViewController.h"
#import <GSFOpenCvImageProcessor.h>

@interface GSFSavedDataViewController ()

// takes paths of files saved in GSF Directory.
- (void)buildSavedDataListWithContents:(NSArray *)paths; // helper function for building the list.

// array for the data in file system.
@property (nonatomic) NSArray *datasource;

// dictionary that will get passed to the segued view Controller.
@property (nonatomic) NSDictionary *selectedFeature;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"GSFSaveData"];
    dispatch_queue_t fileQueue = dispatch_queue_create("fileQueue", NULL);
    dispatch_async(fileQueue, ^{
        __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
        spinner.color = [UIColor blackColor];
        spinner.center = self.tableView.center;
        [spinner startAnimating];
        [self.tableView addSubview:spinner];
        [self buildSavedDataListWithContents:[man contentsOfDirectoryAtPath:[url path] error:nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner removeFromSuperview];
            spinner = nil;
            [self.tableView reloadData];
        });
    });
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
    self.datasource = [NSArray arrayWithArray:list];
    
    // sort objects by name. **change this to sort by what ever we want if we want to sort.
    //NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //NSArray *sorter = [NSArray arrayWithObject:descriptor];
    //self.datasource = [NSMutableArray arrayWithArray:[self.datasource sortedArrayUsingDescriptors:sorter]];;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Feature Collection %ld", (long)section];
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
    
    // does reload image for new cells
        // set image below here
    dispatch_queue_t imageQueue = dispatch_queue_create("imageQueue", NULL);
    dispatch_async(imageQueue, ^{
        UIImage *cellImage = nil;
        if ([[feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *properties = [feature objectForKey:@"properties"];
            NSString *oimage = [properties objectForKey:@"oimage"];
            NSData *image =  [[NSData alloc] initWithBase64EncodedString:oimage options:0];
            GSFOpenCvImageProcessor *pro = [[GSFOpenCvImageProcessor alloc] init];
            cellImage = [pro rotateImage:[[UIImage alloc] initWithData:image] byDegrees:90];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = cellImage;
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#warning make this conditional to support multiselection.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row != 0) {
        return NO;
    } else {
        return YES;
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


@end
