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
#import "ItemStashViewController.h"
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
#define TAG_COMPLETEVIEW            1002
#define TAG_COMPLETELABEL           1003
#define HEADERVIEW_HEIGHT           25.0f


static char editCellKey;

@interface ListItemsViewController()

- (UITableViewCell *)makeItemCell;
- (IBAction)editBtnPressed:(UIBarButtonItem *)editButton;
- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item;
- (void)enableToolbarItems:(BOOL)enabled;

@property (nonatomic,strong) NSMutableArray *listItems;
@property (nonatomic,strong) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic,strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic,strong) UITableViewCell *cellForDeletionCancel;
@property (nonatomic,strong) NSArray *deleteCancelRegions;
@property  (nonatomic, strong) UIBarButtonItem *addButton;

@end


@implementation ListItemsViewController

@synthesize theList, moreActionsBtn;
@synthesize toolBar,inEditMode, editBtn;

- (id)initWithList:(MetaList *)aList
{
    self = [super init];
    if (!self) return nil;
    [self setTheList:aList];
    _listItems = [[aList sortedItemsIncludingComplete:NO] mutableCopy];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTICE_LIST_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveListChangeNotification:) name:NOTICE_LIST_UPDATE object:nil];

    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    [_leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft]; 

    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler:)];
    [_rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
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
    [[self tableView] setAllowsSelectionDuringEditing:NO];
    [[self tableView] setScrollsToTop:YES];
    [[self tableView] addGestureRecognizer:[self leftSwipe]];
    [[self tableView] addGestureRecognizer:[self rightSwipe]];
    
    [[self tableView] setContentInset:UIEdgeInsetsMake(25.0f,0,0,0)];
    [self insertHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    editItemNavController = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)insertHeaderView
{
    UIView *headerView = [ThemeManager headerViewTitled:[[self theList] name] withDimenions:CGSizeMake(CGRectGetWidth([[self tableView] frame]), HEADERVIEW_HEIGHT)];
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
        [[self editBtn] setImage:[UIImage imageNamed:@"btn-done"]];
    }
}


// TODO:  is this method necessary???
- (void)enableToolbarItems:(BOOL)enabled
{
    [[self moreActionsBtn] setEnabled:enabled];
}


#pragma mark -
#pragma mark ListItemsViewControllerProtocol method 

-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didCancelEditOnNewItem:(MetaListItem *)item
{
    [NSException raise:@"Deprecated method" format:@"Method editListItemViewController:didCancelEditOnNewItem: no longer needed"];
}

-(void)editListItemViewController:(EditListItemViewController *)editListItemViewController didAddNewItem:(MetaListItem *)item
{
    [NSException raise:@"Deprecated method" format:@"Method editListItemViewController:didAddNewItem: no longer needed"];
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
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:NO];
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
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withItem:(MetaListItem *)item
{
    [[cell viewWithTag:TAG_COMPLETELABEL] removeFromSuperview];
    [[cell viewWithTag:TAG_COMPLETEVIEW] removeFromSuperview];
    [[cell textLabel] setText:[item name]];
    UIColor *textColor = ([item isCheckedValue]) ? [ThemeManager ghostedTextColor] : [ThemeManager standardTextColor];
    [[cell textLabel] setTextColor:textColor];
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
    DLog(@"new value for item %@ is %d", [item name], [item isNewValue]);
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

#pragma mark - gesture recognizer actions

- (void)rightSwipeHandler:(UISwipeGestureRecognizer *)swipe
{
    if ([self cellForDeletionCancel]) {
        [self cancelItemDelete];
        return;
    }
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[swipe locationInView:[self tableView]]];
    UITableViewCell *swipedCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    [swipedCell setAccessoryType:UITableViewCellAccessoryNone];
    CGAffineTransform xlation = CGAffineTransformMakeTranslation(320.0f, 0.0f);
    UIImage *imgBackground = [[UIImage imageNamed:@"bg-complete"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    CGRect cellFrame = CDO_CGRectByReplacingOrigin([swipedCell frame], CGPointMake(-320.0f, 0.0f));
    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:cellFrame];
    [ivBg setImage:imgBackground];
    [ivBg setTag:TAG_COMPLETEVIEW];
    [swipedCell addSubview:ivBg];
    [UIView animateWithDuration:0.25f animations:^{
        [[swipedCell textLabel] setTransform:xlation];
        [[swipedCell detailTextLabel] setTransform:xlation];
        [ivBg setTransform:xlation];
    } completion:^(BOOL finished) {
        CGPoint center = CDO_CGPointIntegral([[swipedCell contentView] center]);
        BOOL checkValue = ![item isComplete];
        [item setIsComplete:checkValue];
        [item save];
        NSString *actionTitle = ([item isComplete]) ? NSLocalizedString(@"Complete", nil) : NSLocalizedString(@"Not Done", nil);
        [swipedCell addSubview:[self swipeActionLabelWithText:actionTitle centeredAt:center]];
        [[swipedCell textLabel] setTransform:CGAffineTransformIdentity];
        [[swipedCell detailTextLabel] setTransform:CGAffineTransformIdentity];
        [[self tableView] beginUpdates];
        if ([item isComplete]) {
            [[self listItems] removeObjectAtIndex:[indexPath row]];
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [[self tableView] endUpdates];
    }];
}

- (UILabel *)swipeActionLabelWithText:(NSString *)text centeredAt:(CGPoint)center
{
    UILabel *lblComplete = [[UILabel alloc] init];
    [lblComplete setTag:TAG_COMPLETELABEL];
    [lblComplete setFont:[ThemeManager fontForListName]];
    [lblComplete setTextColor:[UIColor whiteColor]];
    [lblComplete setText:text];
    [lblComplete sizeToFit];
    [lblComplete setBackgroundColor:[UIColor clearColor]];
    [lblComplete setCenter:center];
    return lblComplete;
}

- (void)leftSwipeHandler:(UISwipeGestureRecognizer *)swipe
{
    DLog(@"left swipe");
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[swipe locationInView:[self tableView]]];
    UITableViewCell *swipedCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    [swipedCell setAccessoryType:UITableViewCellAccessoryNone];
    CGAffineTransform xlation = CGAffineTransformMakeTranslation(-320.0f, 0.0f);
    CGRect cellFrame = [swipedCell frame];
    
    CGRect imgFrame = CGRectMake(320.0f, 0.0f, 320.0f, cellFrame.size.height);
    UIImageView *ivBg = [[UIImageView alloc] initWithFrame:imgFrame];
    UIImage *imgBackground = [[UIImage imageNamed:@"bg-deletion"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [ivBg setImage:imgBackground];
    [ivBg setTag:TAG_COMPLETEVIEW];
    [swipedCell addSubview:ivBg];
    
    [UIView animateWithDuration:0.25f animations:^{
        [[swipedCell textLabel] setTransform:xlation];
        [[swipedCell detailTextLabel] setTransform:xlation];
        [ivBg setTransform:xlation];
    } completion:^(BOOL finished) {
        CGPoint center = CDO_CGPointIntegral([[swipedCell contentView] center]);
        [swipedCell addSubview:[self swipeActionLabelWithText:@"Delete" centeredAt:center]];

        UIButton *top = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, CGRectGetMinY([swipedCell frame]))];
        [top setBackgroundColor:[UIColor clearColor]];
        
        UIButton *btm = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   CGRectGetMaxY([swipedCell frame]),
                                                                   320.0f,
                                                                   CGRectGetHeight([[self view] bounds]) - CGRectGetMaxY([swipedCell frame]))];
        [btm setBackgroundColor:[UIColor clearColor]];
        [top addTarget:self action:@selector(deleteCancelRegionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btm addTarget:self action:@selector(deleteCancelRegionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:top];
        [[self view] addSubview:btm];
        [self setDeleteCancelRegions:@[top, btm]];
        [self setCellForDeletionCancel:swipedCell];
        [[swipedCell textLabel] setTransform:CGAffineTransformIdentity];
        [[swipedCell detailTextLabel] setTransform:CGAffineTransformIdentity];

    }];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletionConfirmed:)];
    [[self tableView] addGestureRecognizer:tgr];
    
}


#pragma mark - cell/item deletion handlers

- (void)deletionConfirmed:(UITapGestureRecognizer *)tap
{
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:[tap locationInView:[self tableView]]];
    [[self tableView] removeGestureRecognizer:tap];
    [[self deleteCancelRegions] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        [btn removeFromSuperview];
    }];
    [self setDeleteCancelRegions:nil];
    [self setCellForDeletionCancel:nil];    

    [[self tableView] beginUpdates];
    MetaListItem *itemToDelete = [[self listItems] objectAtIndex:[indexPath row]];
    [[self listItems] removeObject:itemToDelete];
    [[[self theList] managedObjectContext] deleteObject:itemToDelete];
    [[self theList] save];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];

}

- (void)deleteCancelRegionTapped:(UIButton *)region
{
    [self cancelItemDelete];
}

- (void)cancelItemDelete
{
    UILabel *lbl = (UILabel *)[[self cellForDeletionCancel] viewWithTag:TAG_COMPLETELABEL];
    UIImageView *iv = (UIImageView *)[[self cellForDeletionCancel] viewWithTag:TAG_COMPLETEVIEW];
    [[self deleteCancelRegions] enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        [btn removeFromSuperview];
    }];
    [self setDeleteCancelRegions:nil];

    [UIView animateWithDuration:0.25f animations:^{
        [lbl setAlpha:0.0f];
        [iv setAlpha:0.0f];
        [[self cellForDeletionCancel] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } completion:^(BOOL finished) {
        [lbl removeFromSuperview];
        [iv removeFromSuperview];
        [self setCellForDeletionCancel:nil];
    }];
}


#pragma mark - list changed notification methods

- (void)didReceiveListChangeNotification:(NSNotification *)notification
{
    [[self tableView] reloadData];
}


@end

