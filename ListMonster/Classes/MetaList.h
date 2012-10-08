//
//  List.h
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class MetaListItem;
@class Category;
@class ListColor;

@interface MetaList : NSManagedObject {

}

@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *listID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSSet *items;
@property (nonatomic, strong) Category *category;
@property (nonatomic, strong) ListColor *color;

- (BOOL)deleteAllItems;
- (void)setItemsMatching:(NSPredicate *)predicate toCheckedState:(NSInteger)state;
- (NSArray *)allCompletedItems;
- (NSArray *)allIncompletedItems;
- (NSString *)excerptOfLength:(NSInteger)numWords;
- (void)removeItem:(MetaListItem *)item;
- (void)addItem:(MetaListItem *)item;

@end
