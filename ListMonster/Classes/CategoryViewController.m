//
//  CategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/20/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "Alerts.h"
#import "CategoryViewController.h"
#import "ListMonsterAppDelegate.h"
#import "Category.h"

@interface CategoryViewController()

- (void)deleteCategory:(Category *)category;

@end



@implementation CategoryViewController

@synthesize allCategories, selectedCategory;

#pragma mark -
#pragma mark Initialization

- (id)initWithCategory:(Category *)aCategory {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    [self setSelectedCategory:aCategory];
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
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
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    NSArray *categories = [[ListMonsterAppDelegate sharedAppDelegate] fetchAllInstancesOf:@"Category" orderedBy:@"name"];
    [self setAllCategories:[categories mutableCopy]];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCategory:)];
        [[self navigationItem] setLeftBarButtonItem:addButton];
        [addButton release];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}


- (void)addCategory:(id)sender {
    
    NSString *catName = [InputRequestor requestInputWith:@"New Category" placeHolder:@"Enter category name" keyboardType:UIKeyboardTypeDefault];
    if (!catName) return;
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    Category *newCategory = [[Category alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    [newCategory setName:catName];
    [[self allCategories] addObject:newCategory];
    [newCategory release];
    NSError *err;
    [moc save:&err];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [[self allCategories] sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    [[self tableView] reloadData];
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
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Category *category = [[self allCategories] objectAtIndex:[indexPath row]];
        [self deleteCategory:category];
        [[self allCategories] removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    /*
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    } */  
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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

#pragma mark -
#pragma mark Coredata methods

- (void)deleteCategory:(Category *)category {
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    [moc deleteObject:category];
    NSError *error;
    [moc save:&error];
    if (error) {
        [ErrorAlert showWithTitle:@"Delete Error" andMessage:[error localizedDescription]];
        DLog(@"Error deleting category: %@", [error localizedDescription]);
    }
}



@end

