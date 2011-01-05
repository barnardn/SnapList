//
//  ListItem.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "MetaListItem.h"


@implementation MetaListItem

@dynamic name, quantity, isChecked, list;


#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert {
    [self setQuantity:[NSDecimalNumber numberWithInt:0]];
    [self setIsChecked:INT_OBJ(0)];
}


@end
