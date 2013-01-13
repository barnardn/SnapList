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


static const CGFloat kEditCellTextViewLeftMargin = 10.0f;
static const CGFloat kEditCellTextViewTopMargin = 10.0f;
static const CGFloat kItemCellContentWidth = 250.0f;

static char editCellKey;

@implementation TextViewTableCellController

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super initWithTableView:tableView];
    if (!self) return nil;
    return self;
}

- (TextViewTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"--editcell--";
    NSString *text = [[self delegate] textViewTableCellController:self textForRowAtIndexPath:indexPath];
    
    TextViewTableCell *cell = (TextViewTableCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setDelegate:self];
    }
    [cell setBackgroundColor:[self backgroundColor]];
    [[cell textView] setTextColor:[self textColor]];
    [[cell textView] setText:text];
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
    return;
}


- (void)stopEditingCellAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewTableCell *cell = (TextViewTableCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    [[cell textView] resignFirstResponder];
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
    CGSize textSize = [text sizeWithFont:[ThemeManager fontForStandardListText]
                              constrainedToSize:CGSizeMake(width - 8.0f, 20000.0f)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return textSize;
}


@end
