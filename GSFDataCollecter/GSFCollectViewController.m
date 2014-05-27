//
//  GSFCollectViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 5/25/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFCollectViewController.h"
#import "GSFDataSelectionViewController.h"
#import "UYLPasswordManager.h"
#import "GSFLoginViewController.h"
#import "GSFData.h"
#import "GSFDataTransfer.h"
#import "GSFProgressView.h"
#import "GSFLiveDataTableViewController.h"

@interface GSFCollectViewController () <UITableViewDataSource, UITableViewDelegate, GSFDataTransferDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL apiKeyChecked;

@property (nonatomic) BOOL dataChecked;

@property (nonatomic) GSFProgressView *uploadBar;

@property (nonatomic, weak) GSFData *selectedData;

- (IBAction)discardFeature:(id)sender;

@end

@implementation GSFCollectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // set api key to false;
    self.apiKeyChecked = NO;
    
    // add edit bar button item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(discardFeature:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    // see if user has an api key.
    if (self.apiKeyChecked == NO) {
        UYLPasswordManager *pman = [UYLPasswordManager sharedInstance];
        if (![pman validKey:nil forIdentifier:@"apikey"]) {
            // push view controller to get the api key.
            [self.navigationController pushViewController:[[GSFLoginViewController alloc] init] animated:YES];
        }
    }
    self.apiKeyChecked = YES;
    
    // this might not need to be called.
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.collectedData.count) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    GSFData *data = [self.collectedData objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f, %.2f", data.coords.coordinate.latitude, data.coords.coordinate.longitude];
    cell.textLabel.text = data.date;
    
    if (data.gsfImage.oimage) {
        cell.imageView.image = data.gsfImage.oimage;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete data from collected data array
        [self.collectedData removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        // delete data from the table.
        // if only one item in the table we must delete the section as well.
        if (self.collectedData.count > 0) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // weakly point to the selected data object that was selected.
    self.selectedData = [self.collectedData objectAtIndex:indexPath.row];
    
    // perform segue to the live data table to view details.
    [self performSegueWithIdentifier:@"mainStagingDetails" sender:self];
    
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)collectNewData:(id)sender
{
    [self performSegueWithIdentifier:@"selectionScreen" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectionScreen"]) {
        GSFDataSelectionViewController *child = (GSFDataSelectionViewController *)segue.destinationViewController;
        child.collectedData = self.collectedData;
    } else if ([[segue identifier] isEqualToString:@"mainStagingDetails"]) {
        GSFLiveDataTableViewController *child = (GSFLiveDataTableViewController *)segue.destinationViewController;
        child.data = self.selectedData;
    }
}

- (IBAction)sendDataToDB:(id)sender
{
    // send data.
    __block GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
    driver.delegate = self;
    self.uploadBar = [[GSFProgressView alloc] init];
    [self.view addSubview:self.uploadBar];
    [self.view bringSubviewToFront:self.uploadBar];
    dispatch_queue_t networkQueue = dispatch_queue_create("networkQueue", NULL);
    dispatch_async(networkQueue, ^{
        [driver uploadDataArray:[driver formatDataAsJSON:self.collectedData]];
    });
}

- (void)checkHttpStatus:(NSInteger)statusCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectedData removeAllObjects];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

// delegate method that provides data for the upload progres view indicator.
- (void)uploadPercentage:(float)percent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.uploadBar.progressBar setProgress:percent animated:YES];
        NSString *percentage = [NSString stringWithFormat:@"Uploading: %.1f%%", percent*100];
        [self.uploadBar setLabelText:percentage];
    });
}

- (IBAction)saveDataToPhone:(id)sender
{
    GSFDataTransfer *driver = [[GSFDataTransfer alloc] init];
    NSData *saveMe = [driver formatDataAsJSON:self.collectedData];
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"GSFSaveData"];
    NSLog(@"%@", [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]]);
    NSError *error = nil;
    [saveMe writeToURL:[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]] options:NSDataWritingAtomic error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem writing to filesystem. Collection won't be cleared." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Problem writing to filesystem.\n");
    } else {
        //NSLog(@"Write to filesystem succeeded.\n");
        [self.collectedData removeAllObjects];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)discardFeature:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
