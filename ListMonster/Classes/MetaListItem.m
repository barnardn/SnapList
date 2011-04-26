//
//  ListItem.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "MetaListItem.h"


@implementation MetaListItem

@dynamic name, quantity, isChecked, list, reminderDate;


#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert {
    [self setQuantity:[NSNumber numberWithInt:0]];
    [self setIsChecked:INT_OBJ(0)];
}

- (BOOL)isComplete {
    
    if (![self isChecked]) return NO;
    NSInteger intVal = [[self isChecked] intValue];
    return (intVal > 0);
}


@end
