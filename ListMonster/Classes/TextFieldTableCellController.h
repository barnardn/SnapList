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

@protocol TextFieldTableCellControllerDelegate <NSObject>

- (NSString *)defaultTextForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface TextFieldTableCellController : BaseTableCellController <TextFieldTableCellDelegate>

@property (nonatomic, weak) id<TableCellControllerDelegate,TextFieldTableCellControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *textfieldTextColor;
@property (nonatomic, assign) BOOL clearTextOnBeginEdit;

- (id)initWithTableView:(UITableView *)tableView;

@end
