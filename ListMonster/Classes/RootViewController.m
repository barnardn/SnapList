//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

//#import "ListEditViewController.h"
#import "EditListViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "NSStringExtensions.h"
#import "RootViewController.h"

@interface RootViewController()

- (NSFetchRequest *)allListsFetchRequest;
- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList;

@end

@implementation RootViewController

@synthesize appDelegate, resultsController;

#pragma mark -
#pragma mark Initializers

- (id)init {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self)
        return nil;
    [self setAppDelegate:[ListMonsterAppDelegate sharedAppDelegate]];
    NSFetchRequest *allLists = [self allListsFetchRequest];
    NSFetchedResultsController *c = [appDelegate fetchedResultsControllerWithFetchRequest:allLists];
    [self setResultsController:c];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [resultsController release], resultsController = nil;
}


- (void)dealloc {
    [resultsController release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
}

- (void)setEditing:(BOOL)inEditMode animated:(BOOL)animated {
    [super setEditing:inEditMode animated:animated];
    if (inEditMode) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addList:)];
        [[self navigationItem] setLeftBarButtonItem:addBtn];
        [addBtn release];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
        DLog(@"in edit mode");
    }

}

- (void)addList:(id)sender {
    
    EditListViewController *evc = [[EditListViewController alloc] init];
    edListNav = [[UINavigationController alloc] initWithRootViewController:evc];
    [self presentModalViewController:edListNav animated:YES];
    [evc release];

}

#pragma mark -
#pragma mark List Edit Protocol delegate

- (void)didFinishEditingList:(MetaList *)aList {
    // do something with aList
    [self dismissModalViewControllerAnimated:YES];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self resultsController] sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectInfo = [[[self resultsController] sections] objectAtIndex:section];
    return [sectInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [self updateCell:cell forMetaList:[[self resultsController] objectAtIndexPath:indexPath]];
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList {
    [[cell textLabel] setText:[metaList name]];
    NSString *catName = [[metaList category] name];
    [[cell detailTextLabel] setText:catName];
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}

#pragma mark -

- (NSFetchRequest *)allListsFetchRequest {
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSFetchRequest *allListsFetchRequest = [[NSFetchRequest alloc] init];
    [allListsFetchRequest setEntity:[NSEntityDescription entityForName:@"MetaList" inManagedObjectContext:moc]];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *byCategory = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:byCategory, byName, nil];
    [allListsFetchRequest setSortDescriptors:sortDescriptors];
    
    [byName release];
    [byCategory release];
    [sortDescriptors release];
    
    return [allListsFetchRequest autorelease];
}


@end

