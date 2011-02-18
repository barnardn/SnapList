//
//  EditListItemViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "EditListItemViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSNumberExtensions.h"

@interface EditListItemViewController()

- (void)doneBtnPressed:(id)sender;
- (void)configureCell:(UITableViewCell *)cell asButtonInSection:(NSInteger)section;

@end

@implementation EditListItemViewController


#pragma mark -
#pragma mark Initialization


@synthesize theItem, theList, itemProperties;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem {
    
    self= [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheList:list];
    [self setTheItem:listItem];
    NSArray *properties = [NSArray arrayWithObjects:[listItem name], 
                      (!([listItem quantity]) ? @"" : [[listItem quantity] stringValue]),
                      nil];
    [self setItemProperties:properties];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return nil;
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
    [super dealloc];
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *viewTitle = [[self theItem] name];
    [[self navigationItem] setTitle:viewTitle];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    [[self navigationItem] setRightBarButtonItem:btn];
    [btn release];
}

#pragma mark -
#pragma mark Actions

- (IBAction)doneBtnPressed:(id)sender {
    // TODO: also must add a new item to the MetaList's items collection!
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save list item: %@", [error localizedDescription]);
    }
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSInteger sectionIdx = [indexPath section];
    if (sectionIdx < [[self itemProperties] count]) {
        NSString *cellText = [[self itemProperties] objectAtIndex:sectionIdx];
        [[cell textLabel] setText:cellText];
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
    [[cell textLabel] setText:titleText];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}



@end

