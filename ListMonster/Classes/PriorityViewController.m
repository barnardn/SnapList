//
//  PriorityViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 7/5/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "MetaListItem.h"
#import "PriorityViewController.h"
#import "Tuple.h"

@implementation PriorityViewController

@synthesize priorityList, theItem, backgroundImageFilename;

#pragma mark -
#pragma mark Initialization


-(id)initWithTitle:(NSString *)aTitle listItem:(MetaListItem *)anItem;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setTheItem:anItem];
    NSArray *priorities = [NSArray arrayWithObjects:[Tuple tupleWithFirst:INT_OBJ(-1) second:@"Low"],
                           [Tuple tupleWithFirst:INT_OBJ(0) second:@"Normal"],
                           [Tuple tupleWithFirst:INT_OBJ(1) second:@"High"],
                           nil];
    [self setPriorityList:priorities];
    lastIndexPath = nil;
    return self;
    
}

- (id)initWithStyle:(UITableViewStyle)style 
{
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
    [self setPriorityList:nil];
    [self setTheItem:nil];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"Priority", nil)];
    if ([self backgroundImageFilename]) {
        [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageFilename]]]];
    }
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return [[self priorityList] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    Tuple *t = [[self priorityList] objectAtIndex:[indexPath row]];
    NSNumber *priorityVal = [t first];
    NSNumber *itemPriority = [[self theItem] priority];
    if (!itemPriority)
        itemPriority = INT_OBJ(0);
    if ([priorityVal isEqualToNumber:itemPriority] && !lastIndexPath) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        lastIndexPath = indexPath;
    }
    NSString *priorityName = [t second];
    [[cell textLabel] setText:priorityName];
    [[cell imageView] setImage:[UIImage imageNamed:priorityName]];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath row] == [lastIndexPath row]) return;
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    DLog(@"cell text: %@", [[cell textLabel] text]);
    UITableViewCell *lastCell = [[self tableView ]  cellForRowAtIndexPath:lastIndexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [lastCell setAccessoryType:UITableViewCellAccessoryNone];
    Tuple *t = [[self priorityList] objectAtIndex:[indexPath row]];
    NSNumber *priorityVal = [t first];
    [[self theItem] setPriority:priorityVal];
    lastIndexPath = indexPath;
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}




@end

