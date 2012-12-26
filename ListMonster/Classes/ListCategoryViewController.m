//
//  ListCategoryViewController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/26/12.
//
//

#import "ListCategory.h"
#import "ListCategoryViewController.h"
#import "MetaList.h"
#import "ThemeManager.h"
#import "TextFieldTableCell.h"
#import "TextFieldTableCellController.h"

static const CGFloat kRowHeight = 44.0f;

@interface ListCategoryViewController ()

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnReorder;
@property (nonatomic, strong) MetaList *list;
@end

@implementation ListCategoryViewController

- (id)initWithList:(MetaList *)list
{
    self = [super init];
    if (!self) return nil;
    _list = list;
    return self;
}

- (NSString *)nibName
{
    return @"ListCategoryView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setRowHeight:kRowHeight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table view datasource methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [ThemeManager headerViewTitled:[[self list] name] withDimensions:CGSizeMake(CGRectGetWidth([[self view] bounds]), [ThemeManager heightForHeaderview])];
}



@end
