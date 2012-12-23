//
//  TextViewTableCellController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/18/12.
//
//

#import <objc/objc-runtime.h>

#import "MetaList.h"
#import "TextViewTableCell.h"
#import "TextViewTableCellController.h"
#import "ThemeManager.h"


static const CGFloat kEditCellTextViewLeftMargin = 10.0f;
static const CGFloat kEditCellTextViewTopMargin = 5.0f;
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
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    
    TextViewTableCell *cell = (TextViewTableCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setDelegate:self];
    }
    [cell setBackgroundColor:[ThemeManager backgroundColorForListManager]];
    if ([[list note] length] == 0)
        [[cell textView] setText:NSLocalizedString(@"Add a new note...", nil)];
    else
        [[cell textView] setText:[list note]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    if ([[list note] length] == 0) return [tableView rowHeight];
    CGSize textSize = [self sizeForText:[list note]];
    CGFloat height =  MAX([tableView rowHeight], textSize.height + 2 * kEditCellTextViewTopMargin);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

#pragma mark - textview delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UITableViewCell *cell = objc_getAssociatedObject(textView, &editCellKey);
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    if ([[list note] length] == 0)
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
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    [list setNote:newText];

    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    UITableViewCell *editCell = objc_getAssociatedObject(textView, &editCellKey);
    objc_removeAssociatedObjects(textView);
    [textView resignFirstResponder];
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:editCell];
    editCell = nil;
    if (indexPath)
        [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    MetaList *list = [[self delegate] cellController:self itemAtIndexPath:indexPath];
    [list save];
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
