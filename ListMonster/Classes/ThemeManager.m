//
//  ThemeManager.m
//  ListMonster
//
//  Created by Norm Barnard on 10/8/12.
//
//

#import "CDOGeometry.h"
#import "ThemeManager.h"

#define TO_PERCENT_WHITE(A)    ((A)/255.0f)

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

+ (UIFont *)fontForDueDateDetails
{
    return [UIFont fontWithName:kRegularFontName size:kSizeTinyFont];
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

+ (UIColor *)textColorForListDetails
{
    return [UIColor colorWithRed:0.32f green:0.4f blue:0.57f alpha:1.0f];
}

+ (UIColor *)textColorForOverdueItems
{
    return [UIColor colorWithRed:TO_PERCENT_WHITE(220) green:TO_PERCENT_WHITE(40) blue:TO_PERCENT_WHITE(40) alpha:1.0f];
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

+ (CGFloat)heightForHeaderview
{
    static CGFloat staticHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *img = [UIImage imageNamed:@"bg-tableheader"];
        staticHeight = CDO_CGSizeGetHeight(img);
    });
    return staticHeight;
}

@end
