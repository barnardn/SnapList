//
//  ListItem.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "datetime_utils.h"

@implementation MetaListItem

@dynamic name, quantity, isChecked, list, reminderDate, priority;

#pragma mark -
#pragma mark Custom accessors

- (void)setIsChecked:(NSNumber *)checkedState
{
    [self willChangeValueForKey:@"isChecked"];
    [self setPrimitiveValue:checkedState forKey:@"isChecked"];
    [self didChangeValueForKey:@"isChecked"];
    if ([checkedState intValue] == 1 && [self reminderDate]) {
        [self setReminderDate:nil];
        [self cancelReminderDecrementingBadgeNumber:NO];
    }
}

- (BOOL)isComplete 
{
    if (![self isChecked]) return NO;
    NSInteger intVal = [[self isChecked] intValue];
    return (intVal > 0);
}

#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert 
{
    [self setPrimitiveValue:@"New Item" forKey:@"name"];
    [self setPrimitiveValue:INT_OBJ(0) forKey:@"quantity"];
    [self setPrimitiveValue:INT_OBJ(0) forKey:@"isChecked"];
/*    [self setName:@"New Item"];
    [self setQuantity:[NSNumber numberWithInt:0]];
    [self setIsChecked:INT_OBJ(0)]; */
}

- (void)willSave
{
    if (![self reminderDate]) return;
    if ([[self reminderDate] timeIntervalSinceNow] <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:self];
        return;
    }
}

- (void)prepareForDeletion
{
    [self cancelReminderDecrementingBadgeNumber:NO];
}

#pragma mark -
#pragma mark Reminder scheduling methods


- (void)scheduleReminder
{
    if (![self reminderDate]) return;
    NSURL *itemUrl = [[self objectID] URIRepresentation];
    NSString *noficationKey = [NSString stringWithFormat:@"%@",itemUrl]; 
    [self cancelReminderDecrementingBadgeNumber:NO];
    UILocalNotification *localNotice = [[UILocalNotification alloc] init];
    [localNotice setFireDate:[self reminderDate]];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:noficationKey forKey:mliREMINDER_KEY];
    [localNotice setUserInfo:infoDict];
    [localNotice setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotice];
    [localNotice release];
    DLog(@"Scheduled new notification for %@", [localNotice fireDate]);
}

- (void)cancelReminderDecrementingBadgeNumber:(BOOL)shouldDecrement
{
    UILocalNotification *reminder = [self findScheduledNofication];
    if (!reminder) return;
    [[UIApplication sharedApplication] cancelLocalNotification:reminder];
    if (shouldDecrement) {
        NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber-1];
    }
}

- (UILocalNotification *)findScheduledNofication
{
    NSString *notificationKey = [NSString stringWithFormat:@"%@", [[self objectID] URIRepresentation]];
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSArray *matching = [allNotifications filterBy:^ (id obj) {
        UILocalNotification *ln = obj;
        NSString *notificationName = [[ln userInfo] valueForKey:mliREMINDER_KEY];
        return ([notificationName isEqualToString:notificationKey]);
    }];
    return ([matching count]) ? [matching objectAtIndex:0] : nil;
}

- (NSString *)messageForNotificationAlert
{
    NSString *msg;
    if (has_midnight_timecomponent([self reminderDate]))
        msg = [self name];
    else
        msg = [NSString stringWithFormat:@"%@ at %@", [self name], formatted_time([self reminderDate])];
    return msg;
}

- (NSString *)priorityName 
{
    if (![self priority])
        return nil;
    switch ([[self priority] intValue]) {
        case 0:
            return @"Normal";            
        case 1: 
            return @"High";
        case -1:
            return @"Low";
    }
    return nil;
}


@end
