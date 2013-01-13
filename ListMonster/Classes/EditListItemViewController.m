//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Alerts.h"
#import "datetime_utils.h"
#import "EditItemActionsView.h"
#import "EditListItemViewController.h"
#import "EditMeasureViewController.h"
#import "EditNumberViewController.h"
#import "EditTextViewController.h"
#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSNumberExtensions.h"
#import "ReminderViewController.h"
#import "ThemeManager.h"
#import "TextViewTableCellController.h"

#define ROW_HEIGHT      44.0f
#define COUNT_PROPERTY_SECTIONS 4

@interface EditListItemViewController() <EditItemViewDelegate, EditItemActionsViewDelegate,
                                            TableCellControllerDelegate, TextViewTableCellControllerDelegate,
                                            UIAlertViewDelegate, UIScrollViewDelegate>

- (UITableView *)tableView;

@property (nonatomic,strong) IBOutlet UITableView *listItemTableView;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) MetaListItem *item;
@property (nonatomic, strong) NSArray *editViewControllers;
@property (nonatomic, strong) NSArray *tableCellControllers;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithItem:(MetaListItem *)item
{
    self = [super init];
    if (!self) return nil;
    _item = item;
    _editViewControllers = @[[EditNumberViewController class], [EditMeasureViewController class], [ReminderViewController class]];
    return self;
}


- (NSString *)nibName
{
    return @"EditListItemView";
}

- (UITableView *)tableView 
{
    return [self listItemTableView];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:@"Snap!list"];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button")
                                                                style:UIBarButtonItemStylePlain
                                                               target:nil
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    MetaList *list = [[self item] list];
    if ([list listTintColor])
        [[self toolBar] setTintColor:[list listTintColor]];
    
    TextViewTableCellController *tvc = [[TextViewTableCellController alloc] initWithTableView:[self tableView]];
    [tvc setDelegate:self];
    [tvc setBackgroundColor:[UIColor whiteColor]];
    [tvc setTextColor:[UIColor darkTextColor]];
    
    [self setTableCellControllers:@[tvc]];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if ([[self tableView] indexPathForSelectedRow])
        [[self tableView] reloadRowsAtIndexPaths:@[[[self tableView] indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    } else if ([indexPath section] == COUNT_PROPERTY_SECTIONS) {
        return 100;
    }
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return COUNT_PROPERTY_SECTIONS + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellID = @"Cell";
    
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
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
        case 4:
            [self configureActionsCell:cell];
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self tableCellControllers] objectAtIndex:[indexPath section]];
        return [cellController tableView:[self tableView] didSelectRowAtIndexPath:indexPath];
    } else {
        TextViewTableCellController *cellController = [[self tableCellControllers] objectAtIndex:0];
        [cellController stopEditingCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    if ([indexPath section] == COUNT_PROPERTY_SECTIONS) return;
    Class editControllerClass = [[self editViewControllers] objectAtIndex:[indexPath section] - 1];
    UIViewController<EditItemViewProtocol> *vc = [[editControllerClass alloc] initWithTitle:@"Snap!list" listItem:[self item]];
    [vc setDelegate:self];
    [[self navigationController] pushViewController:vc animated:YES];
}


#pragma mark - cell configuration methods

- (void)configureQuantityCell:(UITableViewCell *)cell
{
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

- (void)configureUnitsCell:(UITableViewCell *)cell
{
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForStandardListText]];
    
    [[cell textLabel] setText:NSLocalizedString(@"Units", nil)];
    Measure *unitOfMeasure = [[self item] unitOfMeasure];
    NSString *units = @"";
    if (unitOfMeasure)
        units = [NSString stringWithFormat:@"%@(%@)", [unitOfMeasure measure], [unitOfMeasure unitAbbreviation]];
    [[cell detailTextLabel] setText:units];
}

- (void)configureReminderCell:(UITableViewCell *)cell
{
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setText:NSLocalizedString(@"Reminder",nil)];
    NSString *reminderDate = @"";
    if ([[self item] reminderDate]) 
        reminderDate = formatted_relative_date([[self item] reminderDate]);
    [[cell detailTextLabel] setText:reminderDate];

}

- (void)configureActionsCell:(UITableViewCell *)cell
{
    EditItemActionsView *actionView = [[EditItemActionsView alloc] initWithItem:[self item] frame:CGRectMake(0.0f, 0.0f, 300.0f, 100.0f)];
    [actionView setDelegate:self];
    [[cell contentView] addSubview:actionView];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

#pragma mark edit item delegate method

- (void)editItemViewController:(UIViewController *)editViewController didChangeValue:(id)updatedValue forItem:(MetaListItem *)item
{
    [[self item] save];
}

#pragma mark - edit item actions delegate methods

- (void)markCompleteRequestedFromEditItemActionsView:(EditItemActionsView *)view
{
    if ([[self item] isComplete])
        [[self item] setIsComplete:NO];
    else
        [[self item] setIsComplete:YES];
    [[self item] save];
}

- (void)deleteRequestedFromEditItemActionsView:(EditItemActionsView *)view
{
    [[[self item] list] deleteItem:[self item]];
    [[self navigationController] popViewControllerAnimated:YES];
}

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

