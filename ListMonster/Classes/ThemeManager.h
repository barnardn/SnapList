//
//  ThemeManager.h
//  ListMonster
//
//  Created by Norm Barnard on 10/8/12.
//
//

#import <Foundation/Foundation.h>

#define kRegularFontName    @"GeezaPro"
#define kBoldFontName       @"GeezaPro-Bold"

#define kSizeListNameFont   18.0f


@interface ThemeManager : NSObject

+ (UIFont *)fontForListName;


+ (UIColor *)standardTextColor;
+ (UIColor *)highlightedTextColor;
+ (UIColor *)ghostedTextColor;

@end
