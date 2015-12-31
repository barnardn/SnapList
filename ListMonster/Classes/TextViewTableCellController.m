//
//  TextViewTableCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/18/12.
//
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "TextViewTableCell.h"
#import "TextViewTableCellController.h"
#import "ThemeManager.h"


static const CGFloat kEditCellTextViewTopMargin = 10.0f;

static char editCellKey;

@implementation TextViewTableCellController

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (!self) return nil;
    [tableView registerClass:[TextViewTableCell class] forCellReuseIdentifier:NSStringFromClass([TextViewTableCell class])];
    return self;
}

- (TextViewTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self delegate] textViewTableCellController:self textForRowAtIndexPath:indexPath];
    
    TextViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TextViewTableCell class]) forIndexPath:indexPath];
    [cell setBackgroundColor:[self backgroundColor]];
    [[cell textView] setTextColor:[self textColor]];
    [[cell textView] setText:text];
    
    [[cell textView] setEditable:NO];
    [[cell textView] setUserInteractionEnabled:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [[self delegate] textViewTableCellController:self textForRowAtIndexPath:indexPath];
    if ([text length] == 0) return [tableView rowHeight];
    CGSize textSize = [self sizeForText:text];
    CGFloat height =  MAX([tableView rowHeight], textSize.height + 2 * kEditCellTextViewTopMargin);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewTableCell *cell = (TextViewTableCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    [[cell textView] setEditable:YES];
    [[cell textView] setUserInteractionEnabled:YES];
    [[cell textView] becomeFirstResponder];
    
    if (![[self delegate] respondsToSelector:@selector(shouldClearTextForRowAtIndexPath:)]) return;
    
    if (![[self delegate] shouldClearTextForRowAtIndexPath:indexPath]) return;
    
    [[cell textView] setText:@""];
    return;
}



- (void)stopEditingCellAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewTableCell *cell = (TextViewTableCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    [[cell textView] resignFirstResponder];
    [[cell textView] setEditable:NO];
    [[cell textView] setUserInteractionEnabled:NO];
}


#pragma mark - textview delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UITableViewCell *cell = objc_getAssociatedObject(textView, &editCellKey);
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    NSString *text = [[self delegate] textViewTableCellController:self textForRowAtIndexPath:indexPath];
    if ([text length] == 0)
        [textView setText:@""];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound ) {
        [textView resignFirstResponder];
        return NO;
    }
    NSMutableString *currentText = [[textView text] mutableCopy];
    NSString *newText =  [currentText stringByReplacingCharactersInRange:range withString:text];
    UITableViewCell *cell = objc_getAssociatedObject(textView, &editCellKey);
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    [[self delegate] textViewTableCellController:self didChangeText:newText forItemAtIndexPath:indexPath];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    UITableViewCell *editCell = objc_getAssociatedObject(textView, &editCellKey);
    objc_removeAssociatedObjects(textView);
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:editCell];
    editCell = nil;
    if (indexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self delegate] textViewTableCellController:self didEndEdittingText:[textView text] forItemAtIndexPath:indexPath];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
}

#pragma mark - private methods

- (CGSize)sizeForText:(NSString *)text
{
    CGFloat width = 300.0f;
    if ([[self tableView] style] == UITableViewStyleGrouped)
        width = 280.0f;
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width - 8.0f, INT16_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [ThemeManager fontForStandardListText]} context:nil];
    return boundingRect.size;
}


@end
