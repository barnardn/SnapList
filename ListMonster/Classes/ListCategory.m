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
    NSSortDescriptor *byOrder = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *categories = [DataManager fetchAllInstancesOf:kCategoryEntityName sortDescriptors:@[byOrder] inContext:moc];
    return categories;
}

- (NSArray *)sortedLists
{
    return [[self list] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

@end
