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

static const CGFloat kTopTextMargin = 4.0f;

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
    [_textField setAdjustsFontSizeToFitWidth:NO];
    [_textField setFont:[ThemeManager fontForListName]];
    [_textField setTextColor:[UIColor whiteColor]];
    [_textField setEnabled:NO];
    [_textField setDelegate:self];
    [_textField setReturnKeyType:UIReturnKeyDone];
    [[self contentView] addSubview:_textField];
    
    CGSize txtSize = [@"XX" sizeWithFont:[ThemeManager fontForListName]];
    _textHeight = txtSize.height;
    return self;
}

- (void)setDefaultText:(NSString *)defaultText
{
    _defaultText = defaultText;
    [[self textField] setText:defaultText];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
//        [[self textField] setText:@""];
        [[self textField] setEnabled:YES];
        [[self textField] becomeFirstResponder];
        return;
    }
    [[self textField] setEnabled:NO];
    [[self textField] setText:[self defaultText]];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth([[self contentView] frame]) - [self indentationWidth];
    CGFloat yOffset = (CGRectGetHeight([[self contentView] frame]) - [self textHeight] + kTopTextMargin) / 2.0f;
    CGRect tfFrame =  CGRectMake([self indentationWidth], yOffset, width, [self textHeight] + kTopTextMargin);
    [[self textField] setFrame:tfFrame];
}

- (void)prepareForReuse
{
    [[self textField] setText:[self defaultText]];
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
    [[self textField] setText:[self defaultText]];
    [[self textField] setEnabled:NO];    
    return NO;
}


@end
