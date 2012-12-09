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
#import "ThemeManager.h"

static NSString * const kUncategorizedListsKey  = @"--uncategorized--";


@interface ListManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnDone;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnReorder;

@property (nonatomic, strong) NSMutableDictionary *categoryListMap;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *categoryNames;        // to categories sorted.

@end

@implementation ListManagerViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if (!self) return nil;
    _managedObjectContext  = moc;
    _categoryListMap = [NSMutableDictionary dictionary];
    _categoryNames = [NSMutableArray array];
    return self;
}

- (NSString *)nibName
{
    return @"ListManagerView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-listmgt"]]];
    
    NSArray *categories = [ListCategory allCategoriesInContext:[self managedObjectContext]];
    NSArray *uncategorizedLists = [MetaList allUncategorizedListsInContext:[self managedObjectContext]];
    
    [categories forEach:^(ListCategory *lc) {
        [[self categoryListMap] setObject:[[lc sortedLists] mutableCopy] forKey:[lc name]];
        [[self categoryNames] addObject:[lc name]];
    }];
    [[self categoryListMap] setObject:[uncategorizedLists mutableCopy] forKey:kUncategorizedListsKey];
    [[self categoryNames] addObject:kUncategorizedListsKey];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setSeparatorColor:[UIColor clearColor]];
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
    return [lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [self configureCell:cell];
    MetaList *list = [self listObjectAtIndexPath:indexPath];
    [[cell textLabel] setText:[list name]];
    return cell;
}

#pragma mark - private methods

- (MetaList *)listObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *categoryKey = [[self categoryNames] objectAtIndex:[indexPath section]];
    NSArray *arr = [[self categoryListMap] objectForKey:categoryKey];
    return [arr objectAtIndex:[indexPath row]];
}

- (void)configureCell:(UITableViewCell *)cell
{
    [[cell textLabel] setFont:[ThemeManager fontForListName]];
    [[cell textLabel] setTextColor:[ThemeManager textColorForListManagerList]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];    
    [cell setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:1.0f]];
}


@end
