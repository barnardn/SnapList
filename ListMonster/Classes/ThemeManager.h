//
//  ThemeManager.h
//  ListMonster
//
//  Created by Norm Barnard on 10/8/12.
//
//

#import <Foundation/Foundation.h>

#define kRegularFontName    @"Thonburi"
#define kBoldFontName       @"Thonburi-Bold"

#define kSizeListNameFont   20.0f
#define kSizeStandardFont   18.0f
#define kSizeSmallFont      14.0f

@interface ThemeManager : NSObject

+ (UIFont *)fontForListName;
+ (UIFont *)fontForStandardListText;
+ (UIFont *)fontForListDetails;
+ (UIFont *)fontForListHeader;

+ (UIColor *)standardTextColor;
+ (UIColor *)highlightedTextColor;
+ (UIColor *)ghostedTextColor;

+ (CGFloat)heightForHeaderview;

+ (UILabel *)labelForTableHeadingsWithText:(NSString *)text;
+ (UIView *)headerViewTitled:(NSString *)title withDimenions:(CGSize)dimensions;

@end
