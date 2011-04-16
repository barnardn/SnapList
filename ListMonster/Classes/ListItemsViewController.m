//
//  ListItemsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditListItemViewController.h"
#import "ItemStashViewController.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "ListItemsViewController.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NewListItemViewController.h"

@interface ListItemsViewController()

- (UITableViewCell *)makeCellWithCheckboxButton;
- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(UITableViewCell *)cell;
- (void)editBtnPressed:(id)sender;
- (void)commitAnyChanges;
- (void)rollbackAnyChanges;
- (void)toggleCancelButton:(BOOL)editMode;
- (void)cancelBtnPressed:(id)sender; 
- (void)filterItemsByCheckedState;
- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor;
- (void)configureForEmtpyList:(UITableViewCell *)cell;
- (void)cell:(UITableViewCell *)cell configureForItem:(MetaListItem *)item;
- (void)enabledStateForEditControls:(BOOL)enableState;
- (void)addItem;
- (void)pickFromStash;

@end


@implementation ListItemsViewController

@synthesize allItemsTableView, theList, checkedState, addItemBtn, moreActionsBtn;
@synthesize toolBar,inEditMode, listItems, editBtn;


- (id)initWithList:(MetaList *)aList {
    self = [super initWithNibName:@"ListItemsView" bundle:nil];
    if (!self) return nil;
    [self setTheList:aList];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setEditBtn:nil];
}

- (void)dealloc {
    [listItems release];
    [allItemsTableView release];
    [theList release];
    [checkedState release];
    [addItemBtn release];
    [moreActionsBtn release];
    [toolBar release];
    [editBtn release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:[[self theList] name]];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"edit button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(editBtnPressed:)];
    [self setEditBtn:btn];
    [[self navigationItem] setRightBarButtonItem:[self editBtn]];
    [[self checkedState] setSelectedSegmentIndex:livcSEGMENT_UNCHECKED];
    if ([[self theList] color]) {
        UIColor *backColor = [[[self theList] color] uiColor];
        [[self allItemsTableView] setBackgroundColor:backColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([[[self theList] items] count] == 0) {
        [self enabledStateForEditControls:NO];
        return;
    }
    [self enabledStateForEditControls:YES];
    [self filterItemsByCheckedState];           // TODO: refactor to take sorted list then assign to datasource
    [editItemNavController release], editItemNavController = nil;
    [[self allItemsTableView] reloadData];
}

- (void)enabledStateForEditControls:(BOOL)enableState {
    [[[self navigationItem] rightBarButtonItem] setEnabled:enableState];
    [[self checkedState] setEnabled:enableState];
}


#pragma mark -
#pragma mark Button action

-(IBAction)addItemBtnPressed:(id)sender {
    [self addItem];
}

- (void)addItem {
    NewListItemViewController *eivc = [[NewListItemViewController alloc] initWithList:[self theList]];
    editItemNavController = [[UINavigationController alloc] initWithRootViewController:eivc];
    [self presentModalViewController:editItemNavController animated:YES];
    [eivc release];
}


-(IBAction)moreActionsBtnPressed:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More Actions", @"more actions title") 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel action button")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    if ([[self listItems] count] > 0) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete All", @"delete all action button")];
        [actionSheet setDestructiveButtonIndex:1];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Mark All Complete",@"check all")];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Mark All Incomplete", @"uncheck all")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Pick item from stash", @"stash button")];    
    [actionSheet showFromToolbar:[self toolBar]];
    [actionSheet release];
}

- (void)cancelBtnPressed:(id)sender {
    [self setInEditMode:NO];
    [self rollbackAnyChanges];
    [[self editBtn] setTitle:NSLocalizedString(@"Edit", @"edit button")];
    [self toggleCancelButton:[self inEditMode]];
    [[self allItemsTableView] setEditing:NO animated:YES];
}

- (IBAction)checkedStateValueChanged:(id)sender {
    
    [self filterItemsByCheckedState];
    [[self allItemsTableView] reloadData];
}

- (void)filterItemsByCheckedState {

    NSInteger selectedSegmentIdx = [[self checkedState] selectedSegmentIndex];
    NSPredicate *byCheckedState = [NSPredicate predicateWithFormat:@"self.isChecked == %d", selectedSegmentIdx];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    //TODO: revist this, not the most efficient.
    NSArray *filteredItems = [[self itemsSortedBy:byName] filteredArrayUsingPredicate:byCheckedState];
    if ([filteredItems count] != [[self listItems] count])
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:[self theList]];
    [self setListItems:filteredItems];
}

- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor {
    
    NSArray *allItems = [[[self theList] items] allObjects];
    return [allItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)editBtnPressed:(id)sender {
    
    if ([self inEditMode]) {
        [self setInEditMode:NO];
        [[self editBtn] setTitle:NSLocalizedString(@"Edit", @"edit button")];
        [[self editBtn] setStyle:UIBarButtonItemStylePlain];
        [self commitAnyChanges];
        [self filterItemsByCheckedState];

    } else {
        [self setInEditMode:YES];
        [[self editBtn] setTitle:NSLocalizedString(@"Done", @"done button")];
        [[self editBtn] setStyle:UIBarButtonItemStyleDone];
    }
    [[self allItemsTableView] setEditing:[self inEditMode] animated:YES];
    [self toggleCancelButton:[self inEditMode]];
    
    if (![self inEditMode]) 
        [[self allItemsTableView] reloadData];
}

- (void)toggleCancelButton:(BOOL)editMode {
    
    UIBarButtonItem *cancelBtn = nil;
    if (editMode)
        cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button title") 
                                                     style:UIBarButtonItemStyleDone 
                                                    target:self 
                                                    action:@selector(cancelBtnPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [cancelBtn release];
}

#pragma mark -
#pragma mark Table data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([[[self theList] items] count] == 0)
        return 1;
    return [[self listItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isEmtpyList = ([[[self theList] items] count] == 0);
    if (isEmtpyList) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
        [self configureForEmtpyList:cell];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
        cell = [self makeCellWithCheckboxButton];
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    [self cell:cell configureForItem:item];
    return cell;
}

- (void)configureForEmtpyList:(UITableViewCell *)cell {
    [[cell textLabel] setText:NSLocalizedString(@"Tap '+' to add an item", @"empty list instruction cell text")];
    [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)cell:(UITableViewCell *)cell configureForItem:(MetaListItem *)item {
    
    [[cell textLabel] setText:[item name]];
    [[cell textLabel] setTextColor:[UIColor blackColor]];
    NSNumber *qty = [item quantity];
    NSString *qtyString = ([qty compare:INT_OBJ(0)] == NSOrderedSame) ? @"" : [qty stringValue]; 
    [[cell detailTextLabel] setText:qtyString];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self updateCheckboxButtonForItem:item atCell:cell];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  ([[[self theList] items] count] > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    MetaListItem *deleteItem = [[self listItems] objectAtIndex:[indexPath row]];
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    [moc deleteObject:deleteItem];
    NSMutableArray *updatedItemsList = [[self listItems] mutableCopy];
    [updatedItemsList removeObject:deleteItem];
    [self setListItems:updatedItemsList];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if ([[[self theList] items] count] == 1) {  // last item entire list
        [self enabledStateForEditControls:NO];
        [self editBtnPressed:nil];
    } else {
        [self commitAnyChanges];
    }

}
        
#pragma mark -
#pragma mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[self theList] items] count] == 0) {
        [self addItem];
        return;
    }
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];    
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
    [eivc release];
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (!buttonIndex) return;
    
    if ([[self listItems] count] == 0 && buttonIndex == 1) {
        [self pickFromStash];
        return;
    }
    NSArray *actionSelectors = [NSArray arrayWithObjects:@"deleteAllItems", @"checkAllItems", @"uncheckAllItems", @"pickFromStash",nil];
    [self performSelector:NSSelectorFromString([actionSelectors objectAtIndex:buttonIndex- 1])];
}

- (void)deleteAllItems {
    
    BOOL isOk = [[self theList] deleteAllItems];
    if (!isOk) {
        [ErrorAlert showWithTitle:@"Error Deleting Items" andMessage:@"Items could not be deleted"];
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)checkAllItems {
    
    NSPredicate *uncheckedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 0"];
    [[self theList] setItemsMatching:uncheckedItems toCheckedState:1];
    [self filterItemsByCheckedState];
    [[self allItemsTableView] reloadData];
}

- (void)uncheckAllItems {
    
    NSPredicate *checkedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 1"];
    [[self theList] setItemsMatching:checkedItems toCheckedState:0];
    [self filterItemsByCheckedState];
    [[self allItemsTableView] reloadData];
}

- (void)pickFromStash {
    
    ItemStashViewController *isvc = [[ItemStashViewController alloc] initWithList:[self theList]];
    [self presentModalViewController:isvc animated:YES];
}


#pragma mark -
#pragma mark Cell checkbox methods


- (UITableViewCell *)makeCellWithCheckboxButton {
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] autorelease];
    UIButton *checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBoxBtn.frame = CGRectMake(0.0f, 0.0f, 22.0f, 22.0f);
    [checkBoxBtn addTarget:self action:@selector(checkboxButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell setEditingAccessoryView:checkBoxBtn];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}     

- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(UITableViewCell *)cell {
    
    UIButton *checkBoxButton = (UIButton *)[cell editingAccessoryView];
    NSString *stateImageFile = ([item isComplete]) ? @"radio-on.png" : @"radio-off.png";
    [checkBoxButton setImage:[UIImage imageNamed:stateImageFile] forState:UIControlStateNormal];    
}


- (void)checkboxButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
    
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *indexPath = [[self allItemsTableView] indexPathForCell:cell];
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    BOOL isChecked = [[item isChecked] intValue] == 0;
    NSNumber *checkedValue = (isChecked) ? INT_OBJ(1) : INT_OBJ(0);
    [item setIsChecked:checkedValue];
    [self updateCheckboxButtonForItem:item atCell:cell];
}

#pragma mark -
#pragma mark Commit moc changes

- (void)commitAnyChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    if (![moc hasChanges]) return;
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save changes: %@", [error localizedDescription]);
    }
}

- (void)rollbackAnyChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    if (![moc hasChanges]) return;
    [moc rollback];
}

@end
