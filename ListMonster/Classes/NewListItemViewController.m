//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "NewListItemViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSNumberExtensions.h"

@interface NewListItemViewController()

- (void)doneBtnPressed:(id)sender;
- (void)cancelBtnPressed:(id)sender;

@end


@implementation NewListItemViewController

@synthesize theItem, theList, itemProperties;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem {
    
    self= [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:list];
    [self setTheItem:listItem];
    NSArray *properties;
    if (listItem) {
        properties = [NSArray arrayWithObjects:[listItem name], 
                               (!([listItem quantity]) ? @"" : [[listItem quantity] stringValue]),
                               nil];
    } else {
        properties = [NSArray arrayWithObjects:@"Item name", @"Quantity(optional)", nil];
    }
    [self setItemProperties:properties];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return nil;
}

- (void)dealloc {
    [itemProperties release];
    [theItem release];
    [theList release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *viewTitle = ([self theItem]) ? [[self theItem] name] : NSLocalizedString(@"New Item", @"new list item title");
    [[self navigationItem] setTitle:viewTitle];

    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    [[self navigationItem] setRightBarButtonItem:btn];
    [btn release];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBtnPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [cancelBtn release];

}

- (IBAction)cancelBtnPressed:(id)sender {
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneBtnPressed:(id)sender {
    // TODO: also must add a new item to the MetaList's items collection!
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save list item: %@", [error localizedDescription]);
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark Tableview data source 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger propCount = [[self itemProperties] count];
    return ([self theItem]) ? propCount + 2 : propCount;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSInteger sectionIdx = [indexPath section];
    NSString *cellText;
    if (sectionIdx < [[self itemProperties] count]) {
        cellText = [[self itemProperties] objectAtIndex:sectionIdx];
        DLog(@"row idx: %d text: %@", sectionIdx, cellText);
    } else {
        cellText = (sectionIdx == 2) ? @"Complete Item" : @"Delete Item";
    }
    [[cell textLabel] setText:cellText];
    return cell;
}





@end
