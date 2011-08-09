//
//  RootViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Alerts.h"
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

@interface RootViewController()

- (void)updateCell:(UITableViewCell *)cell forMetaList:(MetaList *)metaList;
- (void)displayErrorMessage:(NSString *)message forError:(NSError *)error;
- (void)deleteListEntity:(MetaList *)list;
- (void)showEditViewWithList:(MetaList *)list;
- (UITableViewCell *)tableView:(UITableView *)tableView overdueItemCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSMutableDictionary *)loadAllLists;
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForList:(MetaList *)list;
- (NSMutableArray *)loadOverdueItems;
- (void)updateIncompleteCountForList:(MetaList *)list;

@end

@implementation RootViewController

@synthesize allLists, categoryNameKeys, overdueItems;

#pragma mark -
#pragma mark Initializers

- (id)init 
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style 
{
    return [self init];
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

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [allLists release];
    [categoryNameKeys release];
    [edListNav release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                            target:self 
                                                                            action:@selector(addList:)];
    [[self navigationItem] setLeftBarButtonItem:addBtn];
    [addBtn release];
    [[self navigationItem] setTitle:NSLocalizedString(@"Snap Lists", "@root view title")];
    [self setAllLists:[self loadAllLists]];
    [self setOverdueItems:[self loadOverdueItems]];
    [[self tableView] reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveCompletedItemNotification:) 
                                                 name:NOTICE_LIST_COUNTS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveListChangeNotification:) 
                                                 name:NOTICE_LIST_UPDATE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveOverdueReminderNotification:) 
                                                 name:NOTICE_OVERDUE_ITEM 
                                               object:nil];
}

- (void)setEditing:(BOOL)inEditMode animated:(BOOL)animated 
{
    [super setEditing:inEditMode animated:animated];
    BOOL enableEditButton = ([[self allLists] count] > 0);
    [[[self navigationItem] rightBarButtonItem] setEnabled:enableEditButton];
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
    [evc release];
}

#pragma mark -
#pragma mark Notification Handlers

- (void)didReceiveListChangeNotification:(NSNotification *)notification 
{
    [self setAllLists:[self loadAllLists]];
    [self setOverdueItems:[self loadOverdueItems]];
    [[self tableView] reloadData];
    MetaList *scrollToList = [notification object];
    NSIndexPath *scrollToPath = [self indexPathForList:scrollToList];
    [[self tableView] scrollToRowAtIndexPath:scrollToPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self setEditing:NO animated:YES];
}

- (void)didReceiveCompletedItemNotification:(NSNotification *)notification 
{
    NSManagedObject *managedObj = [notification object];
    if ([[[managedObj entity] name] isEqualToString:@"MetaList"]) {
        MetaList *l = (MetaList *)managedObj;
        [self updateIncompleteCountForList:l];
        return;
    }
    MetaListItem *item = (MetaListItem *)managedObj;
    NSUInteger itemIndex = [[self overdueItems] indexOfObject:item];
    if ([[self overdueItems] count] && itemIndex != NSNotFound && [item isComplete]) {
        DLog(@"removing overdue item: %@", [item name]);
        [[self overdueItems] removeObjectAtIndex:itemIndex];
        if ([[self overdueItems] count] == 0) {
            NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
            [[self tableView] deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
            [self setOverdueItems:nil];
        } else {
            NSIndexPath *itemIdxPath = [NSIndexPath indexPathForRow:itemIndex inSection:0];
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:itemIdxPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self updateIncompleteCountForList:[item list]];
}

- (void)didReceiveOverdueReminderNotification:(NSNotification *)notification
{
    [self setOverdueItems:[self loadOverdueItems]];
    [[self tableView] reloadData];
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
    if ([[self overdueItems] count] > 0)
        sectionIdx++;
    NSArray *itemsForCategory = [[self allLists] objectForKey:key];
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

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [edListNav release], edListNav = nil;
    BOOL enableEditButton = ([[self allLists] count] > 0);
    [[[self navigationItem] rightBarButtonItem] setEnabled:enableEditButton];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger sectionCount = [[self allLists] count];
    if ([[self overdueItems] count] > 0)
        sectionCount++;
    return (sectionCount == 0) ? 1 : sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    BOOL haveOverdueItems = ([[self overdueItems] count] > 0);
    if (section == 0 && haveOverdueItems)
        return [[self overdueItems] count];
    
    NSInteger sectionCount = [[self allLists] count];
    if (sectionCount == 0)
        return 1;
    if (haveOverdueItems) section--;
    NSArray *listArr = [[self allLists] objectForKey:[[self categoryNameKeys] objectAtIndex:section]];
    return [listArr count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    BOOL haveOverdueItems = ([[self overdueItems] count] > 0);
    if ((section == 0) && haveOverdueItems)
        return NSLocalizedString(@"Reminders", nil);
    
    if ([[self allLists] count] == 0)
        return @"";
    if (haveOverdueItems)
        section--;
    return [[self categoryNameKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellId = @"ListCell";
    static NSString *EmptyCellId = @"EmptyCell";
    
    if ([[self allLists] count] == 0) {
        UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:EmptyCellId];
        if (!emptyCell)
            emptyCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCellId] autorelease];
        [[emptyCell textLabel] setText:NSLocalizedString(@"Tap '+' to add a new list", @"add list instruction cell text")];
        [[emptyCell textLabel] setTextAlignment:UITextAlignmentCenter];
        [[emptyCell textLabel] setTextColor:[UIColor lightGrayColor]];
        [emptyCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return emptyCell;
    }
    if ([self overdueItems] && [indexPath section] == 0) 
        return [self tableView:tableView overdueItemCellForRowAtIndexPath:indexPath];
    
    ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil];
        cell = (ListCell *)[nib objectAtIndex:0];
    }
    MetaList *listObj = [self listObjectAtIndexPath:indexPath];
    [self updateCell:cell forMetaList:listObj];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView overdueItemCellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *ItemCellID = @"ItemCell";
    NSInteger rowIdx = [indexPath row];
    MetaListItem *item = [[self overdueItems] objectAtIndex:rowIdx];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ItemCellID];
    if (!cell) 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ItemCellID] autorelease];
    [[cell textLabel] setText:[item name]];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
    NSInteger dayDiff = date_diff([NSDate date], [item reminderDate]);
    NSString *dateFmt = nil;
    [cell setBackgroundColor:[UIColor colorWithRed:1.0 green:0.36 blue:0.36 alpha:1.0]];
    if (dayDiff == 0) {
        if (has_midnight_timecomponent([item reminderDate]))
            dateFmt = @"'Today'";
        else
            dateFmt = @"h:mm a";
        [cell setBackgroundColor:[UIColor colorWithRed:0.36 green:1.0 blue:0.36 alpha:1.0]];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
    }
    else if (dayDiff == -1)
        dateFmt = @"'Yesterday'";
    else if (dayDiff < -1)
        dateFmt = @"MMM d";
    [[cell detailTextLabel] setText:formatted_date_with_format_string([item reminderDate], dateFmt)];
    [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

         
- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger sectionIdx = [indexPath section];
    if ([[self overdueItems] count] > 0)
        sectionIdx--;
    
    NSString *key = [[self categoryNameKeys] objectAtIndex:sectionIdx];
    NSMutableArray *listArr = [[self allLists] objectForKey:key];
    return [listArr objectAtIndex:[indexPath row]];
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
    if (![self overdueItems])
        return ([[self allLists] count] > 0);
    else
        return ([indexPath section] > 0);       // don't allow edits on the overdue items

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BOOL haveOverdueItems = ([[self overdueItems] count] > 0);
    if (haveOverdueItems && [indexPath section] == 0) return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger sectionIdx = (haveOverdueItems) ? [indexPath section] - 1 : [indexPath section];
        NSString *key = [[self categoryNameKeys] objectAtIndex:sectionIdx];
        NSMutableArray *listArr = [[self allLists] objectForKey:key];
        MetaList *dl = [listArr objectAtIndex:[indexPath row]];
        [self deleteListEntity:dl];
        [listArr removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([listArr count] == 0) {
            [[self allLists] removeObjectForKey:key];
            NSArray *catKeys = [[[self allLists] allKeys] sortedArrayUsingSelector:@selector(compare:)];
            [self setCategoryNameKeys:catKeys];
        }
        if (([[self allLists] count] == 0) && ([self isEditing]))
            [self setEditing:NO animated:YES];
        [tableView reloadData];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BOOL haveOverdueItems = ([[self overdueItems] count] > 0);
    if (haveOverdueItems && [indexPath section] == 0) {
        MetaListItem *listItem = [[self overdueItems] objectAtIndex:[indexPath row]];
        EditListItemViewController *elivc = [[EditListItemViewController alloc] initWithList:[listItem list] editItem:listItem];
        [[self navigationController] pushViewController:elivc animated:YES];
        [elivc release];
        return;
    }
    if ([[self allLists] count] == 0) {
        [self addList:nil];
        return ;
    }
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    ListItemsViewController *livc = [[ListItemsViewController alloc] initWithList:list];
    [[self navigationController] pushViewController:livc animated:YES];
    [livc release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    [self showEditViewWithList:list];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 54.0f;
}

#pragma mark -
#pragma mark Other core data related methods

- (NSMutableArray *)loadOverdueItems
{
    NSSortDescriptor *byName = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSSortDescriptor *byDate = [[[NSSortDescriptor alloc] initWithKey:@"reminderDate" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:byDate,byName,nil];
    NSDate *tam = today_at_midnight();
    NSPredicate *beforeTomorrow = [NSPredicate predicateWithFormat:@"reminderDate <= %@ AND isChecked == 0", [tam dateByAddingTimeInterval:SECONDS_PER_DAY]];
    NSArray *overdue = [[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"MetaListItem" sortDescriptors:sortDescriptors filteredBy:beforeTomorrow];
    return ([overdue count] == 0) ? nil : [[overdue mutableCopy] autorelease];
}

- (NSMutableDictionary *)loadAllLists 
{
    NSSortDescriptor *byName = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSSortDescriptor *byCategory = [[[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:byCategory, byName, nil];
    NSArray *lists =  [[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"MetaList" sortDescriptors:sortDescriptors];
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    for (MetaList *l in lists) {
        NSString *key = ([l category]) ? [[l category] name] : @"";
        if (![listDict objectForKey:key])
            [listDict setObject:[NSMutableArray arrayWithObject:l] forKey:key];
        else {
            NSMutableArray *listArr = [listDict objectForKey:key];
            [listArr addObject:l];
        }
    }
    [self setCategoryNameKeys:[[listDict allKeys] sortedArrayUsingSelector:@selector(compare:)]];
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

