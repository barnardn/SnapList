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

@end
