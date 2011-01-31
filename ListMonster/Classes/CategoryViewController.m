//
//  CategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "CategoryViewController.h"
#import "ListMonsterAppDelegate.h"
#import "Category.h"

@interface CategoryViewController()

- (NSFetchRequest *)categoryFetchRequest;
- (void)deleteCategory:(Category *)category;

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
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategory:)];
        [[self navigationItem] setLeftBarButtonItem:addButton];
        [addButton release];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}

- (void)addCategory:(id)sender {
    
    NSString *title = NSLocalizedString(@"New Category", @"new category alert title");
    NSString *placeholder = NSLocalizedString(@"category name", @"new category placeholder");
    // create a new category in the moc
}


#pragma mark -
#pragma mark modal view protocol methods

- (void)modalViewCancelPressed {
    [self dismissModalViewControllerAnimated:YES];
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc undo];
}

- (void)modalViewDonePressedWithReturnValue:(id)returnValue {
    [self dismissModalViewControllerAnimated:YES];
/*    NSError *error = nil;
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc save:&error];
    if (error) {
        [self displayErrorMessage:@"Unable to save list" forError:error];
        return;
    } */
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
    }
    Category *category = [[self resultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[category name]];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Category *category = [[self resultsController] objectAtIndexPath:indexPath];
        [self deleteCategory:category];
    }   
    /*
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    } */  
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

- (void)deleteCategory:(Category *)category {
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc deleteObject:category];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Error deleting category: %@", [error localizedDescription]);
        [ErrorAlert showWithTitle:@"Delete Error" andMessage:[error localizedDescription]];
    }
}

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

