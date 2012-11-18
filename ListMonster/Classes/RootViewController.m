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

- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList;
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (void)deleteListEntity:(MetaList *)list;
- (void)showEditViewWithList:(MetaList *)list;
- (NSMutableDictionary *)loadAllLists;
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForList:(MetaList *)list;
- (void)updateIncompleteCountForList:(MetaList *)list;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

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

#pragma mark -
#pragma mark Notification Handlers

// a list property changed (category or name) - reload all lists..
- (void)didReceiveListChangeNotification:(NSNotification *)notification 
{
    [self setAllLists:[self loadAllLists]];
    [[self tableView] reloadData];
    MetaList *scrollToList = [notification object];
    NSIndexPath *scrollToPath = [self indexPathForList:scrollToList];
    [[self tableView] scrollToRowAtIndexPath:scrollToPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self setEditing:NO animated:YES];
}

- (void)didReceiveListCountChangeNotification:(NSNotification *)notification 
{
    MetaList *list = [notification object];
    [self updateIncompleteCountForList:list];
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

#pragma mark -
#pragma mark Table view data source

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellId = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        [self customizeCell:cell atIndexPath:indexPath];
    }
    if ([[self allLists] count] == 0) {
        [[cell textLabel] setText:NSLocalizedString(@"Tap '+' to add a new list", @"add list instruction cell text")];
        [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
        [[cell textLabel] setTextColor:[ThemeManager ghostedTextColor]];
        return cell;
    } else {
        [[cell textLabel] setTextAlignment:UITextAlignmentLeft];
        [[cell textLabel] setTextColor:[ThemeManager standardTextColor]];
    }
    MetaList *listObj = [self listObjectAtIndexPath:indexPath];
    [[cell textLabel] setText:[listObj name]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];    
    return cell;
}

- (void)customizeCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setHighlightedTextColor:[ThemeManager highlightedTextColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
}

- (NSMutableArray *)listAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIdx = [indexPath section];
    NSString *key = [self categoryNameKeys][sectionIdx];
    NSMutableArray *listArr = [self allLists][key];
    return listArr;
}
                                            
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath 
{
    NSMutableArray *listArr = [self listAtIndexPath:indexPath];
    return listArr[[indexPath row]];
}                                     
                                     
- (void)updateCell:(ListCell *)cell forMetaList:(MetaList *)metaList 
{
    [[cell nameLabel] setText:[metaList name]];
    [[cell nameLabel] setTextColor:[[metaList color] uiColor]];
    [[cell countsLabel] setText:@""];
    [[cell categoryLabel] setHidden:YES];
    CGRect nameFrame = [[cell nameLabel] frame];
    CGFloat y = ceil((cell.frame.size.height - nameFrame.size.height) / 2.0f);
    nameFrame.origin.y = y; //13.0f;    
    [[cell nameLabel] setFrame:nameFrame];    
    if ([metaList items] && [[metaList items] count] > 0) {
        NSInteger incompleteCount = [[metaList allIncompletedItems] count];
        NSString *count = [NSString stringWithFormat:@"%d", incompleteCount];    
        [[cell countsLabel] setText:count];
    }    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}

#pragma mark -
#pragma mark Other core data related methods

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
            
- (void)deleteListEntity:(MetaList *)list 
{
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

