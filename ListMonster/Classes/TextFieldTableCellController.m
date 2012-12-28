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
    TextFieldTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TextFieldTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [[cell textField] setClearsOnBeginEditing:[self clearTextOnBeginEdit]];
        [cell setDelegate:self];
    }
    [cell setDefaultText:[[self delegate] defaultTextForItemAtIndexPath:indexPath]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    [[cell textField] setTextColor:[self textfieldTextColor]];
    [cell setSelected:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"hello from table cell controller");
}

- (void)textFieldTableCell:(TextFieldTableCell *)tableCell didEndEdittingText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:tableCell];
    [[self delegate] didEndEdittingText:text forItemAtIndexPath:indexPath];
}

@end
