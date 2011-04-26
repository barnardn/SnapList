//
//  ListItem.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetaList;

@protocol ReminderItemProtocol

- (NSDate *)reminderDate;
- (void)setReminderDate:(NSDate *)date;

@end

@interface MetaListItem : NSManagedObject <ReminderItemProtocol> {

}

@property (nonatomic, retain) NSNumber *isChecked;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) MetaList *list;
@property (nonatomic, retain) NSDate *reminderDate;

- (BOOL)isComplete;


@end
