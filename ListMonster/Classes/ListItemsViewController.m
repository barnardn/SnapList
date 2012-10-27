//
//  ListItemsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <objc/objc-runtime.h>

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
#import "ThemeManager.h"



#define ROW_HEIGHT  44.0f
#define EDITCELL_TEXTVIEW_HMARGIN   10.0f
#define EDITCELL_TEXTVIEW_VMARGIN   5.0f
#define CELL_VMARGIN                25.0f
#define CELL_CONTENT_WIDTH          245.0f
#define TAG_TEXTVIEW                1001

static char editCellKey;

@interface ListItemsViewController()

- (ListItemCell *)makeItemCell;
- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(ListItemCell *)cell;
- (void)editBtnPressed:(id)sender;
- (void)commitAnyChanges;
- (void)rollbackAnyChanges;
- (void)toggleCancelButton:(BOOL)editMode;
// - (void)cancelBtnPressed:(id)sender;
- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor;
- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item;
- (void)pickFromStash;
- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateCheckedStateCountWithFilteredItems:(NSArray *)filteredItems usingSelectedIndex:(NSInteger )selectedIndex;
- (void)enableToolbarItems:(BOOL)enabled;

@property(nonatomic,strong) NSMutableArray *listItems;

@end


@implementation ListItemsViewController

@synthesize theList, checkedState, addItemBtn, moreActionsBtn;
@synthesize toolBar,inEditMode, editBtn;

- (id)initWithList:(MetaList *)aList
{
    self = [super init];
    if (!self) return nil;
    [self setTheList:aList];
    _listItems = [NSMutableArray arrayWithArray:[[aList items] allObjects]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_LIST_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveListChangeNotification:) name:NOTICE_LIST_UPDATE object:nil];

    return self;
}

- (NSString *)nibName
{
    return @"ListItemsView";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setEditBtn:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[[self theList] name]];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];
    
    /*
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"edit button") 
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self 
                                                               action:@selector(editBtnPressed:)];
    */
    [self setEditBtn:btn];
      // prof rcmd
    [[self navigationItem] setRightBarButtonItem:[self editBtn]];
    [[self checkedState] setSelectedSegmentIndex:livcSEGMENT_UNCHECKED];
    [[self tableView] setAllowsSelectionDuringEditing:YES];
    //[[self tableView] setRowHeight:ROW_HEIGHT];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //[self filterItemsByCheckedState];           // TODO: refactor to take sorted list then assign to datasource
    editItemNavController = nil;
    [[self tableView] reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Button action

-(IBAction)addItemBtnPressed:(id)sender 
{
    // OBSOLETE METHOD
//    [self addItem];
}


- (void)addButtonTapped:(UIBarButtonItem *)barBtn
{
    MetaListItem *item = [MetaListItem insertInManagedObjectContext:[[self theList] managedObjectContext]];
    [[self tableView] beginUpdates];
    [[self listItems] insertObject:item atIndex:0];
    [[self tableView] insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
}


-(IBAction)moreActionsBtnPressed:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More Actions", @"more actions title") 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel action button")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    if ([[[self theList] items] count] > 0) {
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
}

- (IBAction)checkedStateValueChanged:(id)sender {
    
//    [self filterItemsByCheckedState];
    [[self tableView] reloadData];
}

/*
- (void)filterItemsByCheckedState {

    NSInteger selectedSegmentIdx = [[self checkedState] selectedSegmentIndex];
    NSPredicate *byCheckedState = [NSPredicate predicateWithFormat:@"self.isChecked == %d", selectedSegmentIdx];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];    
    //TODO: revist this, not the most efficient.
    NSMutableArray *filteredItems = [[[self itemsSortedBy:byName] filteredArrayUsingPredicate:byCheckedState] mutableCopy];
    [self setListItems:filteredItems];
    [self updateCheckedStateCountWithFilteredItems:filteredItems usingSelectedIndex:selectedSegmentIdx];
}
*/
 
 
- (NSArray *)itemsSortedBy:(NSSortDescriptor *)sortDescriptor
{
    
    NSArray *allItems = [[[self theList] items] allObjects];
    NSSortDescriptor *bySortOrder = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    return [allItems sortedArrayUsingDescriptors:@[bySortOrder, sortDescriptor]];
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
        //[self filterItemsByCheckedState];
        [self enableToolbarItems:YES];

    } else {
        [self setInEditMode:YES];
        [[self editBtn] setTitle:NSLocalizedString(@"Done", @"done button")];
        [[self editBtn] setStyle:UIBarButtonItemStyleDone];
        [self enableToolbarItems:NO];
    }
    [[self tableView] setEditing:[self inEditMode] animated:YES];
    [self toggleCancelButton:[self inEditMode]];
    
    if (![self inEditMode]) 
        [[self tableView] reloadData];
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
      // maybe...
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MetaListItem *item = [self listItems][[indexPath row]];
    if ([indexPath row] == 0) {
        MetaListItem *item = [[self listItems] objectAtIndex:0];
        if ([item isNewValue]) {
            CGSize textSize = [[item name] sizeWithFont:[ThemeManager fontForStandardListText] constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
            return MAX(ROW_HEIGHT, textSize.height + 2 * EDITCELL_TEXTVIEW_VMARGIN);
        }
    }
    NSString *text = [item name];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
    CGSize size = [text sizeWithFont:[ThemeManager fontForStandardListText] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size.height + CELL_VMARGIN;

}



#pragma mark -
#pragma mark Table data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DLog(@"cell count: %d", [[self listItems] count]);
    return [[self listItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    if ([item isNewValue]) {
        UITableViewCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
        if (!editCell) 
            editCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditCell"];
        else {
            [[editCell textLabel] setText:nil];
            CGRect contentFrame = [[editCell contentView] frame];
            contentFrame.size.height = [@"X" sizeWithFont:[ThemeManager fontForStandardListText]].height;
        }
        UITextView *tv = [self textViewForCell:editCell];
        [[editCell contentView] addSubview:tv];
        [tv becomeFirstResponder];
        return editCell;
    }
    UITableViewCell *cell = (ListItemCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
        cell = [self makeItemCell];
    [self configureCell:cell withItem:item];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item
{
    [[cell textLabel] setText:[item name]];
    NSString *qtyString = ([[item quantity] intValue] == 0) ? @"" : [[item quantity] stringValue];
    NSString *unitString = ([item unitOfMeasure]) ? [[item unitOfMeasure] unitAbbreviation] : @"";
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@%@", qtyString, unitString]];
}

- (UITextView *)textViewForCell:(UITableViewCell *)cell
{
    CGSize textSize = [@"XX" sizeWithFont:[ThemeManager fontForStandardListText]];
    CGRect frame = [[cell contentView] frame];
    frame.origin.x = EDITCELL_TEXTVIEW_HMARGIN;
    frame.origin.y = EDITCELL_TEXTVIEW_VMARGIN;
    frame.size.height = textSize.height;
    frame.size.width -= 2*EDITCELL_TEXTVIEW_HMARGIN;
    UITextView *tv = [[UITextView alloc] initWithFrame:frame];
    [tv setBackgroundColor:[UIColor yellowColor]];
    [tv setSpellCheckingType:UITextSpellCheckingTypeNo];
    [tv setAutocorrectionType:UITextAutocorrectionTypeNo];
    [tv setFont:[ThemeManager fontForStandardListText]];
    [[tv layer] setBorderWidth:1.0f];
    [tv setReturnKeyType:UIReturnKeyDone];
    [tv setDelegate:self];
    [tv setTag:TAG_TEXTVIEW];
    objc_setAssociatedObject(tv, &editCellKey, cell, OBJC_ASSOCIATION_ASSIGN);
    return tv;
}

- (UITableViewCell *)makeItemCell
{
    UITableViewCell *cell = [[ListItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    
    [[cell detailTextLabel] setFont:[ThemeManager fontForListDetails]];
    return cell;
 }


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  NO;
    //return YES;
}



#pragma mark -
#pragma mark TableView delegate methods




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [self listItems][[indexPath row]];
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
}

- (void)itemSelectedAtIndexPath:(NSIndexPath *)indexPath 
{    
    ListItemCell *cell = (ListItemCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    MetaListItem *item = [self listItems][[indexPath row]];
    NSNumber *checkedValue = ([item isComplete]) ? INT_OBJ(0) : INT_OBJ(1);  // reverse of the current state
    [item setIsChecked:checkedValue];
    [self updateCheckboxButtonForItem:item atCell:cell];
}

- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(ListItemCell *)cell 
{    
    NSString *stateImageFile = ([item isComplete]) ? @"btn-checkbox-checked" : @"btn-checkbox";
    UIImage *radioStateImage = [UIImage imageNamed:stateImageFile];
    [[cell imageView] setImage:radioStateImage];
    [cell setEditModeImage:radioStateImage];
}


#pragma mark - list changed notification methods

- (void)didReceiveListChangeNotification:(NSNotification *)notification
{
    [[self tableView] reloadData];
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
    NSArray *actionSelectors = @[@"deleteAllItems", checkStateSelector, 
                                @"pickFromStash",@"showListNote"];
    [self performSelector:NSSelectorFromString(actionSelectors[buttonIndex- 1])];
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
    //[self filterItemsByCheckedState];
    [[self tableView] reloadData];
}

- (void)uncheckAllItems 
{
    NSPredicate *checkedItems = [NSPredicate predicateWithFormat:@"self.isChecked == 1"];
    [[self theList] setItemsMatching:checkedItems toCheckedState:0];
    //[self filterItemsByCheckedState];
    [[self tableView] reloadData];
}

- (void)pickFromStash 
{
    ItemStashViewController *isvc = [[ItemStashViewController alloc] initWithList:[self theList]];
    [self presentModalViewController:isvc animated:YES];
}

- (void)showListNote 
{
    DisplayListNoteViewController *noteVc = [[DisplayListNoteViewController alloc] initWithList:[self theList]];
    [self presentModalViewController:noteVc animated:YES];
}

#pragma mark - UITextView delegate method

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound ) {
        [textView resignFirstResponder];
        return NO;
    }
    NSString *newText = [NSString stringWithFormat:@"%@%@", [textView text], text];
    MetaListItem *item = [[self listItems] objectAtIndex:0];
    [item setName:newText];
    CGFloat viewWidth = CGRectGetWidth([textView frame]);
    
    CGSize textSize = [newText sizeWithFont:[textView font] constrainedToSize:CGSizeMake(viewWidth - 20.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    if (textSize.height <= CGRectGetHeight([textView frame])) return YES;
    
    UITableViewCell *editCell = objc_getAssociatedObject(textView, &editCellKey);
    CGRect contentFrame = [[editCell contentView] frame];
    contentFrame.size.height += [text sizeWithFont:[ThemeManager fontForStandardListText]].height;
    [[editCell contentView] setFrame:contentFrame];
    CGRect tvFrame = [textView frame];
    tvFrame.size.height = textSize.height;
    [textView setFrame:tvFrame];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *text = [textView text];
    UITableViewCell *editCell = objc_getAssociatedObject(textView, &editCellKey);
    objc_removeAssociatedObjects(textView);
    [textView resignFirstResponder];
    [textView removeFromSuperview];
    [[editCell textLabel] setText:text];
    MetaListItem *item = [[self listItems] objectAtIndex:0];
    [item setIsNewValue:NO];
    [[[self theList] itemsSet] addObject:item];
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:editCell];
    editCell = nil;
    if (indexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

/** old methods  **/

/*

 
 */



/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle != UITableViewCellEditingStyleDelete) return;
 MetaListItem *deleteItem = [self listItems][[indexPath row]];
 [[self listItems] removeObject:deleteItem];
 [[[self theList] managedObjectContext] deleteObject:deleteItem];
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 [[self theList] removeItem:deleteItem];
 if ([[[self theList] items] count] == 0) {  // just deleted the last item
 NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
 [tableView insertRowsAtIndexPaths:@[ipath] withRowAnimation:UITableViewRowAnimationFade];
 }
 [self commitAnyChanges];
 }
 */



/*
 - (void)cancelBtnPressed:(id)sender
 {
 [self setInEditMode:NO];
 [self rollbackAnyChanges];
 [[self editBtn] setTitle:NSLocalizedString(@"Select", @"edit button")];
 [self toggleCancelButton:[self inEditMode]];
 for (NSIndexPath *p in [[self tableView] indexPathsForVisibleRows]) {
 MetaListItem *item = [self listItems][[p row]];
 ListItemCell *cell = (ListItemCell *)[[self tableView] cellForRowAtIndexPath:p];
 if ([item isComplete])
 [cell setEditModeImage:[UIImage imageNamed:@"btn-checkbox-checked"]];
 else
 [cell setEditModeImage:[UIImage imageNamed:@"btn-checkbox"]];
 }
 [[self tableView] setEditing:NO animated:YES];
 [self enableToolbarItems:YES];
 }
 */
