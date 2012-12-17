//
//  TextFieldTableCell.m
//  ListMonster
//
//  Created by Norm Barnard on 12/9/12.
//
//

#import "CDOGeometry.h"
#import "TextFieldTableCell.h"
#import "ThemeManager.h"

@interface TextFieldTableCell()

@property (nonatomic, assign) CGFloat textHeight;

@end


@implementation TextFieldTableCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    [self setSelectionStyle:UITableViewCellEditingStyleNone];
    [self setAccessoryType:UITableViewCellAccessoryNone];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [_textField setText:NSLocalizedString(@"Add New List...", nil)];
    [_textField setAdjustsFontSizeToFitWidth:NO];
    [_textField setFont:[ThemeManager fontForListName]];
    [_textField setTextColor:[UIColor whiteColor]];
    [_textField setEnabled:NO];
    [_textField setDelegate:self];
    [_textField setReturnKeyType:UIReturnKeyDone];
    [[self contentView] addSubview:_textField];
    
    CGSize txtSize = [@"Add New List..." sizeWithFont:[ThemeManager fontForListName]];
    _textHeight = txtSize.height;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [[self textField] setText:@""];
        [[self textField] setEnabled:YES];
        [[self textField] becomeFirstResponder];
        return;
    }
    [[self textField] setEnabled:NO];
    [[self textField] setText:NSLocalizedString(@"Add New List...", nil)];    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth([[self contentView] frame]) - [self indentationWidth];
    CGRect tfFrame =  CDO_CGRectCenteredInRect([[self contentView] frame], width , [self textHeight] + 4.0f);
    tfFrame.origin.x += [self indentationWidth];
    [[self textField] setFrame:tfFrame];
}

- (void)prepareForReuse
{
    [[self textField] setText:NSLocalizedString(@"Add New List...", nil)];
    [[self textField] setAdjustsFontSizeToFitWidth:YES];
    [[self textLabel] setMinimumFontSize:kSizeListNameFont];
    [[self textField] setFont:[ThemeManager fontForListName]];
    [[self textField] setTextColor:[UIColor whiteColor]];
    [[self textField] setEnabled:NO];
}

#pragma mark - text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0) return YES;
    NSMutableString *maybeText = [NSMutableString stringWithString:[textField text]];
    [maybeText replaceCharactersInRange:range withString:string];
    CGSize maybeSize = [maybeText sizeWithFont:[textField font]];
    return (maybeSize.width > CGRectGetWidth([textField frame])) ? NO : YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[self delegate] textFieldTableCell:self didEndEdittingText:[textField text]];
    [[self textField] setText:NSLocalizedString(@"Add New List...", nil)];
    [[self textField] setEnabled:NO];    
    return NO;
}


@end
