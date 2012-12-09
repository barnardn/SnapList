//
//  List.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "_MetaList.h"

#define LIST_ENTITY_NAME     @"MetaList"

@class MetaListItem;
@class ListCategory;
@class ListColor;

@interface MetaList : _MetaList {

}

- (void)save;
- (NSInteger)countOfItemsCompleted:(BOOL)completed;
- (BOOL)allItemsFinished;
- (void)deleteItem:(MetaListItem *)item;
- (BOOL)deleteAllItems;
- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state;
- (NSArray *)sortedItemsIncludingComplete:(BOOL)includeCompleted;
- (NSArray *)allCompletedItems;
- (NSArray *)allIncompletedItems;
- (NSString *)excerptOfLength:(NSInteger)numWords;
- (void)removeItem:(MetaListItem *)item;
- (void)addItem:(MetaListItem *)item;

+ (NSArray *)allListsInContext:(NSManagedObjectContext *)moc;
+ (NSArray *)allUncategorizedListsInContext:(NSManagedObjectContext *)moc;

@end
