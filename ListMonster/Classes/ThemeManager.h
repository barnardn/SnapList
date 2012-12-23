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
#define kSizeTinyFont       10.0f

#define TABLECELL_VERTICAL_MARGIN   20.0f

typedef enum  {
  TableHeaderStyleNone,
  TableHeaderStyleNormal,
  TableHeaderStyleLight
} TableHeaderStyle;

@interface ThemeManager : NSObject

+ (UIFont *)fontForListName;
+ (UIFont *)fontForStandardListText;
+ (UIFont *)fontForListDetails;
+ (UIFont *)fontForListHeader;
+ (UIFont *)fontForDueDateDetails;

+ (UIColor *)standardTextColor;
+ (UIColor *)highlightedTextColor;
+ (UIColor *)ghostedTextColor;
+ (UIColor *)textColorForListDetails;
+ (UIColor *)textColorForOverdueItems;
+ (UIColor *)textColorForListManagerList;
+ (UIColor *)backgroundColorForListManager;

+ (CGFloat)heightForHeaderview;

+ (UILabel *)labelForTableHeadingsWithText:(NSString *)text;
+ (UILabel *)labelForTableHeadingsWithText:(NSString *)text textColor:(UIColor *)textColor;
+ (UIView *)headerViewTitled:(NSString *)title withDimensions:(CGSize)dimensions;
+ (UIView *)headerViewWithStyle:(TableHeaderStyle)style title:(NSString *)title dimensions:(CGSize)dimensions;

@end
