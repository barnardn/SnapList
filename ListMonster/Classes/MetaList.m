//
//  List.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Category.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSStringExtensions.h"

@implementation MetaList

@dynamic name, listID, dateCreated, items, category, color;


#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert {
    [self setDateCreated:[NSDate date]];
    [self setListID:[NSString stringWithUUID]];
    [self setColor:[ListColor blackColor]];
}


- (BOOL)deleteAllItems {
    
    if ([[self items] count] == 0) return YES;
    
    NSManagedObjectContext *moc = [[ListMonsterAppDelegate sharedAppDelegate] managedObjectContext];
    for (MetaListItem *item in [self items]) {
        [moc deleteObject:item];
    }
    NSError *error = nil;
    [moc save:&error];
    if (error) {
        DLog(@"Unable to delete list items: %@", [error localizedDescription]);
        [moc rollback];
        return NO;
    }
    return YES;
}

- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state {
    
    NSArray *allItems = [[self items] allObjects];
    NSArray *filteredItems = [allItems filteredArrayUsingPredicate:predicate];
    [filteredItems setValue:INT_OBJ(state) forKey:@"isChecked"];
}

@end
