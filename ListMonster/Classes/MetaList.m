//
//  List.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "ListCategory.h"
#import "ListColor.h"
#import "ListMonsterAppDelegate.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSStringExtensions.h"

@interface MetaList()

@end


@implementation MetaList



#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert {
    [self setDateCreated:[NSDate date]];
    [self setListID:[NSString stringWithUUID]];
    [self setColor:[ListColor blackColor]];
}


#pragma mark - helper methods

- (void)save
{
    NSError *error;
    ZAssert([[self managedObjectContext] save:&error], @"Unable to save list %@: %@", [self name], [error localizedDescription]);
}

- (void)deleteItem:(MetaListItem *)item
{
    [[self managedObjectContext] deleteObject:item];
    [self save];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:self];
}

- (void)addItem:(MetaListItem *)item
{
    NSMutableSet *mutableItems = [self mutableSetValueForKey:@"items"];
    [mutableItems addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:self];
}

- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state {
    
    NSArray *allItems = [[self items] allObjects];
    NSArray *filteredItems = [allItems filteredArrayUsingPredicate:predicate];
    [filteredItems setValue:INT_OBJ(state) forKey:@"isChecked"];
}

- (NSArray *)allCompletedItems {
    [NSException raise:@"Deprecated method" format:@"MetaListItem:allCompletedItems"];
    return nil;
}

- (NSArray *)allIncompletedItems {
    [NSException raise:@"Deprecated method" format:@"MetaListItem:allCompletedItems"];
    return nil;
}

- (NSArray *)sortedItemsIncludingComplete:(BOOL)includeCompleted
{
    NSArray *allItems = [[self items] allObjects];
    NSSortDescriptor *byOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sorted = [allItems sortedArrayUsingDescriptors:@[byOrder]];
    if (includeCompleted) return sorted;
    NSPredicate *onlyIncomplete = [NSPredicate predicateWithFormat:@"isChecked == 0"];
    return [sorted filteredArrayUsingPredicate:onlyIncomplete];
}


- (NSString *)excerptOfLength:(NSInteger)numWords {
    
    if ([[self note] length] <= 0) return nil;
    NSArray *words = [[self note] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
