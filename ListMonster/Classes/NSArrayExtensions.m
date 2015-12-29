//
//  NSArrayExtensions.m
//  DsqObsvervation
//
//  Created by Norm Barnard on 11/19/10.
//  Copyright 2010 National Heritage Academies. All rights reserved.
//

#import "NSArrayExtensions.h"


@implementation NSArray(Extensions)

- (NSArray *)map:(id (^)(id obj))mapBlock {
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:0];
    for (id item in self) {
        [newArr addObject:mapBlock(item)];
    }
    return newArr;
}

- (void)forEach:(void (^)(id obj))eachBlock {
    for (id item in self) 
        eachBlock(item);
}

- (NSArray *)filterBy:(BOOL (^)(id obj))predicate {
    
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:0];
    for (id item in self) {
        if (predicate(item)) {
            [newArr addObject:item];
        }
    }
    return newArr;
}

- (id)findFirst:(BOOL (^)(id obj))predicate
{
    for (id item in self) {
        if (predicate(item))
            return item;
    }
    return nil;
}

- (NSInteger)findFirstIndex:(BOOL (^)(id obj))predicate
{
    for (NSUInteger idx = 0; idx < [self count]; idx++) {
        if (predicate(self[idx]))
            return idx;
    }
    return -1;
}


- (NSArray *)sliceAt:(NSInteger)start withLength:(NSInteger)length {
    
    if (start > ([self count] - 1)) return nil;
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:length];
    for (NSInteger idx = start; idx < (start + length); idx++)
        [newArr addObject:self[idx]];

    return newArr;
}

- (NSArray *)sortedOnKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSSortDescriptor *onKey = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending];
    return [self sortedArrayUsingDescriptors:@[onKey]];
}

- (id)firstItem
{
    return ([self count] > 0) ? [self objectAtIndex:0] : nil;
}

@end
