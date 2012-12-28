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
    [[self navigationItem] setTitle:NSLocalizedString(@"Categories", nil)];
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(addButtonTapped:)];
    [[self navigationItem] setRightBarButtonItem:btnAdd];
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

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender
{
    ListCategory *category = [ListCategory insertInManagedObjectContext:[[self list] managedObjectContext]];
    [[self allCategories] insertObject:category atIndex:0];
    [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    [[cell textLabel] setText:[category name]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    if (category == [[self list] category]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
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
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [[self list] setCategory:category];
    [[self list] save];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
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
