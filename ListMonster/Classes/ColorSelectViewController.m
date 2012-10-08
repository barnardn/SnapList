//
//  ColorSelectViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/23/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "ColorSelectViewController.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"

@implementation ColorSelectViewController

@synthesize allColors, theList, lastSelectedIndexPath;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithList:(MetaList *)aList{
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
    [self setTheList:aList];
    
    NSArray *colors = [[ListMonsterAppDelegate sharedAppDelegate] allColors];
    [self setAllColors:colors];
    return self;
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



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLastSelectedIndexPath:nil];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Backgrounds/normal"]];
    [[self tableView] setBackgroundView:backgroundView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self allColors] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ListColor *color = [[self allColors] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[color name]];
    [[cell textLabel] setTextColor:[color uiColor]];
    
    NSNumber *selectRgb = [[[self theList] color] rgbValue];
    BOOL isSelectedColor = (NSOrderedSame == [[color rgbValue] compare:selectRgb]);
    if (isSelectedColor && ![self lastSelectedIndexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setLastSelectedIndexPath:indexPath];
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath row] == [[self lastSelectedIndexPath] row]) return;
    ListColor *color = [[self allColors] objectAtIndex:[indexPath row]];
    [[self theList] setColor:color];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[self lastSelectedIndexPath]];
    [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [lastCell setAccessoryType:UITableViewCellAccessoryNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setLastSelectedIndexPath:indexPath];

}

@end

