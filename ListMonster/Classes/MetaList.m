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
#import "NSArrayExtensions.h"
#import "NSStringExtensions.h"
#import "RegexKitLite.h"

@interface MetaList()

- (NSArray *)itemsForCompletedState:(BOOL)state;

@end


@implementation MetaList

@dynamic name, listID, dateCreated, items, category, color, note;


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

- (void)removeItem:(MetaListItem *)item
{
    NSMutableSet *mutableItems = [self mutableSetValueForKey:@"items"];
    [mutableItems removeObject:item];
}

- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state {
    
    NSArray *allItems = [[self items] allObjects];
    NSArray *filteredItems = [allItems filteredArrayUsingPredicate:predicate];
    [filteredItems setValue:INT_OBJ(state) forKey:@"isChecked"];
}

- (NSArray *)allCompletedItems {
    return [self itemsForCompletedState:YES];
}

- (NSArray *)allIncompletedItems {
    return [self itemsForCompletedState:NO];
}

- (NSString *)excerptOfLength:(NSInteger)numWords {
    
    if ([[self note] length] <= 0) return nil;
    
    NSArray *words = [[self note] componentsSeparatedByRegex:@"\\s+"];
    if ([words count] < numWords)
        return [self note];

    NSString *excerpt = [[words sliceAt:0 withLength:numWords] componentsJoinedByString:@" "];
    return [NSString stringWithFormat:@"%@...", excerpt];
}


#pragma mark -
#pragma mark Category Methods

- (NSArray *)itemsForCompletedState:(BOOL)state {
    
    NSArray *allItems = [[self items] allObjects];
    NSPredicate *byCheckedState = [NSPredicate predicateWithFormat:@"isChecked == %d AND isDeleted == NO", (int)state];
    NSArray *filteredItems = [allItems filteredArrayUsingPredicate:byCheckedState];
    return filteredItems;
    
}



@end
