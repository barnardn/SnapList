//
//  TextFieldTableCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/16/12.
//
//

#import "MetaList.h"
#import "TextFieldTableCellController.h"
#import "ThemeManager.h"

@interface TextFieldTableCellController()

@end

@implementation TextFieldTableCellController


- (id)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (!self) return nil;
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"--txtTableCell--";
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    TextFieldTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [[cell textField] setClearsOnBeginEditing:NO];
        [cell setDelegate:self];
        [cell setDefaultText:[list name]];
    }
    [cell setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"hello from table cell controller");
}

- (void)textFieldTableCell:(TextFieldTableCell *)tableCell didEndEdittingText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:tableCell];
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    [list setName:text];
    [list save];
}

@end
