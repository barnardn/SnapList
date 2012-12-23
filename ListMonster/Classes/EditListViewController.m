//
//  EditListViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//


#import "ListCategory.h"
#import "CategorySelectViewController.h"
#import "ColorSelectViewController.h"
#import "EditListViewController.h"
#import "EditNoteViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "TextFieldTableCell.h"
#import "TextFieldTableCellController.h"
#import "TextViewTableCellController.h"
#import "ThemeManager.h"

@interface EditListViewController() <TableCellControllerDelegate>

@property (nonatomic, strong) MetaList *list;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *cellViewControllers;

@end

@implementation EditListViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithList:(MetaList *)aList
{
    self = [super init];
    if (!self) return nil;
    _list = aList;
    return self;
}

- (NSString *)nibName
{
    return @"EditListView";
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:NSLocalizedString(@"snap!List",nil)];
    [[self tableView] setRowHeight:44.0f];
    NSArray *cellControllers = @[
        [[TextFieldTableCellController alloc] initWithTableView:[self tableView]],
        [[TextViewTableCellController alloc] initWithTableView:[self tableView]]
    ];
    [self setCellViewControllers:cellControllers];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
            (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return elvNUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    
    if ([indexPath section]  <= 1) {
        BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:[indexPath section]];
        [cellController setDelegate:self];
        return [cellController tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    [[cell textLabel] setText:[NSString stringWithFormat:@"Cell %d", [indexPath section]]];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]  <= 1) {
        BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:[indexPath section]];
        [cellController setDelegate:self];
        return [cellController tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return [tableView rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:0];
        [cellController tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

}

#pragma mark - table cell controller delegate

- (id)cellController:(BaseTableCellController *)cellController itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self list];
}

@end

