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
#import "ItemStash.h"
#import "ListMonsterAppDelegate.h"
#import "ListColor.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSNumberExtensions.h"

@interface EditListItemViewController()

- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section;
- (void)prepareProperties;
- (void)didSelectItemCellAtIndex:(NSInteger)section;
- (void)didSelectButtonCellAtIndex:(NSInteger)section;
- (void)savePendingItemChanges;
- (void)addItemEditsToStash;

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
    
    NSMutableDictionary *nameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item", @"title",
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
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil 
                                                               action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
    [[self tableView] setBackgroundColor:[[[self theList] color] uiColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
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
    if (valueString && ![valueString isEqualToString:[[self editProperty] valueForKey:@"value"]]) {
        [[self editProperty] setObject:valueString forKey:@"value"];
        [self setHasDirtyProperties:YES];
    }
    [self setEditViewController:nil];
    [self setEditProperty:nil];
    if ([self hasDirtyProperties])
        [[self tableView] reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![self hasDirtyProperties] || [self editViewController])
        return;
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
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self itemProperties] count] + elivcCOUNT_BUTTON_CELLS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
        cellStyle = UITableViewCellStyleValue2;
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
    
    UIImage *cellButtonImage;
    NSString *titleText; 
    if (section == [[self itemProperties] count]) {
        titleText = ([[self theItem] isComplete]) ? NSLocalizedString(@"Mark as Incomplete", @"mark incomplete text") : NSLocalizedString(@"Mark as Complete", @"completion text");
        cellButtonImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    } else if (section == [[self itemProperties] count] + 1) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger sectionIdx = [indexPath section];
    if ( sectionIdx < [[self itemProperties] count]) {
        [self didSelectItemCellAtIndex:sectionIdx];        
    } else  {
        [self didSelectButtonCellAtIndex:sectionIdx];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
    }


}

- (void)didSelectItemCellAtIndex:(NSInteger)section  {
    NSMutableDictionary *propDict = [[self itemProperties] objectAtIndex:section];
    EditTextViewController *etvc = [[EditTextViewController alloc] initWithViewTitle:[propDict valueForKey:@"title"] 
                                                                            editText:[propDict valueForKey:@"value"]];
    if ([[self theList] color])
        [etvc setBackgroundColor:[[[self theList] color] uiColor]];
    NSString *propertyKey = [propDict valueForKey:@"kvc-key"];
    if ([propertyKey isEqualToString:@"quantity"])
        [etvc setNumericEntryMode:YES];
    [self setEditProperty:propDict];
    [self setEditViewController:etvc];
    [[self navigationController] pushViewController:etvc animated:YES];
}

- (void)didSelectButtonCellAtIndex:(NSInteger)section {
 
    NSInteger completeButtonIdx = [[self itemProperties] count];
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


- (void)addItemEditsToStash {
    
    NSString *stashName = [[[self itemProperties] objectAtIndex:0] valueForKey:@"name"];
    NSString *qtyString = [[[self itemProperties] objectAtIndex:1] valueForKey:@"quantity"];
    NSNumber *qty = [NSNumber numberWithString:qtyString];
    if (!stashName)
        stashName = [[self theItem] name];
    if (!qty)
        qty = [[self theItem] quantity];
    
    [ItemStash addToStash:stashName quantity:qty];
}

- (void)savePendingItemChanges {
    
    NSManagedObjectContext *moc = [[self theList] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save item: %@", [error localizedDescription]);
    }
}
             
             

@end

