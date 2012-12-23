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
#import "ListManagerViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListCell.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSDate+FormattedDates.h"
#import "RootViewController.h"
#import "TableHeaderView.h"
#import "ThemeManager.h"

#define KEY_OVERDUE     @"--overdue--"

@interface RootViewController() <ListManagerDelegate>

- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (NSMutableDictionary *)loadAllLists;
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForList:(MetaList *)list;

@property(nonatomic,strong) NSMutableArray *categoryNameKeys;
@property(nonatomic,strong) NSMutableDictionary *allLists;
@property (nonatomic, strong) UINavigationController *listManagerViewController;

@end

@implementation RootViewController


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
    
    NSMutableArray *overdue = [[MetaListItem itemsDueOnOrBefore:tomorrow()] mutableCopy];
    
    [[self tableView] beginUpdates];
    if ([overdue count] == 0) {
        NSArray *previousOverdue = [[self allLists] objectForKey:KEY_OVERDUE];
        if (previousOverdue) {
            [[self allLists] removeObjectForKey:KEY_OVERDUE];
            NSArray *userCategories = [[self categoryNameKeys] filterBy:^BOOL(NSString *categoryKey) {
                return !([categoryKey isEqualToString:KEY_OVERDUE]);
            }];
            [self setCategoryNameKeys:[userCategories mutableCopy]];
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        
        NSArray *previousOverdue = [[self allLists] objectForKey:KEY_OVERDUE];
        if ([previousOverdue count] > [overdue count]) {  // we now have fewer overdue items than before, remove cells
            NSMutableSet *itemsToDelete = [NSMutableSet setWithArray:previousOverdue];
            [itemsToDelete minusSet:[NSSet setWithArray:overdue]];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[itemsToDelete count]];
            [itemsToDelete enumerateObjectsUsingBlock:^(MetaListItem *item, BOOL *stop) {
                NSUInteger idx = [previousOverdue indexOfObject:item];
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [[self allLists] setObject:overdue forKey:KEY_OVERDUE];
            [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        } else {
            if ([previousOverdue count] == 0) {
                [[self categoryNameKeys] insertObject:KEY_OVERDUE atIndex:0];
                [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            NSMutableSet *itemsToAdd = [NSMutableSet setWithArray:overdue];
            NSArray *previousOverdue = [[self allLists] objectForKey:KEY_OVERDUE];
            [itemsToAdd minusSet:[NSSet setWithArray:previousOverdue]];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[itemsToAdd count]];
            [itemsToAdd enumerateObjectsUsingBlock:^(MetaListItem *item, BOOL *stop) {
                NSUInteger idx = [overdue indexOfObject:item];
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [[self allLists] setObject:overdue forKey:KEY_OVERDUE];
            [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
         }
    }
    [[self tableView] endUpdates];
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

    ListManagerViewController *vclm = [[ListManagerViewController alloc] initWithManagedObjectContext:[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext]];
    [vclm setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vclm];
    [[navController navigationBar] setTintColor:[UIColor darkGrayColor]];
    [self setListManagerViewController:navController];
    [self presentModalViewController:navController animated:YES];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSwipeActionIndicatorViewsFromCell:cell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *ListCellId = @"ListCell";
    static NSString *ItemCellId = @"ItemCell";
    

    NSManagedObject *obj = [self listObjectAtIndexPath:indexPath];
    BOOL isListCell = ([[[obj entity] name] isEqualToString:LIST_ENTITY_NAME]);
    
    NSString *cellId = (isListCell) ? ListCellId : ItemCellId;
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        UITableViewCellStyle cellStyle = (isListCell) ? UITableViewCellStyleValue1 : UITableViewCellStyleSubtitle;
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId];
    }
    
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setTextColor:[ThemeManager standardTextColor]];
    [[cell textLabel] setHighlightedTextColor:[ThemeManager highlightedTextColor]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setTextColor:[ThemeManager textColorForListDetails]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if (isListCell) {
        MetaList *list = (MetaList *)obj;
        [self configureCell:cell forList:list];
    } else {
        MetaListItem *item = (MetaListItem *)obj;
        [self configureCell:cell forOverdueItem:item];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forList:(MetaList *)list
{
    [[cell textLabel] setText:[list name]];
    if ([list allItemsFinished]) {
        [[cell textLabel] setTextColor:[ThemeManager ghostedTextColor]];
        [[cell detailTextLabel] setText:@"☑"];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:18.0f]];
    } else {
        NSInteger countIncomplete = [list countOfItemsCompleted:NO];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", countIncomplete]];
    }
}

- (void)configureCell:(UITableViewCell *)cell forOverdueItem:(MetaListItem *)item
{
    NSString *timeDueString;

    [[cell detailTextLabel] setFont:[ThemeManager fontForDueDateDetails]];
    [[cell textLabel] setText:[item name]];
    DLog(@"reminder date: %@", [item reminderDate]);    
    NSInteger numDays = date_diff([NSDate date], [item reminderDate]);
    DLog(@"numDays: %d", numDays);
    if (numDays == 0) // due today, show time
        if (has_midnight_timecomponent([item reminderDate]))
            timeDueString = NSLocalizedString(@"Today", nil);
        else
            timeDueString = [NSString stringWithFormat:@"%@ %@", [[item reminderDate] formattedTimeForLocale:[NSLocale currentLocale]], NSLocalizedString(@"Today", nil)];
    else
        timeDueString = [[item reminderDate] formattedDateWithStyle:NSDateFormatterShortStyle];
    if (numDays < 0)
        [[cell detailTextLabel] setTextColor:[ThemeManager textColorForOverdueItems]];
    [[cell detailTextLabel] setText:timeDueString];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIViewController *vcToPush;
    NSManagedObject *listObject = [self listObjectAtIndexPath:indexPath];
    if ([[[listObject entity] name] isEqualToString:LIST_ENTITY_NAME]) {
        MetaList *list = (MetaList *)listObject;
        vcToPush = [[ListItemsViewController alloc] initWithList:list];
        
    } else if ([[[listObject entity] name] isEqualToString:ITEM_ENTITY_NAME]) {
        MetaListItem *item = (MetaListItem *)listObject;
        vcToPush = [[EditListItemViewController alloc] initWithItem:item];
    }
    [[self navigationController] pushViewController:vcToPush animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self categoryNameKeys] objectAtIndex:section];
    if ([title isEqualToString:KEY_OVERDUE])
        title = NSLocalizedString(@"Due Today", nil);
    UIView *headerView = [ThemeManager headerViewTitled:title withDimensions:CGSizeMake(CGRectGetWidth([[self tableView] frame]), [ThemeManager heightForHeaderview])];
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
    NSArray *lists =  [MetaList allListsInContext:[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext]];
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
    NSMutableArray *listKeys = [[[listDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    NSMutableArray *overdue = [[MetaListItem itemsDueOnOrBefore:tomorrow()] mutableCopy];
    if ([overdue count] > 0) {
        [listKeys insertObject:KEY_OVERDUE atIndex:0];
        [listDict setObject:overdue forKey:KEY_OVERDUE];
    }
    [self setCategoryNameKeys:listKeys];
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
    [list save];
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
    //NSError *error;
    //ZAssert([[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext] save:&error], @"Unable to delete list! %@", [error localizedDescription]);
    DLog(@"remaining lists: %d", [[self allLists] count]);
    
}


#pragma mark - list manager view delegate

- (void)dismissListManagerView
{
    [self dismissModalViewControllerAnimated:YES];
    [self setAllLists:[self loadAllLists]];
    [[self tableView] reloadData];
}



@end

