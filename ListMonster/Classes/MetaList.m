//
//  List.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "DataManager.h"
#import "ListCategory.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSStringExtensions.h"



@interface MetaList()

@end


@implementation MetaList

#pragma mark - class methods

+ (NSArray *)allListsInContext:(NSManagedObjectContext *)moc
{
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *byCategory = [[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *lists =  [DataManager fetchAllInstancesOf:LIST_ENTITY_NAME sortDescriptors:@[byCategory, byName] inContext:moc];
    return lists;
}

+ (NSArray *)allUncategorizedListsInContext:(NSManagedObjectContext *)moc
{
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSPredicate *emptyCategory = [NSPredicate predicateWithFormat:@"self.category == nil"];
    NSArray *lists = [DataManager fetchAllInstancesOf:LIST_ENTITY_NAME sortDescriptors:@[byName] filteredBy:emptyCategory inContext:moc];
    return lists;
}

#pragma mark -
#pragma mark NSManagedObject overrides

- (void)awakeFromInsert
{
    [self setDateCreated:[NSDate date]];
    [self setListID:[NSString stringWithUUID]];
    [self setPrimitiveIsNewValue:YES];
}


#pragma mark - helper methods

- (void)save
{
    NSError *error;
    ZAssert([[self managedObjectContext] save:&error], @"Unable to save list %@: %@", [self name], [error localizedDescription]);
    [self setIsNewValue:NO];
}

- (void)deleteItem:(MetaListItem *)item
{
    [[self managedObjectContext] deleteObject:item];
    [self save];
}

- (BOOL)deleteAllItems {
    
    if ([[self items] count] == 0) return YES;
    
    for (MetaListItem *item in [self items]) {
        [[self managedObjectContext] deleteObject:item];
    }
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
    if (error) {
        DLog(@"Unable to delete list items: %@", [error localizedDescription]);
        [[self managedObjectContext] rollback];
        return NO;
    }
    return YES;
}

- (NSInteger)countOfItemsCompleted:(BOOL)completed
{
    NSArray *itemsArray = [[self items] allObjects];
    NSPredicate *byIsChecked = [NSPredicate predicateWithFormat:@"self.IsChecked == %u", completed];
    return [[itemsArray filteredArrayUsingPredicate:byIsChecked] count];
}

- (BOOL)allItemsFinished
{
    return ([self countOfItemsCompleted:YES] == [[self items] count]);
}


- (void)removeItem:(MetaListItem *)item
{
    [NSException raise:@"Deprecated method" format:@"MetaListItem:removeItem:"];
    /*
    NSMutableSet *mutableItems = [self mutableSetValueForKey:@"items"];
    [mutableItems removeObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:self];
    */
}

- (void)addItem:(MetaListItem *)item
{
    [NSException raise:@"Deprecated method" format:@"MetaListItem:removeItem:"];
    /*
    NSMutableSet *mutableItems = [self mutableSetValueForKey:@"items"];
    [mutableItems addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_LIST_COUNTS object:self]; */
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


@end
