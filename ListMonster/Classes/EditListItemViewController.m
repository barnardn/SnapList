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

@interface EditListItemViewController()

- (NSString *)listItem:(MetaListItem *)item stringForAttribute:(NSString *)attrName;
- (UITableView *)tableView;
- (void)toggleCompletedState;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization

@synthesize editPropertySections, delegate;
@synthesize backgroundImageFilename, listItemTableView, toolBar;

- (id)initWithItem:(MetaListItem *)item
{
    self = [super init];
    if (!self) return nil;
    _item = item;
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
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main"]]];
}


- (void)preparePropertySections 
{    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item", @"title",
                                     @"name", @"attrib", [EditTextViewController class], @"vc", nil];
    NSMutableDictionary *qtyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quantity", @"title",
                                    @"quantity", @"attrib", [EditNumberViewController class], @"vc", nil];
    NSMutableDictionary *reminderDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Reminder", @"title",
                                         @"reminderDate", @"attrib", [ReminderViewController class], @"vc", nil];
    NSMutableDictionary *unitDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Units", @"title",
                                     @"unitOfMeasure", @"attrib", [EditMeasureViewController class], @"vc", nil];
    NSArray *sects = @[nameDict,qtyDict, unitDict, reminderDict];
    [self setEditPropertySections:sects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    // reload table based on selected index path
    
    /*
    if ([[self theItem] isUpdated] || [[self theItem] isInserted])
        [[self tableView] reloadData];
     */
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
    return 44.0f;       // set table row height to a constant. 
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
    /*
    skipSaveLogic = YES;
    NSMutableDictionary *sectDict = [self editPropertySections][[indexPath section]];
    Class vcClass = sectDict[@"vc"];
    NSString *viewTitle = sectDict[@"title"];
    UIViewController<EditItemViewProtocol> *vc = [[vcClass alloc ] initWithTitle:viewTitle listItem:[self theItem]];
    [[self navigationController] pushViewController:vc animated:YES];
      // prof rcmd
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    */
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
    [[cell textLabel] setText:NSLocalizedString(@"Units", nil)];
    Measure *unitOfMeasure = [[self item] unitOfMeasure];    
    if (!unitOfMeasure) return;
    NSString *units = [NSString stringWithFormat:@"%@(%@)", [unitOfMeasure measure], [unitOfMeasure unitAbbreviation]];

    [[cell detailTextLabel] setText:units];
}

- (void)configureReminderCell:(UITableViewCell *)cell
{
    [[cell textLabel] setText:@"Reminder"];
    if (![[self item] reminderDate]) return;
    NSString *reminderDate = formatted_relative_date([[self item] reminderDate]);
    [[cell detailTextLabel] setText:reminderDate];

}

#pragma mark -
#pragma mark ActionSheet delegate and ActionSheet

-(IBAction)moreActionsBtnPressed:(id)sender {
    
    NSString *markTitle = ([[self item] isComplete]) ? NSLocalizedString(@"Mark As Incomplete",nil) : NSLocalizedString(@"Mark As Complete",nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More Actions", @"more actions title") 
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel action button")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
                                                    otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:markTitle];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Quick Stash",nil)];
    [actionSheet showFromToolbar:[self toolBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex < 0) return;
    BOOL saveRequired = YES;
    DLog(@"buttonIndex: %d : %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    switch (buttonIndex) {
        case 0:        // delete
            [self deleteItem];
            break;
        case 1:
            saveRequired = NO;
            break;
        case 2:
            [self toggleCompletedState];
            break;	
    }
    [[self navigationController] popViewControllerAnimated:YES];

}

- (void)deleteItem
{
    MetaList *list = [[self item] list];
    [list deleteItem:[self item]];
}

- (void)toggleCompletedState
{
    BOOL checkedState = ([[self item] isComplete]) ? NO : YES;
    [[self item] setIsComplete:checkedState];
    [[self item] save];
}


@end

