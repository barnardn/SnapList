//
//  ListManagerViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/8/12.
//
//

#import "ListCategory.h"
#import "ListManagerViewController.h"
#import "MetaList.h"
#import "NSArrayExtensions.h"
#import "TextFieldTableCell.h"
#import "ThemeManager.h"

static NSString * const kUncategorizedListsKey  = @"--uncategorized--";


@interface ListManagerViewController () <UITableViewDataSource, UITableViewDelegate, TextFieldTableCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnReorder;

@property (nonatomic, strong) NSMutableDictionary *categoryListMap;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *categoryNames;        // to categories sorted.
@property (nonatomic, strong) NSMutableDictionary *categoriesByName;

@end

@implementation ListManagerViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if (!self) return nil;
    _managedObjectContext  = moc;
    _categoryListMap = [NSMutableDictionary dictionary];
    _categoryNames = [NSMutableArray array];
    _categoriesByName = [NSMutableDictionary dictionary];
    return self;
}

- (NSString *)nibName
{
    return @"ListManagerView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneTapped:)];
    [[self navigationItem] setLeftBarButtonItem:btnDone];
    [[self navigationItem] setTitle:@"snap!List"];
    
    NSArray *categories = [ListCategory allCategoriesInContext:[self managedObjectContext]];
    NSArray *uncategorizedLists = [MetaList allUncategorizedListsInContext:[self managedObjectContext]];
    
    [categories forEach:^(ListCategory *lc) {
        [[self categoryListMap] setObject:[[lc sortedLists] mutableCopy] forKey:[lc name]];
        [[self categoryNames] addObject:[lc name]];
        [[self categoriesByName] setObject:lc forKey:[lc name]];
    }];
    [[self categoryListMap] setObject:[uncategorizedLists mutableCopy] forKey:kUncategorizedListsKey];
    [[self categoryNames] addObject:kUncategorizedListsKey];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)btnDoneTapped:(UIBarButtonItem *)sender
{
    DLog(@"done button tapped");
    [[self delegate] dismissListManagerView];
}

- (IBAction)btnReorderTapped:(UIBarButtonItem *)sender
{
    DLog(@"order button tapped");
    if ([[self tableView] isEditing]) {
        [[self tableView] setEditing:NO animated:YES];
        [[self btnReorder] setImage:[UIImage imageNamed:@"btn-reorder"]];
    }
    else {
        [[self tableView] setEditing:YES animated:YES];
        [[self btnReorder] setImage:[UIImage imageNamed:@"icon-ok-small"]];
    }
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self categoryNames] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *categoryKey = [[self categoryNames] objectAtIndex:section];
    NSArray *lists = [[self categoryListMap] objectForKey:categoryKey];
    return [lists count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    if (!list)
        return [self textCellForIndexPath:indexPath];
    return [self cellForList:list atIndexPath:indexPath];
}

- (UITableViewCell *)cellForList:(MetaList *)list atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    [cell setShowsReorderControl:YES];
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setTextColor:[ThemeManager textColorForListManagerList]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:1.0f]];
    
    [[cell textLabel] setText:[list name]];
    return cell;
}

- (UITableViewCell *)textCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TextCell";
    TextFieldTableCell *cell = (TextFieldTableCell *)[[self tableView] dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setDelegate:self];
    }
    [cell setBackgroundColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    return cell;
}

#pragma mark text field table cell delegate

- (void)textFieldTableCell:(TextFieldTableCell *)tableCell didEndEdittingText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:tableCell];
    NSString *categoryKey = [[self categoryNames] objectAtIndex:[indexPath section]];
    ListCategory *category = [[self categoriesByName] objectForKey:categoryKey];
    MetaList *newList = [MetaList insertInManagedObjectContext:[self managedObjectContext]];
    [newList setName:text];
    if (![categoryKey isEqualToString:kUncategorizedListsKey])
        [newList setCategory:category];
    [newList setDateCreated:[NSDate date]];
    [newList save];
    
    [[self tableView] beginUpdates];
    NSMutableArray *lists = [[self categoryListMap] objectForKey:categoryKey];
    [lists addObject:newList];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:NO];
    [[self tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
}

#pragma - TODO clean up the header views for this section.  they look crappy!

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *categoryKey = [[self categoryNames] objectAtIndex:section];
    if ([categoryKey isEqualToString:kUncategorizedListsKey])
        categoryKey = NSLocalizedString(@"No Category", nil);
    
    CGFloat width = CGRectGetWidth([[self tableView] bounds]);
    UIView *headerView = [ThemeManager headerViewWithStyle:TableHeaderStyleLight
                                                     title:categoryKey
                                               dimensions:CGSizeMake(width, [ThemeManager heightForHeaderview])];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ThemeManager heightForHeaderview];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    return (list != nil) ? YES : NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    return (list != nil) ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    MetaList *list = [self listObjectAtIndexPath:proposedDestinationIndexPath];
    if (list) return proposedDestinationIndexPath;
    
    return [NSIndexPath indexPathForRow:[proposedDestinationIndexPath row] - 1 inSection:[proposedDestinationIndexPath section]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    DLog(@"source: %@ destination: %@", sourceIndexPath, destinationIndexPath);
    if ([sourceIndexPath compare:destinationIndexPath] == NSOrderedSame) return;
    
    NSString *sourceKey = [[self categoryNames] objectAtIndex:[sourceIndexPath section]];
    NSString *destKey = [[self categoryNames] objectAtIndex:[destinationIndexPath section]];
    
    NSMutableArray *sourceList = [[self categoryListMap] objectForKey:sourceKey];
    NSMutableArray *destinationList = [[self categoryListMap] objectForKey:destKey];
    
    MetaList *list = [sourceList objectAtIndex:[sourceIndexPath row]];
    [sourceList removeObject:list];
    [destinationList insertObject:list atIndex:[destinationIndexPath row]];
    [destinationList enumerateObjectsUsingBlock:^(MetaList *l, NSUInteger idx, BOOL *stop) {
        [l setOrder:@(idx)];
    }];
    if (![sourceKey isEqualToString:destKey]) {
        ListCategory *sourceCategory = [[self categoriesByName] objectForKey:sourceKey];
        [sourceCategory removeListObject:list];
        ListCategory *destCategory = [[self categoriesByName] objectForKey:destKey];
        [destCategory addListObject:list];
    }
    NSError *error = nil;
    ZAssert([[self managedObjectContext] save:&error], @"Whoa! unable to save lists after reorder: %@", [error localizedDescription]);
}


#pragma mark - private methods

- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *categoryKey = [[self categoryNames] objectAtIndex:[indexPath section]];
    NSArray *arr = [[self categoryListMap] objectForKey:categoryKey];
    if ([indexPath row] >= [arr count]) return nil;
    return [arr objectAtIndex:[indexPath row]];
}

#pragma mark - swipe to edit table view overrides

- (BOOL)shouldIgnoreGestureRecognizerForDirection:(SwipeGestureRecognizerDirection)swipeDirection
{
    return (swipeDirection == SwipeGestureRecognizerDirectionRight);
}

- (void)leftSwipeDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"delete list due to left swipe gesture");
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    NSString *categoryKey = [[self categoryNames] objectAtIndex:[indexPath section]];
    NSMutableArray *arr = [[self categoryListMap] objectForKey:categoryKey];
    [arr removeObject:list];
    [[self managedObjectContext] deleteObject:list];
    NSError *error;
    ZAssert([[self managedObjectContext] save:&error], @"Whoa! Unable to delete list: %@", [error localizedDescription]);
}

@end
