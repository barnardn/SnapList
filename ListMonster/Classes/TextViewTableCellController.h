//
//  TextViewTableCellController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseTableCellController.h"

@protocol TextViewTableCellControllerDelegate;

@interface TextViewTableCellController : BaseTableCellController <UITextViewDelegate>

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, weak) id<TableCellControllerDelegate, TextViewTableCellControllerDelegate> delegate;

@end

@protocol TextViewTableCellControllerDelegate <NSObject>

- (NSString *)textViewTableCellController:(TextViewTableCellController *)controller textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)textViewTableCellController:(TextViewTableCellController *)controller didChangeText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)textViewTableCellController:(TextViewTableCellController *)controller didEndEdittingText:(NSString *)text forItemAtIndexPath:(NSIndexPath *)indexPath;

@end