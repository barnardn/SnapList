//
//  ItemStashViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 4/11/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "ItemStashViewController.h"
#import "ItemStash.h"
#import "ListMonsterAppDelegate.h"
#import "MetaListItem.h"

@interface ItemStashViewController()

- (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)moc;
- (void)dismissModalView;

@end


@implementation ItemStashViewController

@synthesize theList, resultsController, navBar, stashTableView, selectedItem;


#pragma mark -
#pragma mark Initialization

- (id)initWithList:(MetaList *)list {
    
    self = [super initWithNibName:@"ItemStashView" bundle:nil];
    if (!self) return nil;
    [self setTheList:list];
    NSFetchRequest *request = [self fetchRequestInContext:[list managedObjectContext]];
    NSFetchedResultsController *c = [[ListMonsterAppDelegate sharedAppDelegate] fetchedResultsControllerWithFetchRequest:request sectionNameKeyPath:nil];
    [self setResultsController:c];
    [[self resultsController] setDelegate:self];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
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
    [theList release];
    [navBar release];
    [stashTableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Item Stash", @"select item from stash view title")];
    [navItem setPrompt:NSLocalizedString(@"Choose an item from your stash", @"stash prompt")];
    [navItem setLeftBarButtonItem:cancelBtn];
    [navItem setRightBarButtonItem:doneBtn];
    [[self navBar] pushNavigationItem:navItem animated:NO];
    [cancelBtn release];
    [doneBtn release];
    [navItem release];
}

/*
- (void)editPressed:(id)sender {
    
    if ([self isEditing]) {
        [sender setTitle:NSLocalizedString(@"Edit", @"edit title")];
        [sender setStyle:UIBarButtonItemStylePlain];
        [self setEditing:NO animated:YES];
        
    } else {
        [sender setTitle:NSLocalizedString(@"Done", @"done title")];
        [sender setStyle:UIBarButtonItemStyleDone];
        [self setEditing:YES animated:YES];
    }
}
*/

- (void)cancelPressed:(id)sender {
    [self dismissModalView];
}

- (void)donePressed:(id)sender {
    
    if (!selectedItem) {
        [self dismissModalView];
        return;
    }
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    MetaListItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"MetaListItem" inManagedObjectContext:moc];
    [newItem setName:[selectedItem name]];
    if ([selectedItem quantity])
        [newItem setQuantity:[selectedItem quantity]];
    [newItem setList:[self theList]];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to add stash item to list %@", [error localizedDescription]);
        NSString *etitle = NSLocalizedString(@"Error", @"error text");
        NSString *msg = NSLocalizedString(@"Unable to add item to list", @"error message");
        [ErrorAlert showWithTitle:etitle andMessage:msg];
    }
    [self dismissModalView];
}

- (void)dismissModalView {
    [[self parentViewController] dismissModalViewControllerAnimated:YES]; 
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    ItemStash *item = [[self resultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[item name]];
    if ([item quantity])
        [[cell detailTextLabel] setText:[[item quantity] stringValue]];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ItemStash *item = [[self resultsController] objectAtIndexPath:indexPath];
        if (item == [self selectedItem])
            [self setSelectedItem:nil];
        NSManagedObjectContext *moc = [[self theList] managedObjectContext];
        [moc deleteObject:item];
    }   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell accessoryType] == UITableViewCellAccessoryCheckmark) {
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone]; 
        [self setSelectedItem:nil];
    } else {
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setSelectedItem:[[self resultsController] objectAtIndexPath:indexPath]];
    }
    [selectedCell setSelected:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *prevCell = [tableView cellForRowAtIndexPath:indexPath];
    [prevCell setAccessoryType:UITableViewCellAccessoryNone];    
}

#pragma mark -
#pragma mark NSFetchedResultsController delegate protocol

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self stashTableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [[self stashTableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self stashTableView] endUpdates];
}

#pragma mark -
#pragma mark Core data methods

- (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)moc {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ItemStash" inManagedObjectContext:moc]];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:byName,nil];
    
    [request setSortDescriptors:sortDescriptors];
    [byName release];
    [sortDescriptors release];
    
    return [request autorelease];
}


@end
