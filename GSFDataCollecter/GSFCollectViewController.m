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

@interface GSFCollectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray *collectedData;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL apiKeyChecked;

@property (nonatomic) BOOL dataChecked;

@end

@implementation GSFCollectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // allocate the data source
    self.collectedData = [[NSMutableArray alloc] init];
    
    // set api key to false;
    self.apiKeyChecked = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    // see if user has an api key.
    if (self.apiKeyChecked == NO) {
        UYLPasswordManager *pman = [UYLPasswordManager sharedInstance];
        if (![pman validKey:nil forIdentifier:@"apikey"]) {
            // push view controller to get the api key.
            [self.navigationController pushViewController:[[GSFLoginViewController alloc] init] animated:YES];
        } else if (self.collectedData.count == 0) {
            [self performSegueWithIdentifier:@"selectionScreen" sender:self];
        }
    }
    self.apiKeyChecked = YES;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    NSLog(@"%@", [NSString stringWithFormat:@"%.2f, %.2f", data.coords.coordinate.latitude, data.coords.coordinate.longitude]);
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    }
}

- (IBAction)sendDataToDB:(id)sender
{
    
}

- (IBAction)saveDataToPhone:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
