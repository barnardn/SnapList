//
//  List.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "MetaList.h"
#import "MetaListItem.h"
#import "Category.h"
#import "NSStringExtensions.h"

@implementation MetaList

@dynamic name, listID, dateCreated, items, category, color;


#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert {
    [self setDateCreated:[NSDate date]];
    [self setListID:[NSString stringWithUUID]];
}

@end
