//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "BasePopoverNavigationController.h"
#import "DisplayListNoteViewController.h"
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
#import "OverdueItemTableViewCell.h"
#import "RootViewController.h"
#import "TableHeaderView.h"
#import "ThemeManager.h"

#define KEY_OVERDUE     @"--overdue--"

@interface RootViewController() <ListManagerDelegate>

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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Memory management


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
    UIBarButtonItem *addListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addList:)];
    [[self navigationItem] setRightBarButtonItem:addListButton];
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]]];
    
    [self setAllLists:[self loadAllLists]];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ListCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([OverdueItemTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([OverdueItemTableViewCell class])];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    
    NSIndexPath *selectedIndexPath = [[self tableView] indexPathForSelectedRow];
    if (selectedIndexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - button actions


- (void)addList:(id)sender 
{
    ListManagerViewController *vclm = [[ListManagerViewController alloc] initWithManagedObjectContext:[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext]];
    [vclm setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vclm];
    [[navController navigationBar] setTintColor:[UIColor darkGrayColor]];
    [self setListManagerViewController:navController];
    [self presentViewController:navController animated:YES completion:nil];
}


#pragma mark -
#pragma mark Error handler routine

// TODO:  replace this with an actual error handling class!
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error 
{
    DLog(@"%@: %@", message, [error localizedDescription]);
    NSString *alertTitle = NSLocalizedString(@"Error during save", @"save list error title");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", "dismiss button title") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger sectionCount = [[self allLists] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger sectionCount = [[self allLists] count];
    if (sectionCount == 0)
        return 0;
    NSArray *listArr = [self allLists][[self categoryNameKeys][section]];
    return [listArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSManagedObject *obj = [self managedObjectAtIndexPath:indexPath];
    BOOL isListCell = ([[[obj entity] name] isEqualToString:LIST_ENTITY_NAME]);
    if (isListCell)
        return [self tableView:tableView listCellForList:(MetaList *)obj atIndexPath:indexPath];
    else
        return [self tableView:tableView overdueItemCellForItem:(MetaListItem *)obj atIndexPath:indexPath];
}

- (ListCell *)tableView:(UITableView *)tableView listCellForList:(MetaList *)list atIndexPath:(NSIndexPath *)indexPath; {
    
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ListCell class]) forIndexPath:indexPath];
    cell.name = list.name;
    cell.listCompleted = [list allItemsFinished];
    if ([list allItemsFinished]) {
        cell.detailText = @"☑";
    } else {
        NSInteger countIncomplete = [list countOfItemsCompleted:NO];
        cell.detailText = (countIncomplete > 0) ? [@(countIncomplete) stringValue] : @"";
    }
    cell.accessoryType = (list.note.length > 0) ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView overdueItemCellForItem:(MetaListItem *)item atIndexPath:(NSIndexPath *)indexPath {
    OverdueItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OverdueItemTableViewCell class]) forIndexPath:indexPath];
    NSString *timeDueString;
    cell.name = item.name;
    NSInteger numDays = date_diff([NSDate date], [item reminderDate]);
    if (numDays == 0) { // due today, show time
        if (has_midnight_timecomponent([item reminderDate]))
            timeDueString = NSLocalizedString(@"Today", nil);
        else
            timeDueString = [NSString stringWithFormat:@"%@ %@", [[item reminderDate] formattedTimeForLocale:[NSLocale currentLocale]], NSLocalizedString(@"Today", nil)];
    } else {
        timeDueString = [[item reminderDate] formattedDateWithStyle:NSDateFormatterShortStyle];
    }
    cell.detailText = timeDueString;
    cell.overdue = (numDays < 0);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UIViewController *vcToPush;
    NSManagedObject *listObject = [self managedObjectAtIndexPath:indexPath];
    if ([[[listObject entity] name] isEqualToString:LIST_ENTITY_NAME]) {
        MetaList *list = (MetaList *)listObject;
        vcToPush = [[ListItemsViewController alloc] initWithList:list];
        
    } else if ([[[listObject entity] name] isEqualToString:ITEM_ENTITY_NAME]) {
        MetaListItem *item = (MetaListItem *)listObject;
        vcToPush = [[EditListItemViewController alloc] initWithItem:item];
    }
    [[self navigationController] pushViewController:vcToPush animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *obj = [self managedObjectAtIndexPath:indexPath];
    BOOL isListCell = ([[[obj entity] name] isEqualToString:LIST_ENTITY_NAME]);
    if (isListCell) {
        MetaList *list = (MetaList *)obj;
        NSString *title = ([list allItemsFinished]) ? NSLocalizedString(@"Reset", @"reset list items action") : NSLocalizedString(@"Done", @"complete list action title");
        
        UITableViewRowAction *completeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self _completeActionWithList:list atIndexPath:indexPath];
        }];
        completeAction.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0 alpha:1.0];
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self _deleteActionForListAtIndexPath:indexPath];
        }];
        return @[deleteAction, completeAction];
    }
    UITableViewRowAction *completeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Done", @"complete list action title") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self _completeActionWithListItemAtIndexPath:indexPath];
    }];
    completeAction.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0 alpha:1.0];
    return @[completeAction];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self categoryNameKeys] objectAtIndex:section];
    if ([title isEqualToString:KEY_OVERDUE])
        title = NSLocalizedString(@"Due Today", nil);
    UIView *headerView = [ThemeManager headerViewTitled:title withDimensions:CGSizeMake(CGRectGetWidth([[self tableView] frame]), [ThemeManager heightForHeaderview])];
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [ThemeManager heightForHeaderview];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MetaList *list = (MetaList *)[self managedObjectAtIndexPath:indexPath];
    BasePopoverNavigationController *viewController = [BasePopoverNavigationController popoverNavigationControllerWithRootViewController:[[DisplayListNoteViewController alloc] initWithList:list]];
    ListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    viewController.popoverPresentationController.sourceView = cell;
    viewController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMaxX(cell.contentView.frame), CGRectGetMinY(cell.contentView.frame), CGRectGetWidth(cell.frame) - CGRectGetMaxX(cell.contentView.frame), CGRectGetHeight(cell.frame));

    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma mark - list for index path methods

- (NSManagedObject *)managedObjectAtIndexPath:(NSIndexPath *)indexPath
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
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSArray *categories = [ListCategory allCategoriesInContext:moc];
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    NSMutableArray *listKeys = [NSMutableArray array];
    for (ListCategory *category in categories) {
        NSMutableArray *lists = [[category sortedLists] mutableCopy];
        if ([lists count] == 0) continue;
        [listDict setValue:lists forKey:[category name]];
        [listKeys addObject:[category name]];
    }
    NSArray *noCategoryLists = [MetaList allUncategorizedListsInContext:moc];
    if ([noCategoryLists count] > 0) {
        [listDict setValue:[noCategoryLists mutableCopy] forKey:NSLocalizedString(@"Uncategorized", nil)];
        [listKeys addObject:NSLocalizedString(@"Uncategorized", nil)];
    }
    NSMutableArray *overdue = [[MetaListItem itemsDueOnOrBefore:tomorrow()] mutableCopy];
    if ([overdue count] > 0) {
        [listKeys insertObject:KEY_OVERDUE atIndex:0];
        [listDict setObject:overdue forKey:KEY_OVERDUE];
    }
    [self setCategoryNameKeys:listKeys];
    return listDict;
}

#pragma mark - list edit actions

- (void)_completeActionWithList:(MetaList *)list atIndexPath:(NSIndexPath *)indexPath {
    BOOL checkAll =  ([list allItemsFinished]) ? NO : YES;
    [[list itemsSet] enumerateObjectsUsingBlock:^(MetaListItem *item, BOOL *stop) {
        [item setIsComplete:checkAll];
    }];
    [list save];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)_completeActionWithListItemAtIndexPath:(NSIndexPath *)indexPath {
    MetaListItem *item = (MetaListItem *)[self managedObjectAtIndexPath:indexPath];
    [item setIsComplete:YES];
    [item save];
    
    NSIndexPath __block *containingListPath = nil;
    [self.categoryNameKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull categoryName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *lists = self.allLists[categoryName];
        NSInteger rowIdx = [lists indexOfObject:item.list];
        if (rowIdx != NSNotFound) {
            *stop = YES;
            containingListPath = [NSIndexPath indexPathForRow:rowIdx inSection:idx];
        }
    }];
    
    NSMutableArray *itemsList = self.allLists[KEY_OVERDUE];
    [self.tableView beginUpdates];
    if (itemsList.count == 1) {
        [self.categoryNameKeys removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self.allLists removeObjectForKey:KEY_OVERDUE];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [itemsList removeObjectAtIndex:indexPath.row];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView reloadRowsAtIndexPaths:@[containingListPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)_deleteActionForListAtIndexPath:(NSIndexPath *)indexPath {
    
    MetaList *list = (MetaList *)[self managedObjectAtIndexPath:indexPath];
    NSMutableArray *categoryLists = [self listAtIndexPath:indexPath];
    ZAssert([categoryLists containsObject:list], @"Whoa! list of lists does not contain object to delete");
    [categoryLists removeObject:list];
    
    if ([categoryLists count] == 0) {
        NSString *categoryName = [[self categoryNameKeys] objectAtIndex:[indexPath section]];
        [[self categoryNameKeys] removeObject:categoryName];
        [[self allLists] removeObjectForKey:categoryName];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NSError *error;
    NSManagedObjectContext *moc = list.managedObjectContext;
    [moc deleteObject:list];
    ZAssert([moc save:&error], @"Unable to delete object! %@", [error localizedDescription]);
}

#pragma mark - list manager view delegate

- (void)dismissListManagerView {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setAllLists:[self loadAllLists]];
    [[self tableView] reloadData];
}

@end

