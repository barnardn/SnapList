//
//  CategorySelectViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/24/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "CategorySelectViewController.h"
#import "ListMonsterAppDelegate.h"

@implementation CategorySelectViewController

@synthesize allCategories, selectedCategory;

#pragma mark -
#pragma mark Initialization


- (id)initWithCategory:(Category *)defaultCategory {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setSelectedCategory:defaultCategory];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithCategory:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setAllCategories:nil];
    [self setSelectedCategory:nil];
}

- (void)dealloc {
    [allCategories release];
    [selectedCategory release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *categories = [[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"Category" orderedBy:@"name"];
    [self setAllCategories:categories];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStyleDone 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button")
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [[self navigationItem] setTitle:NSLocalizedString(@"Select Category", @"category selection only view title")];
    [cancelBtn release];
    [doneBtn release];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Button actions

- (void)cancelPressed:(id)sender {
    [self setSelectedCategory:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)donePressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (Category *)returnValue {
    return [self selectedCategory];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self allCategories] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    Category *cat = [[self allCategories] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[cat name]];
    BOOL isSelectedCategory = (NSOrderedSame == [[cat name] compare:[[self selectedCategory] name]]);
    if (isSelectedCategory)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Category *category = [[self allCategories] objectAtIndex:[indexPath row]];
    [self setSelectedCategory:category];
    [[self tableView] reloadData];
}

@end

