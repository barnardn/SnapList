//
//  ListItemsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "EditListItemViewController.h"
#import "ListMonsterAppDelegate.h"
#import "ListItemsViewController.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NewListItemViewController.h"

@interface ListItemsViewController()

- (UITableViewCell *)makeCellWithCheckboxButton;
- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(UITableViewCell *)cell;
- (void)editBtnPressed:(id)sender;
- (void)commitAnyChanges;
- (void)rollbackAnyChanges;
- (void)toggleCancelButton:(BOOL)editMode;
- (void)cancelBtnPressed:(id)sender; 

@end


@implementation ListItemsViewController

@synthesize allItemsTableView, theList, checkedState, addItemBtn, moreActionsBtn;
@synthesize toolBar,inEditMode, listItems, editBtn;


- (id)initWithList:(MetaList *)aList {
    self = [super initWithNibName:@"ListItemsView" bundle:nil];
    if (!self) return nil;
    [self setTheList:aList];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setEditBtn:nil];
}


- (void)dealloc {
    [listItems release];
    [allItemsTableView release];
    [theList release];
    [checkedState release];
    [addItemBtn release];
    [moreActionsBtn release];
    [toolBar release];
    [editBtn release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setTitle:[[self theList] name]];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"edit button") 
                                                                style:UIBarButtonItemStyleDone 
                                                               target:self 
                                                               action:@selector(editBtnPressed:)];
    [self setEditBtn:btn];
    [[self navigationItem] setRightBarButtonItem:[self editBtn]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSArray *allItems = [[[self theList] items] allObjects];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]; 
    [self setListItems:[allItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:byName]]];
    [editItemNavController release], editItemNavController = nil;
    [[self allItemsTableView] reloadData];
}

#pragma mark -
#pragma mark Button action

-(IBAction)addItemBtnPressed:(id)sender {
    NewListItemViewController *eivc = [[NewListItemViewController alloc] initWithList:[self theList]];
    editItemNavController = [[UINavigationController alloc] initWithRootViewController:eivc];
    [self presentModalViewController:editItemNavController animated:YES];
    [eivc release];
}

-(IBAction)moreActionsBtnPressed:(id)sender {
    
}

- (void)cancelBtnPressed:(id)sender {
    [self setInEditMode:NO];
    [self rollbackAnyChanges];
    [[self editBtn] setTitle:NSLocalizedString(@"Edit", @"edit button")];
    [self toggleCancelButton:[self inEditMode]];
    [[self allItemsTableView] setEditing:NO animated:YES];
}

- (IBAction)checkedStateValueChanged:(id)sender {
    
}


- (void)editBtnPressed:(id)sender {
    
    if ([self inEditMode]) {
        [self setInEditMode:NO];
        [[self editBtn] setTitle:NSLocalizedString(@"Edit", @"edit button")];
        [self commitAnyChanges];
    } else {
        [self setInEditMode:YES];
        [[self editBtn] setTitle:NSLocalizedString(@"Done", @"done button")];
    }
    [[self allItemsTableView] setEditing:[self inEditMode] animated:YES];
    [self toggleCancelButton:[self inEditMode]];
}

- (void)toggleCancelButton:(BOOL)editMode {
    
    UIBarButtonItem *cancelBtn = nil;
    if (editMode)
        cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"cancel button title") 
                                                     style:UIBarButtonItemStyleDone 
                                                    target:self 
                                                    action:@selector(cancelBtnPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
}


#pragma mark -
#pragma mark Table data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self theList] items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [self makeCellWithCheckboxButton];
    }
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item name]];
    NSNumber *qty = [item quantity];
    NSString *qtyString = ([qty compare:INT_OBJ(0)] == NSOrderedSame) ? @"" : [qty stringValue]; 
    [[cell detailTextLabel] setText:qtyString];
    [self updateCheckboxButtonForItem:item atCell:cell];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *indexedObjects = [[[self theList] items] allObjects];
        MetaListItem *deleteItem = [indexedObjects objectAtIndex:[indexPath row]];
        NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
        [moc deleteObject:deleteItem];
    }
}
        
#pragma mark -
#pragma mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];    
    EditListItemViewController *eivc = [[EditListItemViewController alloc] initWithList:[self theList] editItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
    [eivc release];
}

/*
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    NewListItemViewController *eivc = [[NewListItemViewController alloc] initWithList:[self theList] editItem:item];
    [[self navigationController] pushViewController:eivc animated:YES];
    [eivc release];
}
*/

#pragma mark -
#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}


#pragma mark -
#pragma mark Cell checkbox methods


- (UITableViewCell *)makeCellWithCheckboxButton {
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] autorelease];
    UIButton *checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBoxBtn.frame = CGRectMake(0.0f, 0.0f, 22.0f, 22.0f);
    [checkBoxBtn addTarget:self action:@selector(checkboxButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell setEditingAccessoryView:checkBoxBtn];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}     

- (void)updateCheckboxButtonForItem:(MetaListItem *)item atCell:(UITableViewCell *)cell {
    
    UIButton *checkBoxButton = (UIButton *)[cell editingAccessoryView];
    BOOL isChecked = ([[item isChecked] intValue] == 0);
    NSString *stateImageFile = (isChecked) ? @"checked.png" : @"unchecked.png";
    [checkBoxButton setImage:[UIImage imageNamed:stateImageFile] forState:UIControlStateNormal];    
}


- (void)checkboxButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
    
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *indexPath = [[self allItemsTableView] indexPathForCell:cell];
    MetaListItem *item = [[self listItems] objectAtIndex:[indexPath row]];
    BOOL isChecked = [[item isChecked] intValue] == 0;
    NSNumber *checkedValue = (isChecked) ? INT_OBJ(1) : INT_OBJ(0);
    [item setIsChecked:checkedValue];
    [self updateCheckboxButtonForItem:item atCell:cell];
}

#pragma mark -
#pragma mark Commit moc changes

- (void)commitAnyChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    if (![moc hasChanges]) return;
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to save changes: %@", [error localizedDescription]);
    }
}

- (void)rollbackAnyChanges {
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    if (![moc hasChanges]) return;
    [moc rollback];
}

@end
