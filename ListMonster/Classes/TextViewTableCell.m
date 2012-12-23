//
//  TextViewTableCell.m
//  ListMonster
//
//  Created by Norm Barnard on 12/20/12.
//
//

#import "TextViewTableCell.h"
#import "ThemeManager.h"

const NSInteger kTextViewTag    = 1002;

static const CGFloat kItemCellContentWidth = 250.0f;

@implementation TextViewTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [_textView setContentInset:UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f)];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setTextColor:[ThemeManager textColorForListManagerList]];
    [_textView setSpellCheckingType:UITextSpellCheckingTypeDefault];
    [_textView setAutocorrectionType:UITextAutocorrectionTypeDefault];
    [_textView setFont:[ThemeManager fontForStandardListText]];
    [_textView setReturnKeyType:UIReturnKeyDone];
    [_textView setTag:kTextViewTag];
    [[self contentView] addSubview:_textView];
    return self;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate
{
    [[self textView] setDelegate:delegate];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentFrame = [[self contentView] bounds];    
    CGRect tvFrame = CGRectInset(contentFrame, 2.0f, 2.0f);
    [[self textView] setFrame:tvFrame];
}

- (CGSize)sizeForString:(NSString *)string withFont:(UIFont *)font inFrame:(CGRect)frame
{
    CGSize textSize = [string sizeWithFont:font
                       constrainedToSize:CGSizeMake(frame.size.width - 8.0f, 20000.0f)
                           lineBreakMode:NSLineBreakByWordWrapping];

    return textSize;
}



@end
