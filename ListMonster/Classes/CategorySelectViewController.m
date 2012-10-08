//
//  CategorySelectViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/24/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "Category.h"
#import "CategorySelectViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"

@interface CategorySelectViewController()

- (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)moc;
- (void)deleteCategory:(Category *)aCategory;

@end

@implementation CategorySelectViewController

@synthesize resultsController, theList, theCategory, selectedCategory;
@synthesize lastSelectedIndexPath;

#pragma mark -
#pragma mark Initialization


- (id)initWithList:(MetaList *)aList 
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:aList];
    NSFetchRequest *request = [self fetchRequestInContext:[aList managedObjectContext]];
    NSFetchedResultsController *c = [[ListMonsterAppDelegate sharedAppDelegate] fetchedResultsControllerWithFetchRequest:request sectionNameKeyPath:nil];
    [c setDelegate:self];
    [self setResultsController:c];    

    return self;
}

- (id)initWithStyle:(UITableViewStyle)style 
{
    return nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"list back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"edit button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(editPressed:)];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self navigationItem] setRightBarButtonItem:editBtn];
    [[self navigationItem] setTitle:NSLocalizedString(@"Select Category", @"category selection only view title")];
    [self setLastSelectedIndexPath:nil];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Backgrounds/normal"]];
    [[self tableView] setBackgroundView:backgroundView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self isEditing])
        [[self theList] setCategory:[self selectedCategory]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


#pragma mark -
#pragma mark Button actions

- (void)editPressed:(id)sender 
{
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


- (void)setEditing:(BOOL)inEditMode animated:(BOOL)animated 
{
    [super setEditing:inEditMode animated:animated];
    if (inEditMode) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnPressed:)];
        [[self navigationItem] setLeftBarButtonItem:addBtn];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}

- (void)addBtnPressed:(id)sender {
    
    [self setLastSelectedIndexPath:nil];
    EditCategoryViewController *ecvc = [[EditCategoryViewController alloc] initWithList:[self theList]];
    [ecvc setDelegate:self];
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    Category *newCat = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:moc];
    [self setTheCategory:newCat];
    [ecvc setCategory:[self theCategory]];  // analyzer false positive  -- yes 'new' in name is against convention and confusing analyzer
    [self presentModalViewController:ecvc animated:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    Category *cat = [[self resultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[cat name]];
    
    Category *listCategory = [[self theList] category];
    BOOL isSelectedCategory = (NSOrderedSame == [[listCategory name] compare:[cat name]]);
    if (!listCategory) isSelectedCategory = NO;
    
    if (isSelectedCategory && ![self lastSelectedIndexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setSelectedCategory:listCategory];
        [self setLastSelectedIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Category *cat = [[self resultsController] objectAtIndexPath:indexPath];
        [self deleteCategory:cat];
    }   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([self lastSelectedIndexPath] && ([indexPath row] == [[self lastSelectedIndexPath] row])) return;
    Category *category = [[self resultsController] objectAtIndexPath:indexPath];
    [self setSelectedCategory:category];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    if ([self lastSelectedIndexPath]) {
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[self lastSelectedIndexPath]];
        [lastCell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setLastSelectedIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    Category *cat = [[self resultsController] objectAtIndexPath:indexPath];
    
    EditCategoryViewController *ecvc = [[EditCategoryViewController alloc] initWithList:[self theList]];
    [ecvc setDelegate:self];
    [ecvc setCategory:cat];
    [[self navigationController] pushViewController:ecvc animated:YES];
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
    Category *cat =  nil;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
            [[self tableView] scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        case NSFetchedResultsChangeUpdate:
            cat = [[self resultsController] objectAtIndexPath:indexPath];
            if ([[cat changedValues] count] == 0) return;
            cell = [[self tableView] cellForRowAtIndexPath:indexPath];
            [[cell textLabel] setText:[cat name]];
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationNone];
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {    
    [[self tableView] endUpdates];
}

#pragma mark -
#pragma mark Edit Category Delegate Method

- (void)editCategoryViewController:(EditCategoryViewController *)editCategoryViewController didEditCategory:(Category *)category {
    if (!category) {
        [[[self theList] managedObjectContext] deleteObject:[self theCategory]];  // analyzer false positive due to 'new' in name
    } else {
        [[self theList] setCategory:category];
    }

}

#pragma mark -
#pragma mark Coredata methods


- (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)moc {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc]];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:byName,nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    return request;
}

- (void)deleteCategory:(Category *)aCategory {
    if (aCategory == [self selectedCategory])
        [self setSelectedCategory:nil];
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    [moc deleteObject:aCategory];
}


@end

