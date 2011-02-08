//
//  EditListViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "Category.h"
#import "CategorySelectViewController.h"
#import "ColorSelectViewController.h"
#import "EditListViewController.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "ListNameViewController.h"
#import "MetaList.h"

@implementation EditListViewController

@synthesize theList;

#pragma mark -
#pragma mark Initialization

- (id)initWithList:(MetaList *)aList {
    if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
        return nil;
    [self setTheList:aList];
    if (!aList) {
        NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
        NSEntityDescription *listEntity = [NSEntityDescription entityForName:@"MetaList" inManagedObjectContext:moc];
        MetaList *l = [[MetaList alloc] initWithEntity:listEntity insertIntoManagedObjectContext:moc];
        [self setTheList:l];
        [l release];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithList:nil];
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
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"list back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil action:nil];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStyleDone 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"Edit List", @"editlist view title")];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:doneBtn];
    [cancelBtn release];
    [doneBtn release];
    [backBtn release];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] reloadData];    // may be able to eliminate this...
}

#pragma mark -
#pragma mark button item actions

- (void)cancelPressed:(id)sender {
    [[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext] rollback];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}


- (void)donePressed:(id)sender {
    NSError *error = nil;
    [[[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext] save:&error];
    if (error) {
        [ErrorAlert showWithTitle:NSLocalizedString(@"Error", @"error title")
                       andMessage:NSLocalizedString(@"The changes list could not be saved.", @"cant save list message")];
        DLog(@"Unable to save list: %@", [error localizedDescription]);
    }
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
}


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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    NSInteger selectorIdx = [indexPath section];
    SEL configSelector = NSSelectorFromString([cellConfigSelectors objectAtIndex:selectorIdx]);
    return [self performSelector:configSelector withObject:cell];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *nextNavSelectors = [NSArray arrayWithObjects:@"pushNameEditView", @"pushColorSelectView", @"pushCategoryEditView",nil];
    NSInteger sectionIdx = [indexPath section];
    NSString *selString = [nextNavSelectors objectAtIndex:sectionIdx];
    if ([selString compare:@""] == NSOrderedSame)
        return;
    SEL selector = NSSelectorFromString([nextNavSelectors objectAtIndex:sectionIdx]);
    [self performSelector:selector];
}


#pragma mark -
#pragma mark Cell configuration methods

- (UITableViewCell *)cellAsNameCell:(UITableViewCell *)cell {
    NSString *cellTitle = NSLocalizedString(@"Name", @"name cell title");
    NSString *cellText = nil;
    if (![[self theList] name])
        cellText = NSLocalizedString(@"Name", @"empty list name placeholder");
    else
        cellText = [[self theList] name];

    [[cell textLabel] setText:cellTitle];
    [[cell detailTextLabel] setText:cellText];
    return cell;

}

- (UITableViewCell *)cellAsColorCell:(UITableViewCell *)cell {

    NSString *cellTitle = NSLocalizedString(@"Color", @"color cell title");
    NSString *colorName = [[[self theList] color] name];
    UIColor *textColor = [[[self theList] color] uiColor];
    [[cell textLabel] setText:cellTitle];
    [[cell detailTextLabel] setText:colorName];
    [[cell detailTextLabel] setTextColor:textColor];
    return cell;
}

- (UITableViewCell *)cellAsCategoryCell:(UITableViewCell *)cell {
    
    Category *category = [[self theList] category];
    [[cell textLabel] setText:NSLocalizedString(@"Category", @"select a category prompt")];
    [[cell detailTextLabel] setText:[category name]];
    return cell;
}

#pragma mark -
#pragma mark Methods that push in the next view controller

- (void)pushNameEditView {
    ListNameViewController *lnvc = [[ListNameViewController alloc] initWithList:[self theList]];
    [[self navigationController] pushViewController:lnvc animated:YES];
    [lnvc release];
}

- (void)pushColorSelectView {
    ColorSelectViewController *csvc = [[ColorSelectViewController alloc] initWithList:[self theList]];
    [[self navigationController] pushViewController:csvc animated:YES];
    [csvc release];
    
}

- (void)pushCategoryEditView {
    CategorySelectViewController *cvc = [[CategorySelectViewController alloc] initWithList:[self theList]];
    [[self navigationController] pushViewController:cvc animated:YES];
    [cvc release];
}



@end

