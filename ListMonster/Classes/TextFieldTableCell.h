//
//  TextFieldTableCell.h
//  ListMonster
//
//  Created by Norm Barnard on 12/9/12.
//
//

#import <UIKit/UIKit.h>

@protocol TextFieldTableCellDelegate;

@interface TextFieldTableCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, assign) BOOL allowsTextEdit;
@property (nonatomic, weak) id<TextFieldTableCellDelegate> delegate;
@property (nonatomic, strong) NSString *defaultText;

@end

@protocol TextFieldTableCellDelegate <NSObject>

- (void)textFieldTableCell:(TextFieldTableCell *)tableCell didEndEdittingText:(NSString *)text;

@end
