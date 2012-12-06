/*
 *  datetime_utils.m
 *  ListMonster
 *
 *  Created by Norm Barnard on 4/25/11.
 *  Copyright 2011 clamdango.com. All rights reserved.
 *
 */

#import "datetime_utils.h"

NSInteger weekday_for_date(NSDate *current_date) 
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:[NSLocale currentLocale]];
    NSDateComponents *dateParts = [cal components:NSWeekdayCalendarUnit fromDate:current_date];
    NSInteger curWeekday = [dateParts weekday];
    return curWeekday;
}

NSInteger weekday_for_today() 
{
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:[NSLocale currentLocale]];
    NSDateComponents *dateParts = [cal components:NSWeekdayCalendarUnit fromDate:today];
    return [dateParts weekday];
}

NSDate *today_at_midnight() 
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:dtuMMDDYY_CALUNITS fromDate:[NSDate date]];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *tam = [cal dateFromComponents:comps];
    return tam;
    
}

NSDate *tomorrow()
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = today_at_midnight();
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:1];
    NSDate *tomorrow =  [cal dateByAddingComponents:oneDay toDate:today options:0];
    DLog(@"tomorrow: %@", tomorrow);
    return tomorrow;
}


NSDate *date_minus_seconds(NSDate *date)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSSecondCalendarUnit fromDate:date];
    NSDate *noSeconds = [date dateByAddingTimeInterval:(-1 * [components second])];
    return noSeconds;
}

NSDate *date_by_adding_days(NSDate *from_date, NSInteger num_days)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:[NSLocale currentLocale]];
    NSDateComponents *day_offset = [[NSDateComponents alloc] init];
    [day_offset setDay:num_days];
    NSDate *new_date = [cal dateByAddingComponents:day_offset toDate:from_date options:0];
    return new_date;
}

NSString *formatted_relative_date(NSDate *date)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = today_at_midnight();
    NSDateComponents *dateParts = [cal components:NSDayCalendarUnit fromDate:today toDate:date options:0];
    
    switch ([dateParts day]) {
        case 0:
            return NSLocalizedString(@"Today", @"today");
            break;
        case 1:
            return NSLocalizedString(@"Tomorrow", @"tomorrow");
            break;
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
            return dayname_for_date(date);
            break;
        default:
            break;
    }
    return formatted_date(date);
}

NSInteger date_diff(NSDate *fromDate, NSDate *toDate)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateParts = [cal components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    return [dateParts day];
}

BOOL has_midnight_timecomponent(NSDate *date)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *hours = [cal components:dtuHOURSMIN_CALUNITS fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setLocale:[NSLocale currentLocale]];
    return ([hours hour] == 0 && [hours minute] == 0);
}

NSString *formatted_date_with_format_string(NSDate *date, NSString *formatString)
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setLocale:[NSLocale currentLocale]];
    [dateFmt setDateFormat:formatString];
    return [dateFmt stringFromDate:date];
}


NSString *dayname_for_date(NSDate *date)
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setLocale:[NSLocale currentLocale]];
    [dateFmt setDateFormat:@"EEE, MMM d"];
    return [dateFmt stringFromDate:date];
}

NSString *formatted_date(NSDate *date) 
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *hours = [cal components:dtuHOURSMIN_CALUNITS fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setLocale:[NSLocale currentLocale]];
    if ([hours hour] == 0 && [hours minute] == 0)
        [dateFmt setDateFormat:@"EEE, MMM d"];
    else 
        [dateFmt setDateFormat:@"EEE, MMM d 'at' h:mm a"];
    return [dateFmt stringFromDate:date];
}

NSString *formatted_time(NSDate *date)
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    [dateFmt setLocale:[NSLocale currentLocale]];
    [dateFmt setDateFormat:@"h:mm a"];
    return [dateFmt stringFromDate:date];
}

