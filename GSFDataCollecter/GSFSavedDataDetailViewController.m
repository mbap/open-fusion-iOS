//
//  GSFSavedDataDetailViewController.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 3/9/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFSavedDataDetailViewController.h"
#import "GSFSavedDataImageViewController.h"

@interface GSFSavedDataDetailViewController ()

@end

@implementation GSFSavedDataDetailViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // this should be the number of properties in a GSF Geojson object.
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) { //create a new cell (only gets called for searchResultsTableView)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (0 == [indexPath row]) {
        cell.textLabel.text = @"View Images";
    } else {
        if (1 == indexPath.row) {
            if ([[self.feature objectForKey:@"geometry"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *geometry = [self.feature objectForKey:@"geometry"];
                if ([[geometry objectForKey:@"coordinates"] isKindOfClass:[NSArray class]]) {
                    NSArray *coords = [geometry objectForKey:@"coordinates"];
                    NSString *coord = [[NSString alloc] initWithFormat:@"GPS: %.4f, %.4f", [[coords objectAtIndex:0] doubleValue], [[coords objectAtIndex:1] doubleValue]];
                    cell.textLabel.text = coord;
                }
            }
        } else {
            NSDictionary *properties = nil;
            if ([[self.feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
                properties = [self.feature objectForKey:@"properties"];
            }
            if(2 == indexPath.row) {
                NSString *datestring = @"Date: ";
                cell.textLabel.text = [datestring stringByAppendingString:[properties objectForKey:@"timestamp"]];
            } else if (3 == indexPath.row) {
                if ([properties objectForKey:@"altitude"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Altitude: %.2fm", [[properties objectForKey:@"altitude"] doubleValue]];
                }
            } else if (4 == indexPath.row) {
                if ([properties objectForKey:@"h_accuracy"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"H_Acc: %.1f", [[properties objectForKey:@"h_accuracy"] doubleValue]];
                }
            } else if (5 == indexPath.row) {
                if ([properties objectForKey:@"v_accuracy"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"V_Acc: %.1f", [[properties objectForKey:@"v_accuracy"] doubleValue]];
                }
            } else if (6 == indexPath.row) {
                if ([properties objectForKey:@"faces_detected"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: %d detected.", [[properties objectForKey:@"faces_detected"] intValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"Faces: 0."];
                }
            } else if (7 == indexPath.row) {
                if ([properties objectForKey:@"people_detected"]) {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: %d detected.", [[properties objectForKey:@"people_detected"] intValue]];
                } else {
                    cell.textLabel.text = [[NSString alloc] initWithFormat:@"People: 0."];
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == [indexPath row]) {
        [self performSegueWithIdentifier:@"viewSavedFileImages" sender:self];
    }
}


 
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewSavedFileImages"]) {
        GSFSavedDataImageViewController *controller = (GSFSavedDataImageViewController*)segue.destinationViewController;
        if ([[self.feature objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *properties = [self.feature objectForKey:@"properties"];
            UIImage *oimage = nil;
            UIImage *fimage = nil;
            UIImage *pimage = nil;
            if ([properties objectForKey:@"oimage"]) {
                oimage = [[UIImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[properties objectForKey:@"oimage"] options:0]];
            }
            if ([properties objectForKey:@"pimage"]) {
                pimage = [[UIImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[properties objectForKey:@"pimage"] options:0]];
            }
            if ([properties objectForKey:@"fimage"]) {
                fimage = [[UIImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[properties objectForKey:@"fimage"] options:0]];
            }
            NSArray *images = [[NSArray alloc] initWithObjects:oimage, pimage, fimage, nil];
            controller.images = images;
        }
    }
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


@end
