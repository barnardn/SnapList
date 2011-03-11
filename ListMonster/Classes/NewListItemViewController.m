//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditTextViewController.h"
#import "NewListItemViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListColor.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSNumberExtensions.h"

@interface NewListItemViewController()

- (void)prepareProperties;
- (void)doneBtnPressed:(id)sender;
- (void)cancelBtnPressed:(id)sender;

@end


@implementation NewListItemViewController

@synthesize theList, itemProperties, editPropertyIndex, editViewController;
@synthesize hasDirtyProperties;

- (id)initWithList:(MetaList *)list {
    
    self= [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:list];
    [self prepareProperties];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return nil;
}

- (void)prepareProperties {
    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Name", @"title",
                                     [NSNull null], @"value", nil];
    NSMutableDictionary *qtyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quantity", @"title",
                                    [NSNull null], @"value", nil];
    NSArray *properties = [NSArray arrayWithObjects:nameDict, qtyDict, nil];
    [self setItemProperties:properties];
}

- (void)dealloc {
    [itemProperties release];
    [theList release];
    [editViewController release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"New Item", @"new list item title")];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    [[self navigationItem] setRightBarButtonItem:btn];
    [btn release];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBtnPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [cancelBtn release];
    [[self view] setBackgroundColor:[[[self theList] color] uiColor]];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self editViewController] || [self editPropertyIndex] < 0) return;
    NSMutableDictionary *propDict = [[self itemProperties] objectAtIndex:[self editPropertyIndex]];
    NSString *strValue = [[self editViewController] returnString];
    if (strValue) {
        [propDict setValue:strValue forKey:@"value"];
        [self setHasDirtyProperties:YES];
    }
    [self setEditViewController:nil];
    [self setEditPropertyIndex:-1];
    [[self tableView] reloadData];
}


- (IBAction)cancelBtnPressed:(id)sender {
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneBtnPressed:(id)sender {
    if (![self hasDirtyProperties]) {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
        return;
    }
    NSString *itemName = [[[self itemProperties] objectAtIndex:0] valueForKey:@"value"];
    if (!itemName) {
        NSString *msgTitle = NSLocalizedString(@"Bad Value", @"bad value title");
        NSString *msgText = NSLocalizedString(@"An item must have a proper name", @"missing name error");
        [ErrorAlert showWithTitle:msgTitle andMessage:msgText];
        return;
    }
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"MetaListItem" inManagedObjectContext:moc];
    MetaListItem *newItem = [[MetaListItem alloc] initWithEntity:itemEntity insertIntoManagedObjectContext:moc];    
    [newItem setName:itemName];
    id qtyString = [[[self itemProperties] objectAtIndex:1] valueForKey:@"value"];
    if (qtyString != [NSNull null])
        [newItem setQuantity:[NSNumber numberWithString:qtyString]];
    NSMutableSet *items = [[self theList] mutableSetValueForKey:@"items"];
    [items addObject:newItem];
    [newItem release];
    
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save list item: %@", [error localizedDescription]);
    }
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark Tableview data source 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self itemProperties] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId];        
    }
    NSInteger sectionIdx = [indexPath section];
    NSDictionary *propDict = [[self itemProperties] objectAtIndex:sectionIdx];
    if ([propDict valueForKey:@"value"] != [NSNull null]) {
        [[cell detailTextLabel] setText:[propDict valueForKey:@"value"]];
    }
    [[cell textLabel] setText:[propDict valueForKey:@"title"]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark -
#pragma mark Tableview Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self setEditPropertyIndex:[indexPath section]];
    NSDictionary *propDict = [[self itemProperties] objectAtIndex:[self editPropertyIndex]];
    NSString *propValue = ([propDict valueForKey:@"value"] != [NSNull null]) ? [propDict valueForKey:@"value"] : @"";
    EditTextViewController *editVc = [[EditTextViewController alloc] initWithViewTitle:[propDict valueForKey:@"title"] editText:propValue];
    [editVc setBackgroundColor:[[[self theList] color] uiColor]];
    if ([self editPropertyIndex] == 1) // quantity
        [editVc setNumericEntryMode:YES];
    [[self navigationController] pushViewController:editVc animated:YES];
    [self setEditViewController:editVc];
}

@end
