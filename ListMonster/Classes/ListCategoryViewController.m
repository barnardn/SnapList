//
//  ListCategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/26/12.
//
//

#import "ListCategory.h"
#import "ListCategoryViewController.h"
#import "MetaList.h"
#import "ThemeManager.h"
#import "TextFieldTableCell.h"
#import "TextFieldTableCellController.h"

static const CGFloat kRowHeight = 44.0f;

@interface ListCategoryViewController () <TableCellControllerDelegate, TextFieldTableCellControllerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnReorder;
@property (nonatomic, strong) UIBarButtonItem *btnAdd;
@property (nonatomic, strong) MetaList *list;
@property (nonatomic, strong) NSMutableArray *allCategories;
@property (nonatomic, strong) TextFieldTableCellController *textFieldCellController;

@end

@implementation ListCategoryViewController

- (id)initWithList:(MetaList *)list
{
    self = [super init];
    if (!self) return nil;
    _list = list;
    return self;
}

- (NSString *)nibName
{
    return @"ListCategoryView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]]];    
    [[self navigationItem] setPrompt:NSLocalizedString(@"Choose or Edit Categeories", nil)];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(addButtonTapped:)];
    [[self navigationItem] setRightBarButtonItem:btn];
    [self setBtnAdd:btn];
    [[self tableView] setRowHeight:kRowHeight];
    NSArray *categories = [ListCategory allCategoriesInContext:[[self list] managedObjectContext]];
    [self setAllCategories:[categories mutableCopy]];
    TextFieldTableCellController *tfc = [[TextFieldTableCellController alloc] initWithTableView:[self tableView]];
    [tfc setDelegate:self];
    [tfc setTextfieldTextColor:[ThemeManager textColorForListManagerList]];
    [tfc setClearTextOnBeginEdit:YES];
    [self setTextFieldCellController:tfc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - button actions

- (void)addButtonTapped:(UIBarButtonItem *)sender
{
    ListCategory *category = [ListCategory insertInManagedObjectContext:[[self list] managedObjectContext]];
    [[self allCategories] insertObject:category atIndex:0];
    [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)reorderButtonTapped:(UIBarButtonItem *)button
{
    if ([[self tableView] isEditing]) {
        [[self tableView] setEditing:NO animated:YES];
        [button setImage:[UIImage imageNamed:@"btn-reorder"]];
        [[self btnAdd] setEnabled:YES];
    }
    else {
        [[self tableView] setEditing:YES animated:YES];
        [button setImage:[UIImage imageNamed:@"icon-ok-small"]];
        [[self btnAdd] setEnabled:NO];
    }
}


#pragma mark - table view datasource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self allCategories] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    if ([category isNewValue]) {
        TextFieldTableCell *tfCell = (TextFieldTableCell *)[[self textFieldCellController] tableView:tableView cellForRowAtIndexPath:indexPath];
        [tfCell setSelected:YES];
        return tfCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [[cell textLabel] setFont:[ThemeManager fontForListName]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [[cell textLabel] setText:[category name]];
    [[cell textLabel] setTextColor:[ThemeManager textColorForListManagerList]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setShowsReorderControl:YES];
    if (category == [[self list] category]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-checkmark-white"]];
        [cell setAccessoryView:checkmark];
    }
    return cell;
}

#pragma mark - tableview delegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSwipeActionIndicatorViewsFromCell:cell];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [ThemeManager headerViewTitled:[[self list] name] withDimensions:CGSizeMake(CGRectGetWidth([[self view] bounds]), [ThemeManager heightForHeaderview])];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    if ([category isNewValue])
        return [[self textFieldCellController] tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-checkmark-white"]];
    [cell setAccessoryView:checkmark];
    [[self list] setCategory:category];
    [[self list] save];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryView:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    return ![category isNewValue];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    return ![category isNewValue];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[proposedDestinationIndexPath row]];
    if (![category isNewValue]) return proposedDestinationIndexPath;
    
    NSIndexPath *alternative  = [NSIndexPath indexPathForRow:[proposedDestinationIndexPath row] + 1 inSection:[proposedDestinationIndexPath section]];
    return alternative;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[sourceIndexPath row]];
    [[self allCategories] removeObject:category];
    [[self allCategories] insertObject:category atIndex:[destinationIndexPath row]];
    [[self allCategories] enumerateObjectsUsingBlock:^(ListCategory *cat, NSUInteger idx, BOOL *stop) {
        [cat setOrderValue:idx];
    }];
    NSError *error;
    ZAssert([[[self list] managedObjectContext] save:&error], @"Whoa! cant save after category reorder: %@", [error localizedDescription]);
}

#pragma mark - text field controller delegate methods

- (NSString *)defaultTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"New Category...", nil);
}

- (void)didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    [category setName:text];
    [category save];
    [[self tableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - swipe cell overrides

- (BOOL)shouldIgnoreGestureRecognizerForDirection:(SwipeGestureRecognizerDirection)swipeDirection
{
    return (swipeDirection == SwipeGestureRecognizerDirectionRight);
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCategory *category = [[self allCategories] objectAtIndex:[indexPath row]];
    [[self allCategories] removeObject:category];
    [[category managedObjectContext] deleteObject:category];
    [[category managedObjectContext] save:nil];
}

@end
