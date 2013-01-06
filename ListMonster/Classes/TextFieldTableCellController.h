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

- (void)didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSString *)defaultTextForItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface TextFieldTableCellController : BaseTableCellController <TextFieldTableCellDelegate>

@property (nonatomic, weak) id<TableCellControllerDelegate,TextFieldTableCellControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *textfieldTextColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL clearTextOnBeginEdit;
@property (nonatomic, assign) UIKeyboardType keyboardType;

- (id)initWithTableView:(UITableView *)tableView;

@end
