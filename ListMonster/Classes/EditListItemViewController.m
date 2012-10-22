//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "datetime_utils.h"
#import "EditListItemViewController.h"
#import "EditMeasureViewController.h"
#import "EditNumberViewController.h"
#import "EditTextViewController.h"
#import "ItemStash.h"
#import "ListMonsterAppDelegate.h"
#import "ListColor.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSNumberExtensions.h"
#import "PriorityViewController.h"
#import "ReminderViewController.h"

@interface EditListItemViewController()

- (void)preparePropertySections;
- (NSString *)listItem:(MetaListItem *)item stringForAttribute:(NSString *)attrName;
- (void)savePendingItemChanges;
- (void)addItemEditsToStash;
- (void)configureAsModalView;
- (void)configureAsChildNavigationView;
- (UITableView *)tableView;
- (void)deleteItem;
- (void)toggleCompletedState;
- (NSString *)priorityNameForValue:(NSNumber *)priorityValue;
- (void)dismissModalViewWithIOS5Compliance;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization

@synthesize theItem, theList, editPropertySections, isModal, delegate;
@synthesize backgroundImageFilename, listItemTableView, toolBar;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem 
{
    self = [super initWithNibName:@"EditListItemView" bundle:nil];
    if (!self) return nil;
    [self setTheList:list];
    [self setTheItem:listItem];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (UITableView *)tableView 
{
    return [self listItemTableView];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
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
    NSString *viewTitle = ([[self theItem] name]) ? [[self theItem] name] :  NSLocalizedString(@"New Item", @"new item title");
    [[self navigationItem] setTitle:viewTitle];
    if ([self isModal])
        [self configureAsModalView];
    else
        [self configureAsChildNavigationView];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main"]]];
    [self preparePropertySections];
}

- (void)configureAsModalView 
{
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button") 
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];    
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
}

- (void)configureAsChildNavigationView 
{
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
}
 
- (void)cancelPressed:(id)sender
{
    skipSaveLogic = YES;
    [[self delegate] editListItemViewController:self didCancelEditOnNewItem:[self theItem]];
    [self dismissModalViewWithIOS5Compliance];
}

- (void)donePressed:(id)sender
{
    [[self delegate] editListItemViewController:self didAddNewItem:[self theItem]];
    [self dismissModalViewWithIOS5Compliance];
}

- (void)dismissModalViewWithIOS5Compliance
{
    if ([[self parentViewController] respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    else
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];    
}

- (void)preparePropertySections 
{    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item", @"title",
                                     @"name", @"attrib", [EditTextViewController class], @"vc", nil];
    NSMutableDictionary *qtyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quantity", @"title",
                                    @"quantity", @"attrib", [EditNumberViewController class], @"vc", nil];
    NSMutableDictionary *reminderDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Reminder", @"title",
                                         @"reminderDate", @"attrib", [ReminderViewController class], @"vc", nil];
    NSMutableDictionary *priorityDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Priority", @"title",
                                         @"priority", @"attrib", [PriorityViewController class], @"vc", nil];
    NSMutableDictionary *unitDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Units", @"title",
                                     @"unitOfMeasure", @"attrib", [EditMeasureViewController class], @"vc", nil];
    NSArray *sects = @[nameDict, priorityDict, qtyDict, unitDict, reminderDict];
    [self setEditPropertySections:sects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    skipSaveLogic = NO;
    if ([[self theItem] isUpdated] || [[self theItem] isInserted])
        [[self tableView] reloadData];
}


- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    [self savePendingItemChanges];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger sectCount = [[self editPropertySections] count];
    return sectCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger sectionIdx = [indexPath section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];

    NSDictionary *sectDict = [self editPropertySections][sectionIdx];
    [[cell textLabel] setText:[sectDict valueForKey:@"title"]];
    NSString *displayValue = [self listItem:[self theItem] stringForAttribute:[sectDict valueForKey:@"attrib"]];
    [[cell detailTextLabel] setText:displayValue];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (NSString *)listItem:(MetaListItem *)item stringForAttribute:(NSString *)attrName 
{
    if (![item valueForKey:attrName]) return @"";
    id attrValue = [item valueForKey:attrName];
    if ([attrName isEqualToString:@"priority"]) {
        NSNumber *priority = attrValue;
        return [self priorityNameForValue:priority];
    } else if ([attrName isEqualToString:@"unitOfMeasure"]) {
        return [NSString stringWithFormat:@"%@ (%@)",
                [[[self theItem] unitOfMeasure] unit],
                [[[self theItem] unitOfMeasure] unitAbbreviation]];
    }
        
    if ([attrValue isKindOfClass:[NSNumber class]]) {
        NSNumber *qty = attrValue;
        return ([qty intValue] > 0) ? [qty stringValue] : @"";
    } else if ([attrValue isKindOfClass:[NSDate class]]) {
        NSDate *rmdr = attrValue;
        return formatted_date(rmdr);
    } else if ([attrValue isKindOfClass:[NSString class]]) {
        NSString *str = attrValue;
        return str;
    }
    return @"";
}

- (NSString *)priorityNameForValue:(NSNumber *)priorityValue {
    switch ([priorityValue intValue]) {
        case -1:
            return NSLocalizedString(@"Low",nil);   
            break;
        case 1:
            return NSLocalizedString(@"High",nil);
            break;
    }
    return NSLocalizedString(@"Normal",nil);
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    skipSaveLogic = YES;
    NSMutableDictionary *sectDict = [self editPropertySections][[indexPath section]];
    Class vcClass = sectDict[@"vc"];
    NSString *viewTitle = sectDict[@"title"];
    UIViewController<EditItemViewProtocol> *vc = [[vcClass alloc ] initWithTitle:viewTitle listItem:[self theItem]];
    [[self navigationController] pushViewController:vc animated:YES];
      // prof rcmd
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark ActionSheet delegate and ActionSheet

-(IBAction)moreActionsBtnPressed:(id)sender {
    
    NSString *markTitle = ([[self theItem] isComplete]) ? NSLocalizedString(@"Mark As Incomplete",nil) : NSLocalizedString(@"Mark As Complete",nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More Actions", @"more actions title") 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel action button")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
                                                    otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:markTitle];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Quick Stash",nil)];
    [actionSheet showFromToolbar:[self toolBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex < 0) return;
    BOOL saveRequired = YES;
    DLog(@"buttonIndex: %d : %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    switch (buttonIndex) {
        case 0:        // delete
            [self deleteItem];
            break;
        case 1:
            saveRequired = NO;
            break;
        case 2:
            [self toggleCompletedState];
            break;	
        case 3:
            [self addItemEditsToStash];
            break;
    }
    if (!saveRequired) return;
    if ([self isModal])
        [self dismissModalViewWithIOS5Compliance];
    else
        [[self navigationController] popViewControllerAnimated:YES];

}

- (void)deleteItem
{
    [[self theList] removeItem:[self theItem]];
    [[[self theList] managedObjectContext] deleteObject:[self theItem]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_UPDATE object:[self theList]];
}

- (void)toggleCompletedState
{
    NSNumber *checkedState = ([[self theItem] isComplete]) ? INT_OBJ(0) : INT_OBJ(1);
    [[self theItem] setIsChecked:checkedState];
}


- (void)addItemEditsToStash 
{
    [self savePendingItemChanges];
    if ([self isModal])
        [[self delegate] editListItemViewController:self didAddNewItem:[self theItem]];
    [ItemStash addToStash:[self theItem]];
}

- (void)savePendingItemChanges 
{
    if (skipSaveLogic) return;
    if (([[self theItem] isDeleted])) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:[self theList]];
    } else if ([[self theItem] isComplete]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:[self theItem]];
    } else {
        NSDictionary *changedProperties = [[self theItem] changedValues];
        if ([changedProperties valueForKey:@"reminderDate"])
            [[self theItem] scheduleReminder];
    }
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save item: %@", [error localizedDescription]);
    }
}
             
             

@end

