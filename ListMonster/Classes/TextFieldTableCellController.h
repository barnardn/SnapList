//
//  TextFieldTableCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/16/12.
//
//

#import <Foundation/Foundation.h>

#import "BaseTableCellController.h"
#import "TextFieldTableCell.h"

@interface TextFieldTableCellController : BaseTableCellController <TextFieldTableCellDelegate>

- (id)initWithTableView:(UITableView *)tableView;

@end
