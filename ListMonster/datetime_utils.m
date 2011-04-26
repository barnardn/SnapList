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
    NSDateComponents *dateParts = [cal components:NSWeekdayCalendarUnit fromDate:current_date];
    NSInteger curWeekday = [dateParts weekday];
    return curWeekday;
}

NSInteger weekday_for_today() 
{
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateParts = [cal components:NSWeekdayCalendarUnit fromDate:today];
    return [dateParts weekday];
}

NSDate *today_at_midnight() 
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:dtuMMDDYY_CALUNITS fromDate:[NSDate date]];
    NSDate *tam = [cal dateFromComponents:comps];
    return tam;
    
}

NSDate *date_by_adding_days(NSDate *from_date, NSInteger num_days)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *day_offset = [[[NSDateComponents alloc] init] autorelease];
    [day_offset setDay:num_days];
    NSDate *new_date = [cal dateByAddingComponents:day_offset toDate:from_date options:0];
    return new_date;
}