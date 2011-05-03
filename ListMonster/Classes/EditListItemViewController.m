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
#import "EditNumberViewController.h"
#import "EditTextViewController.h"
#import "ItemStash.h"
#import "ListMonsterAppDelegate.h"
#import "ListColor.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSNumberExtensions.h"
#import "ReminderViewController.h"

@interface EditListItemViewController()

- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section;
- (void)preparePropertySections;
- (NSString *)listItem:(MetaListItem *)item stringForAttribute:(NSString *)attrName;
- (void)didSelectItemCellAtIndex:(NSInteger)section;
- (void)didSelectButtonCellAtIndex:(NSInteger)section;
- (void)savePendingItemChanges;
- (void)addItemEditsToStash;
- (void)configureAsModalView;
- (void)configureAsChildNavigationView;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization


@synthesize theItem, theList, editPropertySections, isModal, delegate;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem 
{
    self= [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:list];
    [self setTheItem:listItem];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style 
{
    return nil;
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

- (void)dealloc 
{
    [theItem release];
    [theList release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    NSString *viewTitle = ([[self theItem] name]) ? [[self theItem] name] :  NSLocalizedString(@"New Item", @"new item title");
    [[self navigationItem] setTitle:viewTitle];
    if ([self isModal]) {
        [self configureAsModalView];
    } else {
        [self configureAsChildNavigationView];
    }
    [[self tableView] setBackgroundColor:[[[self theList] color] uiColor]];
    [self preparePropertySections];
}

- (void)configureAsModalView 
{
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button") 
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];    
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [cancelBtn release];
    [doneBtn release];
}

- (void)configureAsChildNavigationView 
{
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];    
}
 
- (void)cancelPressed:(id)sender
{
    [[self delegate] editListItemViewController:self didCancelEditOnNewItem:[self theItem]];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)donePressed:(id)sender
{
    [[self delegate] editListItemViewController:self didAddNewItem:[self theItem]];
    [self savePendingItemChanges];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)preparePropertySections 
{    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item", @"title",
                                     @"name", @"attrib", [EditTextViewController class], @"vc", nil];
    NSMutableDictionary *qtyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quantity", @"title",
                                    @"quantity", @"attrib", [EditNumberViewController class], @"vc", nil];
    NSMutableDictionary *reminderDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Reminder", @"title",
                                         @"reminderDate", @"attrib", [ReminderViewController class], @"vc", nil];
    NSArray *sects = [NSArray arrayWithObjects:nameDict, qtyDict, reminderDict, nil];
    [self setEditPropertySections:sects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if ([[self theItem] isUpdated])
        [[self tableView] reloadData];
}


- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    if ([self isModal]) return;
    [self savePendingItemChanges];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger sectCount = [[self editPropertySections] count];
    if (![self isModal])
        sectCount += elivcCOUNT_BUTTON_CELLS;
    return sectCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    NSString *cellId = ButtonCellIdentifier;
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    
    NSInteger sectionIdx = [indexPath section];
    BOOL isListItemCell = (sectionIdx < ([[self editPropertySections] count]));
    if (isListItemCell) {
        cellId = CellIdentifier;
        cellStyle = UITableViewCellStyleValue2;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId] autorelease];
    
    if (isListItemCell) {
        NSDictionary *sectDict = [[self editPropertySections] objectAtIndex:sectionIdx];
        [[cell textLabel] setText:[sectDict valueForKey:@"title"]];
        NSString *displayValue = [self listItem:[self theItem] stringForAttribute:[sectDict valueForKey:@"attrib"]];
        [[cell detailTextLabel] setText:displayValue];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [self configureCell:cell asButtonInSection:sectionIdx];
    }
    return cell;
}

- (NSString *)listItem:(MetaListItem *)item stringForAttribute:(NSString *)attrName 
{
    if (![item valueForKey:attrName]) return @"";
    id attrValue = [item valueForKey:attrName];
    if ([attrValue isKindOfClass:[NSNumber class]]) {
        NSNumber *qty = attrValue;
        return ([qty intValue] > 0) ? [qty stringValue] : @"";
    } else if ([attrValue isKindOfClass:[NSDate class]]) {
        NSDate *rmdr = attrValue;
        return formatted_date(rmdr);
    } else if ([attrValue isKindOfClass:[NSString class]]) {
        NSString *str = attrValue;
        return str;
    }
    return @"";
}


- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section 
{
    UIImage *cellButtonImage;
    NSString *titleText; 
    if (section == [[self editPropertySections] count]) {
        titleText = ([[self theItem] isComplete]) ? NSLocalizedString(@"Mark as Incomplete", @"mark incomplete text") : NSLocalizedString(@"Mark as Complete", @"completion text");
        cellButtonImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    } else if (section == [[self editPropertySections] count] + 1) {
        titleText = NSLocalizedString(@"Add To Quick Stash", @"quick stash button text");
        cellButtonImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    } else {
        titleText = NSLocalizedString(@"Delete", @"delete item text");
        cellButtonImage = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    }
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:cellButtonImage];
    UIImage *selectedBackImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIImageView *selectedBackImageView = [[UIImageView alloc] initWithImage:selectedBackImage];                              
    [cell setBackgroundView:backImageView];
    [cell setSelectedBackgroundView:selectedBackImageView];
    [backImageView release];
    [selectedBackImageView release];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [[cell textLabel] setText:titleText];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger sectionIdx = [indexPath section];
    if ( sectionIdx < [[self editPropertySections] count]) {
        [self didSelectItemCellAtIndex:sectionIdx];        
    } else  {
        [self didSelectButtonCellAtIndex:sectionIdx];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
    }
}

- (void)didSelectItemCellAtIndex:(NSInteger)section  
{
    NSMutableDictionary *sectDict = [[self editPropertySections] objectAtIndex:section];
    Class vcClass = [sectDict objectForKey:@"vc"];
    NSString *viewTitle = [sectDict objectForKey:@"title"];
    UIViewController<EditItemViewProtocol> *vc = [[vcClass alloc ] initWithTitle:viewTitle listItem:[self theItem]];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)didSelectButtonCellAtIndex:(NSInteger)section 
{
    NSInteger completeButtonIdx = [[self editPropertySections] count];
    if (section == completeButtonIdx + 1) {
        [self addItemEditsToStash];
        return;
    }
    if (section == completeButtonIdx) {
        NSNumber *checkedState = ([[self theItem] isComplete]) ? INT_OBJ(0) : INT_OBJ(1);
        [[self theItem] setIsChecked:checkedState];
    } else {
        NSMutableSet *items = [[self theList] mutableSetValueForKey:@"items"];
        [[[self theList] managedObjectContext] deleteObject:[self theItem]];
        [items removeObject:[self theItem]];
    }
    [self savePendingItemChanges];
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)addItemEditsToStash 
{
    NSString *stashName = [[[self editPropertySections] objectAtIndex:0] valueForKey:@"name"];
    NSString *qtyString = [[[self editPropertySections] objectAtIndex:1] valueForKey:@"quantity"];
    NSNumber *qty = [NSNumber numberWithString:qtyString];
    if (!stashName)
        stashName = [[self theItem] name];
    if (!qty)
        qty = [[self theItem] quantity];
    
    [ItemStash addToStash:stashName quantity:qty];
}

- (void)savePendingItemChanges 
{
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save item: %@", [error localizedDescription]);
    }
}
             
             

@end

