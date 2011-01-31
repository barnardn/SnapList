//
//  SettingsViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/30/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "SettingsViewController.h"

#import "CategoryViewController.h"
#import "SettingItem.h"
#import "SettingViewProtocol.h"

@implementation SettingsViewController

@synthesize settingsMap, settingsKeys;

#pragma mark -
#pragma mark Initialization

- (id)init {
    
    if (!(self = [super initWithStyle:UITableViewStyleGrouped])) return nil;
    SettingItem *categorySetting = [[SettingItem alloc] initWithItemTitle:NSLocalizedString(@"Categories", @"categories item title")
                                                      viewControllerClass:[CategoryViewController class]];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:categorySetting, @"categories", nil];
    [self setSettingsMap:settings];
    
    NSArray *keys = [[self settingsMap] allKeys];
    [self setSettingsKeys:[keys sortedArrayUsingSelector:@selector(compare:)]];
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self init];
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
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"settings back button title")
                                                                style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backBtn];
    [backBtn release];
    [[self navigationItem] setTitle:NSLocalizedString(@"Settings", @"settings view title")];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self settingsMap] count];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    NSString *settingKey = [[self settingsKeys] objectAtIndex:[indexPath row]];
    SettingItem *setting = [[self settingsMap] objectForKey:settingKey];
    [[cell textLabel] setText:[setting itemTitle]];
    [[cell detailTextLabel] setText:[setting detailTitle]];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *settingKey = [[self settingsKeys] objectAtIndex:[indexPath row]];
    SettingItem *setting = [[self settingsMap] objectForKey:settingKey];
    Class settingController = [setting viewControllerClass];
    UIViewController<SettingViewProtocol> *vc = [[settingController alloc] initWithInfo:[setting viewControllerInfo]];
    [[self navigationController] pushViewController:vc animated:YES];
    [vc release];
}


@end

