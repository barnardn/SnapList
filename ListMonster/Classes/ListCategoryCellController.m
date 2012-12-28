//
//  ListCategoryCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/26/12.
//
//

#import "ListCategory.h"
#import "ListCategoryCellController.h"
#import "ListCategoryViewController.h"
#import "MetaList.h"
#import "ThemeManager.h"

@implementation ListCategoryCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"--categoryCell--";
    
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    [cell setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [[cell textLabel] setTextColor:[ThemeManager textColorForListManagerList]];
    [[cell textLabel] setFont:[ThemeManager fontForListName]];

    if ([list category]) {
        [[cell textLabel] setText:[[list category] name]];
    } else {
        [[cell textLabel] setTextColor:[ThemeManager ghostedTextColorForListManager]];
        [[cell textLabel] setText:NSLocalizedString(@"Pick a Category...", nil)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZAssert([[self delegate] respondsToSelector:@selector(cellController:didSelectItem:)], @"Whoa! delegate must respond to cellController:didSelectItem:!");
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    ListCategoryViewController *vcCategory = [[ListCategoryViewController alloc] initWithList:list];
    [[self navController] pushViewController:vcCategory animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView rowHeight];
}


@end
