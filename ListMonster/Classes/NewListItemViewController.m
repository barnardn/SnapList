//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditTextViewController.h"
#import "ItemStash.h"
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
- (UITableViewCell *)stashButtonCellForTableView:(UITableView *)tableView;
- (void)handleStashButtonAtIndexPath:(NSIndexPath *)indexPath;

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
    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item", @"title",
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
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [cancelBtn release];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
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
        NSString *msgText = NSLocalizedString(@"An item must have a proper description", @"missing name error");
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
    return [[self itemProperties] count] + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] >= [itemProperties count]) return [self stashButtonCellForTableView:tableView];
    
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId] autorelease];        
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

- (UITableViewCell *)stashButtonCellForTableView:(UITableView *)tableView {
    
    static NSString *stashCellId = @"StashCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stashCellId];
    if (cell) return cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stashCellId];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIImage *selectedButtonImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:buttonImage];
    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedButtonImage];
    [cell setBackgroundView:backgroundView];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    [backgroundView release];
    [selectedBackgroundView release];
    
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell textLabel] setText:NSLocalizedString(@"Add To Quick Stash", @"quick stash add button text")];
    return cell;
}



#pragma mark -
#pragma mark Tableview Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] >= [itemProperties count]) return [self handleStashButtonAtIndexPath:indexPath];
    
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

- (void)handleStashButtonAtIndexPath:(NSIndexPath *)indexPath {
    
    id nameValue = [[[self itemProperties] objectAtIndex:0] valueForKey:@"value"];
    if (nameValue == [NSNull null]) return;    
    NSString *stashedName = nameValue;
    NSNumber *stashedNumber = nil;
    id qtyString = [[[self itemProperties] objectAtIndex:1] valueForKey:@"value"];
    if (qtyString != [NSNull null])
        stashedNumber = [NSNumber numberWithString:qtyString];
    [ItemStash addToStash:stashedName quantity:stashedNumber];
    UITableViewCell *stashButton = [[self tableView] cellForRowAtIndexPath:indexPath];
    [stashButton setSelected:NO];
}


@end
