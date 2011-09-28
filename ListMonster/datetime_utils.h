/*
 *  datetime_utils.h
 *  Utility functions for working with dates and times.
 *
 *  Created by Norm Barnard on 4/25/11.
 *  Copyright 2011 clamdango.com. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#define SECONDS_PER_DAY (60*60*24)

#define dtuMMDDYY_CALUNITS NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit
#define dtuHOURSMIN_CALUNITS NSHourCalendarUnit|NSMinuteCalendarUnit


NSInteger weekday_for_date(NSDate *current_date);
NSInteger weekday_for_today() ;
NSDate *today_at_midnight();
NSDate *date_by_adding_days(NSDate *from_date, NSInteger num_days);
NSString *formatted_date(NSDate *date);
NSString *dayname_for_date(NSDate *date);
NSString *formatted_relative_date(NSDate *date);
NSInteger date_diff(NSDate *fromDate, NSDate *toDate);
NSDate *date_minus_seconds(NSDate *date);
BOOL has_midnight_timecomponent(NSDate *date);
NSString *formatted_time(NSDate *date);
NSString *formatted_date_with_format_string(NSDate *date, NSString *formatString);