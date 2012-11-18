//
//  ThemeManager.m
//  ListMonster
//
//  Created by Norm Barnard on 10/8/12.
//
//

#import "CDOGeometry.h"
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

+ (UIView *)headerViewTitled:(NSString *)title withDimenions:(CGSize)dimensions
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"bg-tableheader"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f, 1.0f, 3.0f, 1.0f)];
    CGRect backgroundFrame = CGRectMake(0.0f, 0.0f, dimensions.width, dimensions.height);
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:backgroundFrame];
    [backgroundView setImage:backgroundImage];
    UILabel *lblListName  = [ThemeManager labelForTableHeadingsWithText:title];
    CGRect labelFrame = CDO_CGRectCenteredInRect(backgroundFrame, CGRectGetWidth([lblListName frame]), CGRectGetHeight([lblListName frame]));
    [lblListName setFrame:labelFrame];
    [backgroundView addSubview:lblListName];
    return backgroundView;
}



@end
