//
//  ListItem.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "_MetaListItem.h"

#define mliREMINDER_KEY  @"SnaplistReminder"
#define mleMAX_REMINDER_WORDS   10

@class MetaList;
@class Measure;

@protocol ReminderItemProtocol

@property(nonatomic,retain) NSDate *reminderDate;
- (void)scheduleReminder;

@end

@interface MetaListItem : _MetaListItem <ReminderItemProtocol> {
    BOOL reminderDateChanged;
}


- (BOOL)isComplete;
- (void)setIsComplete:(BOOL)complete;
- (void)cancelReminder;
- (NSString *)messageForNotificationAlert;
- (UILocalNotification *)findScheduledNofication;
- (NSString *)priorityName;
- (void)decrementBadgeNumberForFiredNotification;
- (void)decrementBadgeNumber;
- (void)save;

@end
