//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CellButtonTableViewCell.h"
#import "datetime_utils.h"
#import "EditListItemViewController.h"
#import "EditMeasureViewController.h"
#import "EditNumberViewController.h"
#import "LeftDetailTableViewCell.h"
#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "ReminderViewController.h"
#import "ThemeManager.h"
#import "TextViewTableCellController.h"

#define ROW_HEIGHT      44.0f
#define COUNT_PROPERTY_SECTIONS 4

@interface EditListItemViewController() <EditItemViewDelegate, TableCellControllerDelegate, TextViewTableCellControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) MetaListItem *item;
@property (nonatomic, strong) NSArray *editViewControllers;
@property (nonatomic, strong) NSArray *tableCellControllers;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithItem:(MetaListItem *)item
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    _item = item;
    _editViewControllers = @[[EditNumberViewController class], [EditMeasureViewController class], [ReminderViewController class]];
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [[self navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]]];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button")
                                                                style:UIBarButtonItemStylePlain
                                                               target:nil
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    TextViewTableCellController *tvc = [[TextViewTableCellController alloc] initWithTableView:[self tableView]];
    [tvc setDelegate:self];
    [tvc setBackgroundColor:[UIColor whiteColor]];
    [tvc setTextColor:[UIColor darkTextColor]];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LeftDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([LeftDetailTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CellButtonTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CellButtonTableViewCell class])];
    [self setTableCellControllers:@[tvc]];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if ([[self tableView] indexPathForSelectedRow])
        [[self tableView] reloadRowsAtIndexPaths:@[[[self tableView] indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    }
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return COUNT_PROPERTY_SECTIONS + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    if (section == COUNT_PROPERTY_SECTIONS) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    }
    
    if (indexPath.section < COUNT_PROPERTY_SECTIONS) {
        LeftDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LeftDetailTableViewCell class]) forIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

        switch ([indexPath section]) {
            case 1:
                [self configureQuantityCell:cell];
                break;
            case 2:
                [self configureUnitsCell:cell];
                break;
            case 3:
                [self configureReminderCell:cell];
                break;
        }
        return cell;
    }
    
    CellButtonTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellButtonTableViewCell class]) forIndexPath:indexPath];
    buttonCell.destructive = NO;
    NSString *title = (self.item.isComplete) ? @"Mark as Not Done" : @"Mark as Done";
    if (indexPath.row == 1) {
        title = @"Delete";
        buttonCell.destructive = YES;
    }
    buttonCell.buttonTitle = title;
    return buttonCell;
}

#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] didSelectRowAtIndexPath:indexPath];
    } else {
        TextViewTableCellController *cellController = [[self tableCellControllers] objectAtIndex:0];
        [cellController stopEditingCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    if ([indexPath section] == COUNT_PROPERTY_SECTIONS) {
        [self _handleCellButtonTapAtIndexPath:indexPath];
        return;
    };
    Class editControllerClass = [[self editViewControllers] objectAtIndex:[indexPath section] - 1];
    UIViewController<EditItemViewProtocol> *vc = [[editControllerClass alloc] initWithTitle:@"Snap!list" listItem:[self item]];
    [vc setDelegate:self];
    [[self navigationController] pushViewController:vc animated:YES];
}


#pragma mark - cell configuration methods

- (void)configureQuantityCell:(UITableViewCell *)cell {
    [[cell detailTextLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    
    [[cell textLabel] setText:NSLocalizedString(@"Quantity", nil)];
    if ([[self item] quantity] == 0) {
        [[cell detailTextLabel] setText:@"1"];
        return;
    }
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setLocale:[NSLocale currentLocale]];
    [numFormatter setMaximumFractionDigits:2];
    NSString *qty = [numFormatter stringFromNumber:[[self item] quantity]];
    [[cell detailTextLabel] setText:qty];
}

- (void)configureUnitsCell:(UITableViewCell *)cell {
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForStandardListText]];
    
    [[cell textLabel] setText:NSLocalizedString(@"Units", nil)];
    Measure *unitOfMeasure = [[self item] unitOfMeasure];
    NSString *units = @"";
    if (unitOfMeasure)
        units = [NSString stringWithFormat:@"%@(%@)", [unitOfMeasure measure], [unitOfMeasure unitAbbreviation]];
    [[cell detailTextLabel] setText:units];
}

- (void)configureReminderCell:(UITableViewCell *)cell {
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setText:NSLocalizedString(@"Reminder",nil)];
    NSString *reminderDate = @"";
    if ([[self item] reminderDate]) 
        reminderDate = formatted_relative_date([[self item] reminderDate]);
    [[cell detailTextLabel] setText:reminderDate];

}

#pragma mark - cell button actions 

- (void)_handleCellButtonTapAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = self.item.managedObjectContext;
    BOOL wasDeleted = NO;
    if (indexPath.row == 0) {
        self.item.isComplete = !self.item.isComplete;
    } else {
        [self.item.list deleteItem:self.item];
        wasDeleted = YES;
    }
    [context save:nil];
    if (wasDeleted) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark edit item delegate method

- (void)editItemViewController:(UIViewController *)editViewController didChangeValue:(id)updatedValue forItem:(MetaListItem *)item
{
    [[self item] save];
}

#pragma mark - edit item actions delegate methods

//- (void)markCompleteRequestedFromEditItemActionsView:(EditItemActionsView *)view
//{
//    if ([[self item] isComplete])
//        [[self item] setIsComplete:NO];
//    else
//        [[self item] setIsComplete:YES];
//    [[self item] save];
//}
//
//- (void)deleteRequestedFromEditItemActionsView:(EditItemActionsView *)view
//{
//    [[[self item] list] deleteItem:[self item]];
//    [[self navigationController] popViewControllerAnimated:YES];
//}

#pragma mark - textviewtablecell controller delegate methods

- (void)textViewTableCellController:(TextViewTableCellController *)controller didChangeText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self item] setName:text];
}

- (void)textViewTableCellController:(TextViewTableCellController *)controller didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self item] setName:text];
    [[self item] save];
}

- (NSString *)textViewTableCellController:(TextViewTableCellController *)controller textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self item] name];
}


@end

