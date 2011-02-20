//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditListItemViewController.h"
#import "EditTextViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSNumberExtensions.h"

@interface EditListItemViewController()

- (void)doneBtnPressed:(id)sender;
- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section;
- (void)prepareProperties;
- (void)didSelectItemCellAtIndex:(NSInteger)section;
- (void)didSelectButtonCellAtIndex:(NSInteger)section;
- (void)savePendingItemChanges;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization


@synthesize theItem, theList, itemProperties, editViewController, editProperty;
@synthesize hasDirtyProperties;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem {
    
    self= [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:list];
    [self setTheItem:listItem];
    [self prepareProperties];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return nil;
}

- (void)prepareProperties {
    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Name", @"title",
                                     [[self theItem] name], @"value", @"name", @"kvc-key", nil];
    
    NSNumber *qty = [[self theItem] quantity];
    NSString *qtyString = ([qty compare:INT_OBJ(0)] == NSOrderedSame) ? @"" : [qty stringValue];
    NSMutableDictionary *qtyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quantity", @"title",
                                    qtyString, @"value", @"quantity", @"kvc-key", nil];
    NSArray *properties = [NSArray arrayWithObjects:nameDict, qtyDict, nil];
    [self setItemProperties:properties];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [itemProperties release];
    [theItem release];
    [theList release];
    [editViewController release];
    [editProperty release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *viewTitle = [[self theItem] name];
    [[self navigationItem] setTitle:viewTitle];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",@"done button")
                                                            style:UIBarButtonItemStyleDone 
                                                           target:self 
                                                           action:@selector(doneBtnPressed:)];
    [[self navigationItem] setRightBarButtonItem:btn];
    [btn release];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![self editViewController]) return;
    if (![self editProperty]) return;
    
    NSString *valueString = [[self editViewController] returnString];
    if (!valueString || [valueString isEqualToString:@""]) {
        NSString *key = [[self editProperty] valueForKey:@"kvc-key"];
        if ([key isEqualToString:@"name"]) {
            NSString *ttl = NSLocalizedString(@"Bad Value", @"error title");
            NSString *msg = NSLocalizedString(@"A list item must have a name", @"list item required name error");
            [ErrorAlert showWithTitle:ttl andMessage:msg];
            [self setEditViewController:nil];
            [self setEditProperty:nil];
            return;
        }
    }
    [[self editProperty] setObject:valueString forKey:@"value"];
    [self setHasDirtyProperties:YES];
    [self setEditViewController:nil];
    [self setEditProperty:nil];
    [[self tableView] reloadData];
}


#pragma mark -
#pragma mark Actions

- (IBAction)doneBtnPressed:(id)sender {
    
    if (![self hasDirtyProperties]) {
        [[self navigationController] popViewControllerAnimated:YES];
        return;
    }
    [[self itemProperties] forEach:^ void (id obj) {
        NSDictionary *pd = obj;
        NSString *propKey = [pd valueForKey:@"kvc-key"];
        NSString *propVal = [pd valueForKey:@"value"];
        if ([propKey isEqualToString:@"quantity"]) {
            NSNumber *qty = [NSNumber numberWithString:propVal];
            if (qty) [[self theItem] setQuantity:qty];
        } else {
            [[self theItem] setValue:propVal forKey:propKey];
        }
    }];
    [self savePendingItemChanges];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self itemProperties] count] + 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    NSString *cellId = ButtonCellIdentifier;
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    
    NSInteger sectionIdx = [indexPath section];
    BOOL isListItemCell = (sectionIdx < ([[self itemProperties] count]));
    if (isListItemCell) {
        cellId = CellIdentifier;
        cellStyle = UITableViewCellStyleValue1;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellId] autorelease];
    
    if (isListItemCell) {
        NSDictionary *propDict = [[self itemProperties] objectAtIndex:sectionIdx];
        if ([propDict valueForKey:@"value"] != [NSNull null]) {
            [[cell detailTextLabel] setText:[propDict valueForKey:@"value"]];
        }  
        [[cell textLabel] setText:[propDict valueForKey:@"title"]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [self configureCell:cell asButtonInSection:sectionIdx];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section {
    
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
    NSString *titleText; 
    if (section == [[self itemProperties] count])
        titleText = NSLocalizedString(@"Mark as Complete", @"completion text");
    else {
        titleText = NSLocalizedString(@"Delete", @"delete item text");
        [cell setBackgroundColor:[UIColor redColor]];
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [[cell textLabel] setText:titleText];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger sectionIdx = [indexPath section];
    if ( sectionIdx < [[self itemProperties] count])
        [self didSelectItemCellAtIndex:sectionIdx];
    else 
        [self didSelectButtonCellAtIndex:sectionIdx];

}

- (void)didSelectItemCellAtIndex:(NSInteger)section  {
    NSMutableDictionary *propDict = [[self itemProperties] objectAtIndex:section];
    EditTextViewController *etvc = [[EditTextViewController alloc] initWithViewTitle:[propDict valueForKey:@"title"] 
                                                                            editText:[propDict valueForKey:@"value"]];
    NSString *propertyKey = [propDict valueForKey:@"kvc-key"];
    if ([propertyKey isEqualToString:@"quantity"])
        [etvc setNumericEntryMode:YES];
    [self setEditProperty:propDict];
    [self setEditViewController:etvc];
    [[self navigationController] pushViewController:etvc animated:YES];
}

- (void)didSelectButtonCellAtIndex:(NSInteger)section {
 
    NSInteger completeButtonIdx = [[self itemProperties] count];
    if (section == completeButtonIdx) {
        [[self theItem] setIsChecked:INT_OBJ(1)];
    } else {
        NSMutableSet *items = [[self theList] mutableSetValueForKey:@"items"];
        [items removeObject:[self theItem]];
    }
    [self savePendingItemChanges];
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)savePendingItemChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save item: %@", [error localizedDescription]);
    }
}
             
             

@end

