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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setFont:[ThemeManager fontForListDetails]];
    [[cell detailTextLabel] setFont:[ThemeManager fontForListName]];
    //[[cell detailTextLabel] setTextColor:[ThemeManager textColorForListManagerList]];
    [[cell textLabel] setText:NSLocalizedString(@"Category", nil)];
    if ([self category]) {
        [[cell detailTextLabel] setText:[[self category] name]];
    } else {
        [[cell detailTextLabel] setTextColor:[ThemeManager ghostedTextColorForListManager]];
        [[cell detailTextLabel] setText:@""];
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
