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
#define ITEM_ENTITY_NAME        @"MetaListItem"


@class MetaList;
@class Measure;

@protocol ReminderItemProtocol

@property(nonatomic,retain) NSDate *reminderDate;
- (void)scheduleReminder;

@end

@interface MetaListItem : _MetaListItem <ReminderItemProtocol> {
    BOOL reminderDateChanged;
}

@property (nonatomic) BOOL wasDeleted;

- (BOOL)isComplete;
- (void)setIsComplete:(BOOL)complete;
- (NSString *)quantityDescription;
- (void)cancelReminder;
- (NSString *)messageForNotificationAlert;
- (UILocalNotification *)findScheduledNofication;
- (void)decrementBadgeNumberForFiredNotification;
- (void)decrementBadgeNumber;
- (void)save;


+ (NSArray *)itemsDueOnOrBefore:(NSDate *)date;

@end
