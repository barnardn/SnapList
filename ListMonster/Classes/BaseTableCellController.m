//
//  BaseTableCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/16/12.
//
//

#import "BaseTableCellController.h"

@implementation BaseTableCellController


- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (!self) return nil;
    _tableView = tableView;
    return self;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must implement %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must implement %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView rowHeight];
}

@end
