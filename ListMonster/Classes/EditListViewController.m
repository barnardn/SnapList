//
//  EditListViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "CategoryViewController.h"
#import "EditListViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "Category.h"

@implementation EditListViewController

@synthesize theList;

#pragma mark -
#pragma mark Initialization

- (id)initWithList:(MetaList *)l {
    if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
        return nil;
    [self setTheList:l];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithList:nil];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"list back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";   
    NSArray *cellConfigSelectors = [NSArray arrayWithObjects:@"cellAsNameCell:", @"cellAsColorCell:", @"cellAsCategoryCell:",nil];
    
    /*{
        @selector(cellAsNameCell:), @selector(cellAsColorCell:), @selector(cellAsCategoryCell:)
    };*/
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    NSInteger selectorIdx = [indexPath section];
    SEL configSelector = NSSelectorFromString([cellConfigSelectors objectAtIndex:selectorIdx]);
    return [self performSelector:configSelector withObject:cell];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CategoryViewController *cvc = [[CategoryViewController alloc] initWithCategory:nil];
    [[self navigationController] pushViewController:cvc animated:YES];
    [cvc release];
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
    [theList release];
    [super dealloc];
}

#pragma mark -
#pragma mark Cell configuration methods

- (UITableViewCell *)cellAsNameCell:(UITableViewCell *)cell {
    
    NSString *cellText = nil;
    if (![[self theList] name]) {
        [[cell textLabel] setTextColor:[UIColor grayColor]];
        cellText = NSLocalizedString(@"List Name", @"empty list name placeholder");
    } else {
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        cellText = [[self theList] name];
    }
    [[cell textLabel] setText:cellText];
    return cell;

}

- (UITableViewCell *)cellAsColorCell:(UITableViewCell *)cell {
    
    NSArray *cellTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Black", @"black"),
                                  NSLocalizedString(@"Red", @"red"), NSLocalizedString(@"Green", @"green"),
                                  NSLocalizedString(@"Blue", @"blue"), NSLocalizedString(@"Gold", @"gold"),
                                  NSLocalizedString(@"Turquoise", @"turquoise"), NSLocalizedString(@"Orange", @"orange"),
                                  NSLocalizedString(@"Magenta", @"magenta"), nil];
    NSInteger colorIdx = [[[self theList] colorCode] intValue];
    [[cell textLabel] setText:[cellTitles objectAtIndex:colorIdx]];
    return cell;
}

- (UITableViewCell *)cellAsCategoryCell:(UITableViewCell *)cell {
    
    Category *category = [[self theList] category];
    if (!category) {
        [[cell textLabel] setText:NSLocalizedString(@"Select Category", @"select a category prompt")];
        [[cell textLabel] setTextColor:[UIColor grayColor]];
        return cell;
    }
    [[cell textLabel] setText:[category name]];
    [[cell textLabel] setTextColor:[UIColor blackColor]];
    return cell;
}



@end

