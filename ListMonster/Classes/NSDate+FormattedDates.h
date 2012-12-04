//
//  NSDate+FormattedDates.h
//  ListMonster
//
//  Created by Norm Barnard on 12/2/12.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (FormattedDates)

- (NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style;
- (NSString *)formattedTimeForLocale:(NSLocale *)locale;

@end
