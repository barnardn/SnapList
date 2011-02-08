//
//  CategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "Category.h"
#import "CategoryViewController.h"
#import "ListMonsterAppDelegate.h"
#import "CategoryEditViewController.h"

@interface CategoryViewController()

- (NSFetchRequest *)categoryFetchRequest;

@end


@implementation CategoryViewController

@synthesize resultsController;

#pragma mark -
#pragma mark Initialization

- (id)initWithInfo:(NSDictionary *)info {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    NSFetchRequest *request = [[self categoryFetchRequest] retain];
    NSFetchedResultsController *c = [[ListMonsterAppDelegate sharedAppDelegate] fetchedResultsControllerWithFetchRequest:request];
    [request release];
    [c setDelegate:self];
    [self setResultsController:c];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithInfo:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [resultsController release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                               target:self 
                                                                               action:@selector(addCategory:)];
    [[self navigationItem] setRightBarButtonItem:addButton];
    [addButton release];
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


- (void)addCategory:(id)sender {
    
    CategoryEditViewController *cevc = [[CategoryEditViewController alloc] initWithCategory:nil];
    [[self navigationController] pushViewController:cevc animated:YES];
    [cevc release];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[[self resultsController] sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectInfo = [[[self resultsController] sections] objectAtIndex:section];
    return [sectInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    Category *category = [[self resultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[category name]];
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Category *category = [[self resultsController] objectAtIndexPath:indexPath];
    CategoryEditViewController *cevc = [[CategoryEditViewController alloc] initWithCategory:category];
    [[self navigationController] pushViewController:cevc animated:YES];
    [cevc release];
}


#pragma mark -
#pragma mark NSFetchedResultsController delegate protocol

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableViewCell *cell = nil;
    Category *theCategory =  nil;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] 
                            withRowAnimation:UITableViewRowAnimationFade];
        case NSFetchedResultsChangeUpdate:
            cell = [[self tableView] cellForRowAtIndexPath:indexPath];
            theCategory = [[self resultsController] objectAtIndexPath:indexPath];
            [[cell textLabel] setText:[theCategory name]];
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}


#pragma mark -
#pragma mark Coredata methods


- (NSFetchRequest *)categoryFetchRequest {
    ListMonsterAppDelegate *appDelegate = [ListMonsterAppDelegate sharedAppDelegate];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:[appDelegate managedObjectContext]]];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:byName,nil];
    
    [request setSortDescriptors:sortDescriptors];
    [byName release];
    [sortDescriptors release];
    
    return [request autorelease];
}


@end

