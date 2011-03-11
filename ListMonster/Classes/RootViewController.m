//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditListViewController.h"
#import "ListItemsViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListCell.h"
#import "ListColor.h"
#import "MetaList.h"
#import "NSArrayExtensions.h"
#import "RootViewController.h"

@interface RootViewController()

- (NSFetchRequest *)allListsFetchRequest;
- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList;
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
    [edListNav release];
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
    [[self navigationItem] setTitle:NSLocalizedString(@"Snap Lists", "@root view title")];

}

- (void)setEditing:(BOOL)inEditMode animated:(BOOL)animated {
    [super setEditing:inEditMode animated:animated];
}

- (void)addList:(id)sender {
    [self showEditViewWithList:nil];
}

- (void)showEditViewWithList:(MetaList *)list {
    
    EditListViewController *evc = [[EditListViewController alloc] initWithList:list];
    edListNav = [[UINavigationController alloc] initWithRootViewController:evc];
    [self presentModalViewController:edListNav animated:YES];
    [evc release];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [edListNav release], edListNav = nil;
    [[self tableView] reloadData];  // TODO: remove this if the list items view works rewritten with fetched results controller
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

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

    static NSString *CellId = @"ListCell";
    ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil];
        cell = (ListCell *)[nib objectAtIndex:0];
    }
    [self updateCell:cell forMetaList:[[self resultsController] objectAtIndexPath:indexPath]];
    return cell;

}

- (void)updateCell:(ListCell *)cell forMetaList:(MetaList *)metaList {
    [[cell nameLabel] setText:[metaList name]];
    [[cell nameLabel] setTextColor:[[metaList color] uiColor]];
    [[cell countsLabel] setText:@""];
    NSString *catName = [[metaList category] name];
    
    if (!catName) {
        [[cell categoryLabel] setHidden:YES];
        CGRect nameFrame = [[cell nameLabel] frame];
        CGFloat y = ceil((cell.frame.size.height - nameFrame.size.height) / 2.0f);
        nameFrame.origin.y = y; //13.0f;    
        [[cell nameLabel] setFrame:nameFrame];
    } else {
        [[cell categoryLabel] setHidden:NO];
        CGRect nameFrame = [[cell nameLabel] frame];
        nameFrame.origin.y = 0.0f;
        [[cell nameLabel] setFrame:nameFrame];
        [[cell categoryLabel] setText:catName];
    }
    if ([metaList items] && [[metaList items] count] > 0) {
        NSPredicate *byUncheckedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 0"];
        NSSet *uncheckedItems = [[metaList items] filteredSetUsingPredicate:byUncheckedItems];
        NSString *count = [NSString stringWithFormat:@"%d", [uncheckedItems count]];
        [[cell countsLabel] setText:count];
    }    
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MetaList *list = [[self resultsController] objectAtIndexPath:indexPath];
    ListItemsViewController *livc = [[ListItemsViewController alloc] initWithList:list];
    [[self navigationController] pushViewController:livc animated:YES];
    [livc release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    MetaList *list = [[self resultsController] objectAtIndexPath:indexPath];
    [self showEditViewWithList:list];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
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

