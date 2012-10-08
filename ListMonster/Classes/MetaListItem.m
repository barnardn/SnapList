//
//  ListItem.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "ListMonsterAppDelegate.h"
#import "Measure.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "datetime_utils.h"

@implementation MetaListItem

@dynamic name, quantity, isChecked, list, reminderDate, priority, unitOfMeasure;
@dynamic itemIdentity;

#pragma mark -
#pragma mark Custom accessors

- (void)setIsChecked:(NSNumber *)checkedState
{
    [self willChangeValueForKey:@"isChecked"];
    [self setPrimitiveValue:checkedState forKey:@"isChecked"];
    [self didChangeValueForKey:@"isChecked"];
    if ([checkedState intValue] == 1 && [self reminderDate]) {
        [self decrementBadgeNumberForFiredNotification];
        [self setReminderDate:nil];
        [self cancelReminder];
    }
}

// NOTE: some date checks are required.
// if the previous reminder date is prior to "right now" then the notification was fired, and bumped up 
// the badge number, so we have to decrement the badge number since were effectively completing this 
// entry by pushing it into the future.
- (void)setReminderDate:(NSDate *)date
{
    NSDate *oldDate = [self primitiveValueForKey:@"reminderDate"];
    if (![self isComplete]) {
        if (oldDate && (NSOrderedAscending == [oldDate compare:[NSDate date]])) 
            [self decrementBadgeNumber];
        [self cancelReminder];
    }
    [self willChangeValueForKey:@"reminderDate"];
    [self setPrimitiveValue:date forKey:@"reminderDate"];
    [self didChangeValueForKey:@"reminderDate"];    
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
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"itemIdentity"];
}

- (void)willSave
{
    [super willSave];
    if ([[self changedValues] valueForKey:@"reminderDate"])
        reminderDateChanged = YES;
}

- (void)didSave
{
    [super didSave];
    if (!reminderDateChanged) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_OVERDUE_ITEM object:self];
}

- (void)prepareForDeletion
{
    [self cancelReminder];
}

#pragma mark -
#pragma mark Reminder scheduling methods

- (void)decrementBadgeNumberForFiredNotification
{
    if (NSOrderedAscending == [[self reminderDate] compare:[NSDate date]])
        [self decrementBadgeNumber];
}

- (void)decrementBadgeNumber
{
    NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if (badgeNumber > 0)
        badgeNumber--;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];

}

- (void)scheduleReminder
{
    if (![self reminderDate]) return;
    [self cancelReminder];
    UILocalNotification *localNotice = [[UILocalNotification alloc] init];
    [localNotice setFireDate:[self reminderDate]];
    NSDictionary *infoDict = @{mliREMINDER_KEY: [self itemIdentity]};
    [localNotice setUserInfo:infoDict];
    ///NSInteger badgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    [localNotice setApplicationIconBadgeNumber:1];  // was badgeNumber + 1
    //DLog(@"set badge to %d", badgeNumber + 1);
    [localNotice setAlertBody:[self messageForNotificationAlert]];
    [localNotice setAlertAction:NSLocalizedString(@"View", nil)];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotice];
    DLog(@"Scheduled new notification for %@", [localNotice fireDate]);
}

- (void)cancelReminder
{
    UILocalNotification *reminder = [self findScheduledNofication];
    if (!reminder) return;
    [[UIApplication sharedApplication] cancelLocalNotification:reminder];
    if ([self reminderDate])
        [self decrementBadgeNumberForFiredNotification];
}

- (UILocalNotification *)findScheduledNofication
{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSArray *matching = [allNotifications filterBy:^ (id obj) {
        UILocalNotification *ln = obj;
        NSString *notificationName = [[ln userInfo] valueForKey:mliREMINDER_KEY];
        return ([notificationName isEqualToString:[self itemIdentity]]);
    }];
    return ([matching count]) ? matching[0] : nil;
}

- (NSString *)messageForNotificationAlert
{
    NSString *msg = [self name];
    NSArray *words = [[self name] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([words count] > mleMAX_REMINDER_WORDS) {
        msg = [words componentsJoinedByString:@" "];
    }
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
