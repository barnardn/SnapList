//
//  ListItemsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <objc/objc-runtime.h>

#import "Alerts.h"
#import "CDOGeometry.h"
#import "DisplayListNoteViewController.h"
#import "EditListItemViewController.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "ListItemsViewController.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "ThemeManager.h"

#define ROW_HEIGHT  44.0f
#define EDITCELL_TEXTVIEW_HMARGIN   10.0f
#define EDITCELL_TEXTVIEW_VMARGIN   5.0f
#define CELL_VMARGIN                25.0f
#define ITEM_CELL_CONTENT_WIDTH     245.0f
#define TAG_TEXTVIEW                1001

static char editCellKey;

@interface ListItemsViewController()

- (UITableViewCell *)makeItemCell;
- (IBAction)editBtnPressed:(UIBarButtonItem *)editButton;
- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item;

@property (nonatomic,strong) NSMutableArray *listItems;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end


@implementation ListItemsViewController

- (id)initWithList:(MetaList *)aList
{
    self = [super init];
    if (!self) return nil;
    _theList = aList;
    _listItems = [NSMutableArray arrayWithCapacity:0];
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
    [self setAddButton:btn];
    
    [[self navigationItem] setRightBarButtonItem:[self addButton]];
    
    if ([[self theList] allItemsFinished]) {
        [[self btnViewAll] setTag:1];
        [[self btnViewAll] setImage:[UIImage imageNamed:@"icon-hide-completed"]];
        [self setListItems:[[[self theList] sortedItemsIncludingComplete:YES] mutableCopy]];
    } else {
        [[self btnViewAll] setTag:0];
        [[self btnViewAll] setImage:[UIImage imageNamed:@"icon-show-all"]];
        [self setListItems:[[[self theList] sortedItemsIncludingComplete:NO] mutableCopy]];
    }
    
    [[self tableView] setAllowsSelectionDuringEditing:NO];
    [[self tableView] setScrollsToTop:YES];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(25.0f,0,0,0)];
    [self insertHeaderView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([[self tableView] indexPathForSelectedRow]) {
        NSInteger row = [[[self tableView] indexPathForSelectedRow] row];
        MetaListItem *item = [[self listItems] objectAtIndex:row];
        if ([self shouldRemoveSelectedItem:item]) {
            [[self listItems] removeObjectAtIndex:row];
            [[self tableView] deleteRowsAtIndexPaths:@[[[self tableView] indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [[self tableView] reloadRowsAtIndexPaths:@[[[self tableView] indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (BOOL)shouldRemoveSelectedItem:(MetaListItem *)item;
{
    if ([item wasDeleted]) return YES;    
    // remove the item if were hiding completed and our item is now marked complete
    return ([[self btnViewAll] tag] == 0 && [item isComplete]);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)insertHeaderView
{
    UIView *headerView = [ThemeManager headerViewTitled:[[self theList] name] withDimensions:CGSizeMake(CGRectGetWidth([[self tableView] frame]), [ThemeManager heightForHeaderview])];
    [[self view] addSubview:headerView];
}


#pragma mark -
#pragma mark Button action


- (void)addButtonTapped:(UIBarButtonItem *)barBtn
{
    MetaListItem *firstItem = [[self listItems] firstItem];
    if ([firstItem isNew]) {
        UITableViewCell *editCell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextView *textView = (UITextView *)[[editCell contentView] viewWithTag:TAG_TEXTVIEW];
        [textView endEditing:YES];
    }
    MetaListItem *item = [MetaListItem insertInManagedObjectContext:[[self theList] managedObjectContext]];
    [[self tableView] beginUpdates];
    [[self listItems] insertObject:item atIndex:0];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[self tableView] insertRowsAtIndexPaths:@[topIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
    
    if ([[self listItems] count] > 1)
        [[self tableView] scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (IBAction)editBtnPressed:(UIBarButtonItem *)editButton
{
    if ([[self tableView] isEditing]) {
        [[self tableView] setEditing:NO animated:YES];
        [[self editBtn] setImage:[UIImage imageNamed:@"btn-reorder"]];
    }
    else {
        [[self tableView] setEditing:YES animated:YES];
        [[self editBtn] setImage:[UIImage imageNamed:@"icon-ok-small"]];
    }
}


- (IBAction)btnViewAllTapped:(UIBarButtonItem *)btn
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
    if ([btn tag] == 1) {       // we're viewing all currently
        [[self listItems] enumerateObjectsUsingBlock:^(MetaListItem *item, NSUInteger idx, BOOL *stop) {
            if ([item isComplete])
                [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
        }];
        [[self tableView] beginUpdates];
        NSMutableArray *filtered = [[[self theList] sortedItemsIncludingComplete:NO] mutableCopy];
        [self setListItems:filtered];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self tableView] endUpdates];
        [btn setTag:0];
        [[self btnViewAll] setImage:[UIImage imageNamed:@"icon-show-all"]];
        return;
    }
    NSMutableArray *allItems = [[[self theList] sortedItemsIncludingComplete:YES] mutableCopy];
    [allItems enumerateObjectsUsingBlock:^(MetaListItem *item, NSUInteger idx, BOOL *stop) {
        DLog(@"is complete %d", [item isComplete]);
        if ([item isComplete])
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    [[self tableView] beginUpdates];
    [self setListItems:allItems];
    [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] endUpdates];
    [btn setTag:1];
    [[self btnViewAll] setImage:[UIImage imageNamed:@"icon-hide-completed"]];
}


#pragma mark - table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MetaListItem *item = [self listItems][[indexPath row]];
    if ([indexPath row] == 0) {
        MetaListItem *item = [[self listItems] objectAtIndex:0];
        if ([item isNewValue]) {
            CGSize textSize = [[item name] sizeWithFont:[ThemeManager fontForStandardListText] constrainedToSize:CGSizeMake(ITEM_CELL_CONTENT_WIDTH, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
            return MAX(ROW_HEIGHT, textSize.height + 2 * EDITCELL_TEXTVIEW_VMARGIN);
        }
    }
    NSString *text = [item name];
    CGSize constraint = CGSizeMake(ITEM_CELL_CONTENT_WIDTH, 20000.0f);
    CGSize size = [text sizeWithFont:[ThemeManager fontForStandardListText] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size.height + CELL_VMARGIN;

}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [self makeItemCell];
    }
    [self configureCell:cell withItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSwipeActionIndicatorViewsFromCell:cell];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    if ([item isNewValue])
        ALog(@"cant move row at index path: %@", indexPath);
    return ![item isNewValue];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([fromIndexPath row] == [toIndexPath row]) return;
    MetaListItem *item = [[self listItems] objectAtIndex:[fromIndexPath row]];
    [[self listItems] removeObject:item];
    [[self listItems] insertObject:item atIndex:[toIndexPath row]];
    [[self listItems] enumerateObjectsUsingBlock:^(MetaListItem *mli, NSUInteger idx, BOOL *stop) {
        [mli setOrderValue:idx];
    }];
    [[self theList] save];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [self listItems][[indexPath row]];
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
}


#pragma mark - cell creation and setup methods

- (UITableViewCell *)makeItemCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    [[cell textLabel] setNumberOfLines:0];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [[cell textLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [cell setShowsReorderControl:YES];
    [[cell detailTextLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setTextColor:[ThemeManager textColorForListDetails]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item
{
    [[cell textLabel] setText:[item name]];
    UIColor *textColor = ([item isCheckedValue]) ? [ThemeManager ghostedTextColor] : [ThemeManager standardTextColor];
    [[cell textLabel] setTextColor:textColor];
    NSString *qtyString = @"";
    NSString *unitString = ([item unitOfMeasure]) ? [[item unitOfMeasure] unitAbbreviation] : @"";
    if (![item unitOfMeasure]) {
        if (![[item quantityDescription] isEqualToString:@"1"])
            qtyString = [item quantityDescription];
    }
    else
        qtyString = [item quantityDescription];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@%@", qtyString, unitString]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    [tv setBackgroundColor:[UIColor clearColor]];
    [tv setSpellCheckingType:UITextSpellCheckingTypeNo];
    [tv setAutocorrectionType:UITextAutocorrectionTypeNo];
    [tv setFont:[ThemeManager fontForStandardListText]];
    [[tv layer] setBorderWidth:1.0f];
    [[tv layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [tv setReturnKeyType:UIReturnKeyDone];
    [tv setDelegate:self];
    [tv setTag:TAG_TEXTVIEW];
    objc_setAssociatedObject(tv, &editCellKey, cell, OBJC_ASSOCIATION_ASSIGN);
    return tv;
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
    MetaListItem *item = [[self listItems] objectAtIndex:0];
    if ([text length] == 0) {
        [[self tableView] beginUpdates];
        [[self listItems] removeObject:item];
        [[self tableView] deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self tableView] endUpdates];
        [[self theList] deleteItem:item];
        return;
    }
    
    [[editCell textLabel] setText:text];
    [item setIsNewValue:NO];
    [[[self theList] itemsSet] addObject:item];
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:editCell];
    editCell = nil;
    if (indexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[self listItems] enumerateObjectsUsingBlock:^(MetaListItem *item, NSUInteger idx, BOOL *stop) {
        [item setOrderValue:idx];
    }];
    
    [[self theList] save];
}

#pragma mark - swipe to edit cell view controller overrides



- (void)rightSwipeUpdateAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    BOOL complete = ![item isComplete] ? YES : NO;
    [item setIsComplete:complete];
    [item save];
}

- (NSString *)rightSwipeActionTitleForItemItemAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    return ([item isComplete]) ? @"Not Done" : @"Complete";
}

- (BOOL)rightSwipeShouldDeleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    return ([item isComplete]);
}

- (void)rightSwipeRemoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self listItems] count] > [indexPath row])
        [[self listItems] removeObjectAtIndex:[indexPath row]];
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    if ([[self listItems] count] > [indexPath row])
        [[self listItems] removeObjectAtIndex:[indexPath row]];
    [[self theList] deleteItem:item];
}


@end

