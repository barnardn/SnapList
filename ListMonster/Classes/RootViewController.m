//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "ListCategory.h"
#import "datetime_utils.h"
#import "EditListViewController.h"
#import "EditListItemViewController.h"
#import "ListItemsViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListCell.h"
#import "ListColor.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "RootViewController.h"
#import "TableHeaderView.h"
#import "ThemeManager.h"

@interface RootViewController()

- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (void)showEditViewWithList:(MetaList *)list;
- (NSMutableDictionary *)loadAllLists;
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForList:(MetaList *)list;


@end

@implementation RootViewController

@synthesize allLists, categoryNameKeys;

#pragma mark -
#pragma mark Initializers

- (id)init 
{
    self = [super init];
    if (!self) return nil;
    return self;
}


- (NSString *)nibName
{
    return @"RootView";
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

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedIndexPath = [[self tableView] indexPathForSelectedRow];
    if (selectedIndexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                            target:self 
                                                                            action:@selector(addList:)];
    [[self navigationItem] setLeftBarButtonItem:addBtn];
    [[self navigationItem] setTitle:NSLocalizedString(@"Snap Lists", "@root view title")];
    
    CGSize cellSize = [[UIImage imageNamed:@"bg-cell"] size];
    [[self tableView] setRowHeight:cellSize.height];
    
    [self setAllLists:[self loadAllLists]];
}

- (void)addList:(id)sender 
{
    [self showEditViewWithList:nil];
}

- (void)showEditViewWithList:(MetaList *)list 
{
    EditListViewController *evc = [[EditListViewController alloc] initWithList:list];
    [evc setNotificationMessage:NOTICE_LIST_UPDATE];
    edListNav = [[UINavigationController alloc] initWithRootViewController:evc];
    if (!list)
        [self presentModalViewController:edListNav animated:YES];
    else
        [[self navigationController] pushViewController:evc animated:YES];
}


- (void)updateIncompleteCountForList:(MetaList *)list 
{
    NSIndexPath *indexPath = [self indexPathForList:list];
    ListCell *listCell = (ListCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    NSInteger incompleteCount = [[list allIncompletedItems] count];
    NSString *countText = (incompleteCount == 0) ? @"" : [NSString stringWithFormat:@"%d", incompleteCount];
    [[listCell countsLabel] setText:countText];
    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
}

- (NSIndexPath *)indexPathForList:(MetaList *)list 
{
    NSString *categoryName = [[list category] name];
    NSString *key = (categoryName) ? categoryName : @"";
    NSInteger sectionIdx = [[self categoryNameKeys] indexOfObject:key];
    NSArray *itemsForCategory = [self allLists][key];
    NSInteger rowIdx = [itemsForCategory indexOfObject:list];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];    
    return indexPath;
}

#pragma mark -
#pragma mark Error handler routine

// TODO:  replace this with an actual error handling class!
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error 
{
    NSString *errMessage = [NSString stringWithFormat:@"%@: %@", message, [error localizedDescription]];
    DLog(errMessage);
    NSString *alertTitle = NSLocalizedString(@"Error during save", @"save list error title");
    [ErrorAlert showWithTitle:alertTitle andMessage: errMessage];
}

#pragma mark - Table view datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger sectionCount = [[self allLists] count];
    return (sectionCount == 0) ? 1 : sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger sectionCount = [[self allLists] count];
    if (sectionCount == 0)
        return 1;
    NSArray *listArr = [self allLists][[self categoryNameKeys][section]];
    return [listArr count];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellId = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
    if ([[self allLists] count] == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"Tap '+' to add a new list", @"add list instruction cell text")];
        [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
        [[cell textLabel] setTextColor:[ThemeManager ghostedTextColor]];
        return cell;
    }
    [self customizeListCell:cell];
    MetaList *listObj = [self listObjectAtIndexPath:indexPath];
    [[cell textLabel] setText:[listObj name]];
    NSInteger countIncomplete = [listObj countOfItemsCompleted:NO];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", countIncomplete]];
    return cell;
}

- (void)customizeListCell:(UITableViewCell *)cell
{
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setTextColor:[ThemeManager standardTextColor]];
    [[cell textLabel] setHighlightedTextColor:[ThemeManager highlightedTextColor]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForListDetails]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([[self allLists] count] == 0) {
        [self addList:nil];
        return ;
    }
    MetaList *list = [self listObjectAtIndexPath:indexPath];    
    ListItemsViewController *livc = [[ListItemsViewController alloc] initWithList:list];
    [[self navigationController] pushViewController:livc animated:YES];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    [self showEditViewWithList:list];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self allLists] count] == 0)
        return nil;
    return [self categoryNameKeys][section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self categoryNameKeys] objectAtIndex:section];
    UIView *headerView = [ThemeManager headerViewTitled:title withDimenions:CGSizeMake(CGRectGetWidth([[self tableView] frame]), [ThemeManager heightForHeaderview])];
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ThemeManager heightForHeaderview];
}

#pragma mark - list for index path methods

- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *listArr = [self listAtIndexPath:indexPath];
    return listArr[[indexPath row]];
}

- (NSMutableArray *)listAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIdx = [indexPath section];
    NSString *key = [self categoryNameKeys][sectionIdx];
    NSMutableArray *listArr = [self allLists][key];
    return listArr;
}

#pragma mark - Other core data related methods

- (NSMutableDictionary *)loadAllLists 
{
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *byCategory = [[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[byCategory, byName];
    NSArray *lists =  [[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"MetaList" sortDescriptors:sortDescriptors];
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    for (MetaList *l in lists) {
        NSString *key = ([l category]) ? [[l category] name] : @"";
        if (!listDict[key])
            listDict[key] = [NSMutableArray arrayWithObject:l];
        else {
            NSMutableArray *listArr = listDict[key];
            [listArr addObject:l];
        }
    }
    [self setCategoryNameKeys:[[listDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    return listDict;
}

#pragma mark - swipe to edit cell view controller overrides

- (void)rightSwipeUpdateAtIndexPath:(NSIndexPath *)indexPath
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    BOOL checkAll =  ([list allItemsFinished]) ? NO : YES;
    [[list itemsSet] enumerateObjectsUsingBlock:^(MetaListItem *item, BOOL *stop) {
        [item setIsComplete:checkAll];
    }];
    //[list save];
}

- (NSString *)rightSwipeActionTitleForItemItemAtIndexPath:(NSIndexPath *)indexPath
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    return ([list allItemsFinished]) ? @"List Reset" : @"All Done!";
}

- (BOOL)rightSwipeShouldDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)rightSwipeRemoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *categoryLists = [self listAtIndexPath:indexPath];
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    ZAssert([categoryLists containsObject:list], @"Whoa! list of lists does not contain list to delete");
    [categoryLists removeObject:list];
    NSError *error;
    //ZAssert([[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext] save:&error], @"Unable to delete list! %@", [error localizedDescription]);
}




@end

