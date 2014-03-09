//
//  GSFSavedDataViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/7/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataViewController.h"

@interface GSFSavedDataViewController ()

// takes paths of files saved in GSF Directory.
- (void)buildSavedDataListWithContents:(NSArray *)paths; // helper function for building the list.

// array for the data in file system.
@property (nonatomic) NSArray *datasource;

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // add custom image behind table view.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"transparent" ofType:@"png"]]];
    
    NSFileManager *man = [[NSFileManager alloc] init];
    NSArray *urls = [man URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [urls objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"/GSFSaveData"];
    NSString *dataPath = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self buildSavedDataListWithContents:[man contentsOfDirectoryAtPath:dataPath error:nil]];
}

//build the festival arrays
- (void)buildSavedDataListWithContents:(NSArray *)paths
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSURL *path in paths) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:path] options:NSJSONReadingMutableContainers error:&error];
        if (json != nil && error == nil) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                [list addObject:(NSDictionary*)json];
            }
        }

    }
    self.datasource = [NSArray arrayWithArray:list];
    // sort festival objects by name.
    //NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //NSArray *sorter = [NSArray arrayWithObject:descriptor];
    //self.da = [NSMutableArray arrayWithArray:[self.datasource sortedArrayUsingDescriptors:sorter]];;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.datasource.count;
}

// method to specify number of rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// fills the rows with data.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"]; // dequeue cell
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    //create a cell background image
    UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:cell.frame];
    UIImage *cellImage = [UIImage imageNamed:@"LightGrey.png"];
    cellImageView.image = cellImage;
    cell.backgroundView = cellImageView;
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    /*
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if (self.searchResults.count) {
            FestivalInfo *festival = [self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = festival.name;
            cell.detailTextLabel.text = @"testing poop Here"; //subtitle property
        } else {
            cell.textLabel.text = @"Submit a Festival?";
        }
    } else {
        FestivalInfo *festival = [self.datasource objectAtIndex:indexPath.row];
        cell.textLabel.text = festival.name;
        if (_x%4 == 0) {
            cell.detailTextLabel.text = @"Electric"; //subtitle property
        } else if (_x%4 == 1) {
            cell.detailTextLabel.text = @"Rock"; //subtitle property
        } else if (_x%4 == 2) {
            cell.detailTextLabel.text = @"Reggee"; //subtitle property
        } else if (_x%4 == 3) {
            //cell.detailTextLabel.text = @"Hip Hop";
        }
        _x++;
    }
     */
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
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
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
