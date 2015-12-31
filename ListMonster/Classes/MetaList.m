//
//  List.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "DataManager.h"
#import "ListCategory.h"
#import "GzColors.h"
#import "MetaList.h"
#import "MetaListItem.h"
#import "NSArrayExtensions.h"
#import "NSStringExtensions.h"



@interface MetaList()

@end


@implementation MetaList

#pragma mark - class methods

+ (NSArray *)allUncategorizedListsInContext:(NSManagedObjectContext *)moc
{
    NSSortDescriptor *byOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *byName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSPredicate *emptyCategory = [NSPredicate predicateWithFormat:@"self.category == nil"];
    NSArray *lists = [DataManager fetchAllInstancesOf:LIST_ENTITY_NAME sortDescriptors:@[byOrder, byName] filteredBy:emptyCategory inContext:moc];
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
    if ([[self items] count] == 0) return NO;
    return ([self countOfItemsCompleted:YES] == [[self items] count]);
}

- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state {
    
    NSArray *allItems = [[self items] allObjects];
    NSArray *filteredItems = [allItems filteredArrayUsingPredicate:predicate];
    [filteredItems setValue:@(state) forKey:@"isChecked"];
}

- (NSArray <MetaListItem *> *)sortedItemsIncludingComplete:(BOOL)includeCompleted
{
    NSArray <MetaListItem *> *allItems = [[self items] allObjects];
    NSSortDescriptor *byOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray <MetaListItem *> *sorted = [allItems sortedArrayUsingDescriptors:@[byOrder]];
    if (includeCompleted) return sorted;
    NSPredicate *onlyIncomplete = [NSPredicate predicateWithFormat:@"isChecked == 0"];
    return [sorted filteredArrayUsingPredicate:onlyIncomplete];
}

- (UIColor *)listTintColor
{
    if ([[self tintColor] length] == 0) return nil;
    return [GzColors colorFromHex:[self tintColor]];
}


@end
