//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "datetime_utils.h"
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

#define ROW_HEIGHT      44.0f

@interface EditListItemViewController() <EditItemViewDelegate>

- (UITableView *)tableView;

@property (nonatomic,strong) IBOutlet UITableView *listItemTableView;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) MetaListItem *item;
@property (nonatomic, strong) NSArray *editViewControllers;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization

- (id)initWithItem:(MetaListItem *)item
{
    self = [super init];
    if (!self) return nil;
    _item = item;
    _editViewControllers = @[[EditTextViewController class], [EditNumberViewController class], [EditMeasureViewController class], [ReminderViewController class]];
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
        NSString *text = [[self item] name];
        CGSize constraint = CGSizeMake(300.0f, 20000.0f);
        CGSize size = [text sizeWithFont:[ThemeManager fontForStandardListText] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return size.height + TABLECELL_VERTICAL_MARGIN;
    }
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *NameCellId = @"NameCell";
    static NSString *CellIdentifier = @"Cell";
    
    NSString *cellID = ([indexPath section] == 0) ? NameCellId : CellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        if ([indexPath section] == 0)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        else
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    switch ([indexPath section]) {
        case 0:
            [self configureItemNameCell:cell];
            break;
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    Class editControllerClass = [[self editViewControllers] objectAtIndex:[indexPath section]];
    UIViewController<EditItemViewProtocol> *vc = [[editControllerClass alloc] initWithTitle:@"Snap!list" listItem:[self item]];
    [vc setDelegate:self];
    [[self navigationController] pushViewController:vc animated:YES];
}

#pragma mark - cell configuration methods

- (void)configureItemNameCell:(UITableViewCell *)cell
{
    [[cell textLabel] setNumberOfLines:0];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    [[cell textLabel] setFont:[ThemeManager fontForStandardListText]];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [[cell textLabel] setText:[[self item] name]];
}

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
    if ([[self item] reminderDate]) return;
        reminderDate = formatted_relative_date([[self item] reminderDate]);
    [[cell detailTextLabel] setText:reminderDate];

}

#pragma mark edit item delegate method

- (void)editItemViewController:(UIViewController *)editViewController didChangeValue:(id)updatedValue forItem:(MetaListItem *)item
{
    [[self item] save];
}


@end

