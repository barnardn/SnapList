//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "HelpViewController.h"
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

@interface RootViewController() <ListManagerDelegate, UIAlertViewDelegate, HelpViewDelegate>

- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (NSMutableDictionary *)loadAllLists;
- (NSManagedObject *)managedObjectAtIndexPath:(NSIndexPath *)indexPath;

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
    UIBarButtonItem *btnListMgr = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"399-list1"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(addList:)];
    
    UIBarButtonItem *btnHelp = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"451-help-symbol2"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnHelpTapped:)];
    [[self navigationItem] setLeftBarButtonItem:btnListMgr];
    [[self navigationItem] setRightBarButtonItem:btnHelp];
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]]];
    
    [self setAllLists:[self loadAllLists]];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ListCell class])];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[[self navigationController] navigationBar] setTintColor:nil];
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

- (IBAction)btnHelpTapped:(UIBarButtonItem *)sender
{
    HelpViewController *vcHelp = [[HelpViewController alloc] init];
    [vcHelp setDelegate:self];
    [self presentViewController:vcHelp animated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSwipeActionIndicatorViewsFromCell:cell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSManagedObject *obj = [self managedObjectAtIndexPath:indexPath];
    BOOL isListCell = ([[[obj entity] name] isEqualToString:LIST_ENTITY_NAME]);
    if (isListCell)
        return [self tableView:tableView listCellForList:(MetaList *)obj atIndexPath:indexPath];
    else
        return [self tableView:tableView overdueItemCellForItem:(MetaListItem *)obj];
}

- (ListCell *)tableView:(UITableView *)tableView listCellForList:(MetaList *)list atIndexPath:(NSIndexPath *)indexPath; {
    
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ListCell class]) forIndexPath:indexPath];
    cell.name = list.name;
    cell.listCompleted = [list allItemsFinished];
    if ([list allItemsFinished]) {
        [[cell detailTextLabel] setText:@"☑"];
    } else {
        NSInteger countIncomplete = [list countOfItemsCompleted:NO];
        cell.detailText = (countIncomplete > 0) ? [@(countIncomplete) stringValue] : @"";
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView overdueItemCellForItem:(MetaListItem *)item
{
    static NSString *CellId = @"OverudeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
    }
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setTextColor:[ThemeManager standardTextColor]];
    [[cell textLabel] setHighlightedTextColor:[ThemeManager highlightedTextColor]];
    [[cell detailTextLabel] setTextColor:[ThemeManager textColorForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForDueDateDetails]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];    
    
    NSString *timeDueString;
    [[cell textLabel] setText:[item name]];
    DLog(@"reminder date: %@", [item reminderDate]);
    NSInteger numDays = date_diff([NSDate date], [item reminderDate]);
    DLog(@"numDays: %@", @(numDays));
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

#pragma mark - list for index path methods

- (MetaList *)managedObjectAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - swipe to edit cell view controller overrides

- (void)rightSwipeUpdateAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *mo = [self managedObjectAtIndexPath:indexPath];
    if ([mo isKindOfClass:[MetaListItem class]]) {
        MetaListItem *item = (MetaListItem *)mo;
        [item setIsComplete:YES];
        [item save];
        return;
    }
    MetaList *list = (MetaList *)mo;
    BOOL checkAll =  ([list allItemsFinished]) ? NO : YES;
    [[list itemsSet] enumerateObjectsUsingBlock:^(MetaListItem *item, BOOL *stop) {
        [item setIsComplete:checkAll];
    }];
    [list save];
}

- (NSString *)rightSwipeActionTitleForItemItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *mo = [self managedObjectAtIndexPath:indexPath];
    if ([mo isKindOfClass:[MetaListItem class]])
        return NSLocalizedString(@"Complete!", nil);
    MetaList *list = (MetaList *)mo;
    return ([list allItemsFinished]) ? @"List Reset" : @"All Done!";
}

- (BOOL)rightSwipeShouldDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *mo = [self managedObjectAtIndexPath:indexPath];
    return ([mo isKindOfClass:[MetaListItem class]]);
}

- (void)rightSwipeRemoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *mo = [self managedObjectAtIndexPath:indexPath];
    if ([mo isKindOfClass:[MetaList class]]) return;
    [self removeManagedObjectAtIndexPath:indexPath];
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeManagedObjectAtIndexPath:indexPath];
}

- (void)removeManagedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *mo = [self managedObjectAtIndexPath:indexPath];
    NSMutableArray *categoryLists = [self listAtIndexPath:indexPath];
    ZAssert([categoryLists containsObject:mo], @"Whoa! list of lists does not contain object to delete");
    [categoryLists removeObject:mo];
    if ([categoryLists count] == 0) {
        NSString *categoryName = [[self categoryNameKeys] objectAtIndex:[indexPath section]];
        [[self categoryNameKeys] removeObject:categoryName];
        [[self allLists] removeObjectForKey:categoryName];
    }
    NSError *error;
    if ([mo isKindOfClass:[MetaList class]]) {
        [[mo managedObjectContext] deleteObject:mo];
    } else {
        MetaListItem *item = (MetaListItem *)mo;
        NSInteger order = [[[item list] items] count];
        [item setOrderValue:(order + 1)];
        [item setIsComplete:YES];
    }
    ZAssert([[mo managedObjectContext] save:&error], @"Unable to delete object! %@", [error localizedDescription]);
}


#pragma mark - list manager view delegate

- (void)dismissListManagerView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setAllLists:[self loadAllLists]];
    [[self tableView] reloadData];
}

#pragma mark - help view controller delegate

- (void)dismissHelpView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

