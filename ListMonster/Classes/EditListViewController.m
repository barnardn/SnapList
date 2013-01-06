//
//  EditListViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 1/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//


#import "ListCategory.h"
#import "ListCategoryCellController.h"
#import "ColorPickerCellController.h"
#import "EditListViewController.h"
#import "EditNoteViewController.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "TextFieldTableCell.h"
#import "TextFieldTableCellController.h"
#import "TextViewTableCellController.h"
#import "ThemeManager.h"

@interface EditListViewController() <TableCellControllerDelegate, TextFieldTableCellControllerDelegate, TextViewTableCellControllerDelegate>

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    ColorPickerCellController *ccColorPicker = [[ColorPickerCellController alloc] initWithTableView:[self tableView]];
    [ccColorPicker setDelegate:self];
    [ccColorPicker setList:[self list]];

    TextFieldTableCellController *ccTf = [[TextFieldTableCellController alloc] initWithTableView:[self tableView]];
    [ccTf setDelegate:self];
    [ccTf setTextfieldTextColor:[UIColor whiteColor]];
    [ccTf setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    
    TextViewTableCellController *ccTv = [[TextViewTableCellController alloc] initWithTableView:[self tableView]];
    [ccTv setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    [ccTv setTextColor:[UIColor whiteColor]];
    [ccTv setDelegate:self];
    
    ListCategoryCellController *ccLc = [[ListCategoryCellController alloc] initWithTableView:[self tableView]];
    [ccLc setDelegate:self];
    [ccLc setCategory:[[self list] category]];
    [ccLc setNavController:[self navigationController]];
    
    NSArray *cellControllers = @[
        ccTf, ccLc, ccColorPicker, ccTv
    ];
    [self setCellViewControllers:cellControllers];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    if ([[self tableView] indexPathForSelectedRow]) {
        [[self tableView] reloadRowsAtIndexPaths:@[[[self tableView] indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return elvNUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:[indexPath section]];
    return [cellController tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:[indexPath section]];
    return [cellController tableView:tableView heightForRowAtIndexPath:indexPath];
    return [tableView rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableCellController *cellController = [[self cellViewControllers] objectAtIndex:[indexPath section]];
    [cellController tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -  base table cell controller delegate

- (id)cellController:(BaseTableCellController *)cellController itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self list];
}

#pragma mark text field cell controller delegate

- (NSString *)defaultTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self list] name];
}

- (void)didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self list] setName:text];
    [[self list] save];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - color picker cell controller delegate method

- (void)cellController:(BaseTableCellController *)cellController didSelectItem:(id)item
{
    if ([cellController isKindOfClass:[ColorPickerCellController class]]) {
        UIColor *color = (UIColor *)item;
        [[[self navigationController] navigationBar] setTintColor:color];
    }
}

#pragma mark - textview table cell controller delegate

- (void)textViewTableCellController:(TextViewTableCellController *)controller didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self list] setNote:text];
    [[self list] save];
}

- (void)textViewTableCellController:(TextViewTableCellController *)controller didChangeText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[self list] setNote:text];
}

- (NSString *)textViewTableCellController:(TextViewTableCellController *)controller textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self list] note] length] == 0)
        return NSLocalizedString(@"Add a new note...", nil);
    return [[self list] note];
}


#pragma mark - keyboard notification handlers

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    [[self tableView] setContentInset:contentInsets];
    [[self tableView] setScrollIndicatorInsets:contentInsets];
    
    CGRect visibleRect = [[self view] frame];
    visibleRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(visibleRect, [cell frame].origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, cell.frame.origin.y-kbSize.height+cell.frame.size.height + 10.0f);
        [[self tableView] setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardDidDisappear:(NSNotification *)notification
{
    [[self tableView] setContentInset:UIEdgeInsetsZero];
    [[self tableView] setScrollIndicatorInsets:UIEdgeInsetsZero];
}




@end

