//
//  Category.h
//  ListMonster
//
//  Created by Norm Barnard on 1/16/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


#import "_ListCategory.h"

@interface ListCategory : _ListCategory

+ (NSArray *)allCategoriesInContext:(NSManagedObjectContext *)moc;

- (NSArray *)sortedLists;
- (void)save;

@end
