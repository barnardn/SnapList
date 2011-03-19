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

@interface EditListViewController()

- (void)setupNavigationBarForModalView;
- (UIBarButtonItem *)doneButton;
- (void)doneAction;
- (void)dismissView;

@end


@implementation EditListViewController

@synthesize theList, editActionCancelled, isNewList;

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
        [self setIsNewList:YES];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithList:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [theList release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self isNewList]) {
        [self setupNavigationBarForModalView];
        return;
    }
    [[self navigationItem] setTitle:NSLocalizedString(@"Edit List", @"editlist view title")];
    [[self navigationItem] setRightBarButtonItem:[self doneButton]];
/*    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"list back button")
                                                                style:UIBarButtonItemStylePlain 
                                                               target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release]; */
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] reloadData];    // may be able to eliminate this...
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



#pragma mark -
#pragma mark modal view navigation bar methods

- (void)setupNavigationBarForModalView {
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button")
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(cancelPressed:)];
    
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    [[self navigationItem] setRightBarButtonItem:[self doneButton]];
    [cancelBtn release];
    [[self navigationItem] setTitle:NSLocalizedString(@"Add List", @"add new list view title")];
}

- (UIBarButtonItem *)doneButton {
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(donePressed:)];
    return [doneBtn autorelease];
}


#pragma mark -
#pragma mark button item actions

- (void)cancelPressed:(id)sender {
    [[[self theList] managedObjectContext] rollback];
    [self setEditActionCancelled:YES];
    [self dismissView];
}


- (void)donePressed:(id)sender {
    [self doneAction];
    [self dismissView];
}

- (void)doneAction {
    if ([self editActionCancelled]) return;
    if (![[[self theList] managedObjectContext] hasChanges]) return;
    
    NSError *error = nil;
    [[[self theList] managedObjectContext] save:&error];
    if (error) {
        [ErrorAlert showWithTitle:NSLocalizedString(@"Error", @"error title")
                       andMessage:NSLocalizedString(@"The changes list could not be saved.", @"cant save list message")];
        DLog(@"Unable to save list: %@", [error localizedDescription]);
    }
}

- (void)dismissView {
    
    if ([self isNewList])
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    else
        [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

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

