//
//  Category.m
//  ListMonster
//
//  Created by Norm Barnard on 1/16/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "DataManager.h"
#import "ListCategory.h"

static NSString * const kCategoryEntityName = @"ListCategory";

@implementation ListCategory

+ (NSArray *)allCategoriesInContext:(NSManagedObjectContext *)moc
{
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *byOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *categories = [DataManager fetchAllInstancesOf:kCategoryEntityName sortDescriptors:@[byOrder, byName] inContext:moc];
    return categories;
}

- (NSArray *)sortedLists
{
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *bySortOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    return [[self list] sortedArrayUsingDescriptors:@[bySortOrder, byName]];
}

- (void)save
{
    NSError *error = nil;
    ZAssert([[self managedObjectContext] save:&error], @"Unable to save category %@: %@", [self name], [error localizedDescription]);
    [self setIsNewValue:NO];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveIsNewValue:YES];
}


@end
