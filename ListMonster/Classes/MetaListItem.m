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
        if (NSOrderedAscending == [[self reminderDate] compare:[NSDate date]]) {
            NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
            if (badgeNumber > 0)
                badgeNumber--;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        }
        [self setReminderDate:nil];
        [self cancelReminder];
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


- (void)scheduleReminder
{
    if (![self reminderDate]) return;
    NSURL *itemUrl = [[self objectID] URIRepresentation];
    NSString *noficationKey = [NSString stringWithFormat:@"%@",itemUrl]; 
    [self cancelReminder];
    UILocalNotification *localNotice = [[UILocalNotification alloc] init];
    [localNotice setFireDate:[self reminderDate]];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:noficationKey forKey:mliREMINDER_KEY];
    [localNotice setUserInfo:infoDict];    
    [localNotice setApplicationIconBadgeNumber:1];
    [localNotice setAlertBody:[self messageForNotificationAlert]];
    [localNotice setAlertAction:NSLocalizedString(@"View", nil)];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotice];
    [localNotice release];
    DLog(@"Scheduled new notification for %@", [localNotice fireDate]);
}

- (void)cancelReminder
{
    UILocalNotification *reminder = [self findScheduledNofication];
    if (!reminder) return;
    [[UIApplication sharedApplication] cancelLocalNotification:reminder];
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
