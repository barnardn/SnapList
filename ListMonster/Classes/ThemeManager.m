//
//  ThemeManager.m
//  ListMonster
//
//  Created by Norm Barnard on 10/8/12.
//
//

#import "ThemeManager.h"

@implementation ThemeManager

+ (UIFont *)fontForListName
{
    return [UIFont fontWithName:kBoldFontName size:kSizeListNameFont];
}

+ (UIFont *)fontForStandardListText
{
    return [UIFont fontWithName:kRegularFontName size:kSizeStandardFont];
}

+ (UIFont *)fontForListDetails
{
    return [UIFont fontWithName:kBoldFontName size:kSizeSmallFont];
}

+ (UIFont *)fontForListHeader
{
    return [UIFont fontWithName:kBoldFontName size:kSizeSmallFont];
}

+ (UIColor *)standardTextColor
{
    return [UIColor darkTextColor];
}

+ (UIColor *)highlightedTextColor
{
    return [UIColor darkGrayColor];
}

+ (UIColor *)ghostedTextColor
{
    return [UIColor lightGrayColor];
}

+ (UILabel *)labelForTableHeadingsWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:text];
    [label sizeToFit];
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(1.0f, 1.0f)];
    return label;
}


@end
