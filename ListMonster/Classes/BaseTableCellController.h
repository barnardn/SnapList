//
//  BaseTableCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/16/12.
//
//

#import <Foundation/Foundation.h>

@protocol TableCellControllerDelegate;

@interface BaseTableCellController : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<TableCellControllerDelegate> delegate;

- (id)initWithTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TableCellControllerDelegate <NSObject>

- (id)cellController:(BaseTableCellController *)cellController itemAtIndexPath:(NSIndexPath *)indexPath;

@end
