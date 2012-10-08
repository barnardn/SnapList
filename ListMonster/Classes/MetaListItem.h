//
//  ListItem.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define mliREMINDER_KEY  @"SnaplistReminder"
#define mleMAX_REMINDER_WORDS   10

@class MetaList;
@class Measure;

@protocol ReminderItemProtocol

@property(nonatomic,retain) NSDate *reminderDate;
- (void)scheduleReminder;

@end

@interface MetaListItem : NSManagedObject <ReminderItemProtocol> {
    BOOL reminderDateChanged;
}

@property (nonatomic, strong) NSString *itemIdentity;
@property (nonatomic, strong) NSNumber *isChecked;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) MetaList *list;
@property (nonatomic, strong) NSNumber *priority;
@property (nonatomic, strong) Measure *unitOfMeasure;


- (BOOL)isComplete;
- (void)cancelReminder;
- (NSString *)messageForNotificationAlert;
- (UILocalNotification *)findScheduledNofication;
- (NSString *)priorityName;
- (void)decrementBadgeNumberForFiredNotification;
- (void)decrementBadgeNumber;

@end
