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

@end
