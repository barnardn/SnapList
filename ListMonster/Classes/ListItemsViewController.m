//
//  ListItemsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "DisplayListNoteViewController.h"
#import "EditListItemViewController.h"
#import "ItemStashViewController.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "ListItemsViewController.h"
#import "ListItemCell.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"

@interface ListItemsViewController()

- (ListItemCell *)makeItemCell;
- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(ListItemCell *)cell;
- (void)editBtnPressed:(id)sender;
- (void)commitAnyChanges;
- (void)rollbackAnyChanges;
- (void)toggleCancelButton:(BOOL)editMode;
- (void)cancelBtnPressed:(id)sender; 
- (void)filterItemsByCheckedState;
- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor;
- (void)configureForEmtpyList:(UITableViewCell *)cell;
- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item;
- (void)enabledStateForEditControls:(BOOL)enableState;
- (void)addItem;
- (void)pickFromStash;
- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateCheckedStateCountWithFilteredItems:(NSArray *)filteredItems usingSelectedIndex:(NSInteger )selectedIndex;
- (void)enableToolbarItems:(BOOL)enabled;

@end


@implementation ListItemsViewController

@synthesize allItemsTableView, theList, checkedState, addItemBtn, moreActionsBtn;
@synthesize toolBar,inEditMode, listItems, editBtn, backgroundImageFilename;

- (id)initWithList:(MetaList *)aList {
    self = [super initWithNibName:@"ListItemsView" bundle:nil];
    if (!self) return nil;
    [self setTheList:aList];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_LIST_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveListChangeNotification:) name:NOTICE_LIST_UPDATE object:nil];

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [backgroundImageFilename release];
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
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"edit button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(editBtnPressed:)];
    [self setEditBtn:btn];
    [btn release];  // prof rcmd
    [[self navigationItem] setRightBarButtonItem:[self editBtn]];
    [[self checkedState] setSelectedSegmentIndex:livcSEGMENT_UNCHECKED];
    if ([[self theList] color]) {
        NSString *bgImagePath = [NSString stringWithFormat:@"Backgrounds/%@", [[[self theList] color] swatchFilename]];
        [self setBackgroundImageFilename:bgImagePath];
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgImagePath]];
        [[self allItemsTableView] setBackgroundView:bgView];
        [bgView release];
    }
    [[self allItemsTableView] setAllowsSelectionDuringEditing:YES];
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

-(IBAction)addItemBtnPressed:(id)sender 
{
    [self addItem];
}

- (void)addItem 
{
    MetaListItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"MetaListItem" inManagedObjectContext:[[self theList] managedObjectContext]];
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:newItem];
    [eivc setIsModal:YES];
    [eivc setDelegate:self];
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
        if ([[self checkedState] selectedSegmentIndex] == livcSEGMENT_CHECKED)
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Mark All Incomplete", @"uncheck all")];
        else
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Mark All Complete",@"check all")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Pick item from stash", @"stash button")];    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"View List Note", nil)];
    [actionSheet showFromToolbar:[self toolBar]];
    [actionSheet release];
}

- (void)cancelBtnPressed:(id)sender {
    [self setInEditMode:NO];
    [self rollbackAnyChanges];
    [[self editBtn] setTitle:NSLocalizedString(@"Select", @"edit button")];
    [self toggleCancelButton:[self inEditMode]];
    for (NSIndexPath *p in [[self allItemsTableView] indexPathsForVisibleRows]) {
        MetaListItem *item = [[self listItems] objectAtIndex:[p row]];
        ListItemCell *cell = (ListItemCell *)[[self allItemsTableView] cellForRowAtIndexPath:p];
        if ([item isComplete])
            [cell setEditModeImage:[UIImage imageNamed:@"radio-on"]];
        else
            [cell setEditModeImage:[UIImage imageNamed:@"radio-off"]];
    }
    [[self allItemsTableView] setEditing:NO animated:YES];
    [self enableToolbarItems:YES];
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
    NSMutableArray *filteredItems = [[[self itemsSortedBy:byName] filteredArrayUsingPredicate:byCheckedState] mutableCopy];
    [self setListItems:filteredItems];
    [self updateCheckedStateCountWithFilteredItems:filteredItems usingSelectedIndex:selectedSegmentIdx];
    [filteredItems release]; 
}

- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor {
    
    NSArray *allItems = [[[self theList] items] allObjects];
    NSSortDescriptor *bySortOrder = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    return [allItems sortedArrayUsingDescriptors:[NSArray arrayWithObjects:bySortOrder, sortDescriptor, nil]];
}

- (void)updateCheckedStateCountWithFilteredItems:(NSArray *)filteredItems usingSelectedIndex:(NSInteger )selectedIndex
{
    UISegmentedControl *checkedStateSegCtrl = (UISegmentedControl *)[[self toolBar] viewWithTag:livcSEGMENT_VIEW_TAG];
    int nComplete, nIncomplete;
    if (livcSEGMENT_CHECKED == selectedIndex) {
        nComplete = [filteredItems count];
        nIncomplete = [[[self theList] items] count] - nComplete;
    } else {
        nIncomplete = [filteredItems count];
        nComplete = [[[self theList] items] count] - nIncomplete;
    }
    [checkedStateSegCtrl setTitle:[NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"Incomplete",nil),nIncomplete] 
                forSegmentAtIndex:livcSEGMENT_UNCHECKED];
    [checkedStateSegCtrl setTitle:[NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"Complete", nil),nComplete] 
                forSegmentAtIndex:livcSEGMENT_CHECKED];
}

- (void)editBtnPressed:(id)sender 
{
    if ([self inEditMode]) {
        [self setInEditMode:NO];
        [[self editBtn] setTitle:NSLocalizedString(@"Select", @"edit button")];
        [[self editBtn] setStyle:UIBarButtonItemStylePlain];
        [self commitAnyChanges];
        [self filterItemsByCheckedState];
        [self enableToolbarItems:YES];

    } else {
        [self setInEditMode:YES];
        [[self editBtn] setTitle:NSLocalizedString(@"Done", @"done button")];
        [[self editBtn] setStyle:UIBarButtonItemStyleDone];
        [self enableToolbarItems:NO];
    }
    [[self allItemsTableView] setEditing:[self inEditMode] animated:YES];
    [self toggleCancelButton:[self inEditMode]];
    
    if (![self inEditMode]) 
        [[self allItemsTableView] reloadData];
}

- (void)enableToolbarItems:(BOOL)enabled
{
    [[self checkedState] setEnabled:enabled];
    [[self addItemBtn] setEnabled:enabled];
    [[self moreActionsBtn] setEnabled:enabled];
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
#pragma mark ListItemsViewControllerProtocol method 

-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didCancelEditOnNewItem:(MetaListItem *)item
{
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    [moc deleteObject:item];
    DLog(@"item cancel item count: %d", [[[self theList] items] count]);
}

-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didAddNewItem:(MetaListItem *)item
{
    [[self theList] addItem:item];
    [item release];  // maybe...
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BOOL isEmtpyList = ([[[self theList] items] count] == 0);
    if (isEmtpyList) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        if (!cell)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"] autorelease];
        [self configureForEmtpyList:cell];
        return cell;
    }
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    ListItemCell *cell = (ListItemCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
        cell = [self makeItemCell];
    [self configureCell:cell withItem:item];
    return cell;
}

- (void)configureForEmtpyList:(UITableViewCell *)cell 
{
    [[cell textLabel] setText:NSLocalizedString(@"Tap '+' to add an item", @"empty list instruction cell text")];
    [[cell textLabel] setTextColor:[UIColor lightGrayColor]];
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configureCell:(ListItemCell *)cell withItem:(MetaListItem *)item
{    
    NSString *stateImageFile = ([item isComplete]) ? @"radio-on" : @"radio-off";
    UIImage *radioImage = [UIImage imageNamed:stateImageFile];
    [cell setEditModeImage:radioImage];
    UIImage *priorityImage = nil;
    if (![[item priority] isEqualToNumber:INT_OBJ(0)]) {
        NSString *priorityName = [item priorityName];
        priorityImage = [UIImage imageNamed:priorityName];
    }
    [cell setNormalModeImage:priorityImage];    
    if ([self inEditMode]) {
        [[cell imageView] setImage:radioImage];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [[cell imageView] setImage:priorityImage];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } 
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    ZAssert(lbl != nil, @"Whoa! missing name label in configureCell:withItem:");
    [lbl setText:[item name]];
    NSNumber *qty = [item quantity];
    NSString *qtyString = ([qty compare:INT_OBJ(0)] == NSOrderedSame) ? @"" : [qty stringValue]; 
    NSString *unitString = ([item unitOfMeasure]) ? [[item unitOfMeasure] unitAbbreviation] : @"";
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@%@", qtyString, unitString]];

}

- (ListItemCell *)makeItemCell
{
    ListItemCell *cell = [[[ListItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] autorelease]; 
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setLineBreakMode:UILineBreakModeWordWrap];
    [lbl setMinimumFontSize:14.0f];
    [lbl setNumberOfLines:0];
    [lbl setFont:[UIFont systemFontOfSize:14.0f]];
    [lbl setTag:1];
    [[cell contentView] addSubview:lbl];
    [lbl release];
    return cell;
}  


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  NO;
    //return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    MetaListItem *deleteItem = [[self listItems] objectAtIndex:[indexPath row]];
    [[self listItems] removeObject:deleteItem];
    [[[self theList] managedObjectContext] deleteObject:deleteItem];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];    
    [[self theList] removeItem:deleteItem];
    if ([[[self theList] items] count] == 0) {  // just deleted the last item
        [self enabledStateForEditControls:NO];
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ipath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self commitAnyChanges];
}
   

#pragma mark -
#pragma mark TableView delegate methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{    
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    NSString *text = [item name];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 34.0f);
    return height + (CELL_CONTENT_MARGIN * 2);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[self theList] items] count] == 0) {
        [self addItem];
    } else if ([self inEditMode]) {
        [self itemSelectedAtIndexPath:indexPath];
    } else {
        MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];    
        EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:item];
        [[self navigationController] pushViewController:eivc animated:YES];
        [eivc release];
    }
}

- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath 
{    
    ListItemCell *cell = (ListItemCell *)[[self allItemsTableView] cellForRowAtIndexPath:indexPath];
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    NSNumber *checkedValue = ([item isComplete]) ? INT_OBJ(0) : INT_OBJ(1);  // reverse of the current state
    [item setIsChecked:checkedValue];
    [self updateCheckboxButtonForItem:item atCell:cell];
}

- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(ListItemCell *)cell 
{    
    NSString *stateImageFile = ([item isComplete]) ? @"radio-on" : @"radio-off";
    UIImage *radioStateImage = [UIImage imageNamed:stateImageFile];
    [[cell imageView] setImage:radioStateImage];
    [cell setEditModeImage:radioStateImage];
}


#pragma mark - list changed notification methods

- (void)didReceiveListChangeNotification:(NSNotification *)notification
{
    [[self allItemsTableView] reloadData];
}

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (!buttonIndex) return;
    
    if ([[self listItems] count] == 0 && buttonIndex == 1) {
        [self pickFromStash];
        return;
    }
    NSString *checkStateSelector = nil;
    if (livcSEGMENT_CHECKED == [[self checkedState] selectedSegmentIndex])
        checkStateSelector = @"uncheckAllItems";
    else
        checkStateSelector = @"checkAllItems";
    NSArray *actionSelectors = [NSArray arrayWithObjects:@"deleteAllItems", checkStateSelector, 
                                @"pickFromStash",@"showListNote", nil];
    [self performSelector:NSSelectorFromString([actionSelectors objectAtIndex:buttonIndex- 1])];
}

- (void)deleteAllItems 
{
    BOOL isOk = [[self theList] deleteAllItems];
    if (!isOk) {
        [ErrorAlert showWithTitle:@"Error Deleting Items" andMessage:@"Items could not be deleted"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:[self theList]];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)checkAllItems 
{    
    NSPredicate *uncheckedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 0"];
    [[self theList] setItemsMatching:uncheckedItems toCheckedState:1];
    [self filterItemsByCheckedState];
    [[self allItemsTableView] reloadData];
}

- (void)uncheckAllItems 
{
    NSPredicate *checkedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 1"];
    [[self theList] setItemsMatching:checkedItems toCheckedState:0];
    [self filterItemsByCheckedState];
    [[self allItemsTableView] reloadData];
}

- (void)pickFromStash 
{
    ItemStashViewController *isvc = [[ItemStashViewController alloc] initWithList:[self theList]];
    [self presentModalViewController:isvc animated:YES];
    [isvc release];
}

- (void)showListNote 
{
    DisplayListNoteViewController *noteVc = [[DisplayListNoteViewController alloc] initWithList:[self theList]];
    [self presentModalViewController:noteVc animated:YES];
    [noteVc release];
}

#pragma mark -
#pragma mark Commit moc changes

- (void)commitAnyChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    if (![moc hasChanges]) return;
    NSPredicate *itemsForCountUpdate = [NSPredicate predicateWithFormat:@"isChecked == YES OR isDeleted == YES"];
    NSSet *filteredSet = [[[self theList] items] filteredSetUsingPredicate:itemsForCountUpdate];
    if ([filteredSet count] > 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:[self theList]];
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
