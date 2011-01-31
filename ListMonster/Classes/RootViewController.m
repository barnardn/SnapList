//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditListViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListColor.h"
#import "MetaList.h"
#import "NSArrayExtensions.h"
#import "RootViewController.h"

@interface RootViewController()

- (NSFetchRequest *)allListsFetchRequest;
- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList;
- (ListColor *)blackColor;
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (void)deleteListEntity:(MetaList *)list;
- (void)showEditViewWithList:(MetaList *)list;

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
    [c setDelegate:self];
    [self setResultsController:c];
    [[self tabBarItem] setTitle:@"Lists"];   // TODO: change me.
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
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addList:)];
    [[self navigationItem] setLeftBarButtonItem:addBtn];
    [addBtn release];

}

- (void)setEditing:(BOOL)inEditMode animated:(BOOL)animated {
    [super setEditing:inEditMode animated:animated];
/*    if (inEditMode) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addList:)];
        [[self navigationItem] setLeftBarButtonItem:addBtn];
        [addBtn release];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
        DLog(@"in edit mode");
    } */
}

- (void)addList:(id)sender {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MetaList" inManagedObjectContext:moc];
    MetaList *newList = [[MetaList alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    [newList setName:NSLocalizedString(@"New List", @"default new list name")];
    [newList setColor:[self blackColor]];
    [self showEditViewWithList:newList];
    [newList release];
}

- (void)showEditViewWithList:(MetaList *)list {
    
    EditListViewController *evc = [[EditListViewController alloc] initWithList:list];
    [evc setModalParent:self];
    edListNav = [[UINavigationController alloc] initWithRootViewController:evc];
    [self presentModalViewController:edListNav animated:YES];
    [evc release];
}

- (ListColor *)blackColor {
    
    NSArray *colors = [[ListMonsterAppDelegate sharedAppDelegate] allColors];
    NSArray *blackColor = [colors filterBy:^ BOOL (id obj) {
        ListColor *color = obj;
        return (NSOrderedSame == [[color rgbValue] compare:INT_OBJ(0)]);
    }];
    return [blackColor objectAtIndex:0];
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
    NSError *error = nil;
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc save:&error];
    if (error) {
        [self displayErrorMessage:@"Unable to save list" forError:error];
        return;
    }
}
    
#pragma mark -
#pragma mark Error handler routine

// TODO:  replace this with an actual error handling class!
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error {
    
    NSString *errMessage = [NSString stringWithFormat:@"%@: %@", message, [error localizedDescription]];
    DLog(errMessage);
    NSString *alertTitle = NSLocalizedString(@"Error during save", @"save list error title");
    [ErrorAlert showWithTitle:alertTitle andMessage: errMessage];
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
        [cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    [self updateCell:cell forMetaList:[[self resultsController] objectAtIndexPath:indexPath]];
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList {
    [[cell textLabel] setText:[metaList name]];
    [[cell textLabel] setTextColor:[[metaList color] uiColor]];
    NSString *catName = [[metaList category] name];
    [[cell detailTextLabel] setText:catName];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MetaList *dl = [[self resultsController] objectAtIndexPath:indexPath];
        [self deleteListEntity:dl];
    }   
    /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    } */  
}



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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    MetaList *list = [[self resultsController] objectAtIndexPath:indexPath];
    [self showEditViewWithList:list];
}


#pragma mark -
#pragma mark NSFetchedResultsController protocol

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
    MetaList *theList =  nil;
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
            theList = [[self resultsController] objectAtIndexPath:indexPath];
            [self updateCell:cell forMetaList:theList];
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller     
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type 
{
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
                [[self tableView] insertSections:sections
                                withRowAnimation:UITableViewRowAnimationFade];
                break;
        case NSFetchedResultsChangeDelete:
                [[self tableView] deleteSections:sections
                                withRowAnimation:UITableViewRowAnimationFade];                
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

#pragma mark -
#pragma mark Other core data related methods

- (NSFetchRequest *)allListsFetchRequest {
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    NSFetchRequest *allListsFetchRequest = [[NSFetchRequest alloc] init];
    [allListsFetchRequest setEntity:[NSEntityDescription entityForName:@"MetaList" inManagedObjectContext:moc]];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *byCategory = [[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:byCategory, byName, nil];
    [allListsFetchRequest setSortDescriptors:sortDescriptors];
    
    [byName release], byName = nil;
    [byCategory release], byCategory = nil;
    [sortDescriptors release], sortDescriptors = nil;
    
    return [allListsFetchRequest autorelease];
}

- (void)deleteListEntity:(MetaList *)list {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc deleteObject:list];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        NSString *errMsg = NSLocalizedString(@"Unable to delete list", @"list delete error message");
        [self displayErrorMessage:errMsg forError:error];
    }
}


@end

