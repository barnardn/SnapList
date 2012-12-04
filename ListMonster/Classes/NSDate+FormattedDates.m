//
//  NSDate+FormattedDates.m
//  ListMonster
//
//  Created by Norm Barnard on 12/2/12.
//
//

#import "NSDate+FormattedDates.h"

@implementation NSDate (FormattedDates)

- (NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formattedTimeForLocale:(NSLocale *)locale
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *timeFormat = [NSDateFormatter dateFormatFromTemplate:@"hhmm" options:0 locale:locale];
    [dateFormatter setDateFormat:timeFormat];
    return [dateFormatter stringFromDate:self];
}

@end
