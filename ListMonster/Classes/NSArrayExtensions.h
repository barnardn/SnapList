//
//  NSArrayExtensions.h
//  DsqObsvervation
//
//  Created by Norm Barnard on 11/19/10.
//  Copyright 2010 National Heritage Academies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray(Extensions)

- (NSArray *)map:(id (^)(id obj))mapBlock;
//
// apply the mapBlock to each object in the NSArray and return
// an array of the resulting objects
//
- (void)forEach:(void (^)(id obj))eachBock;
//
// apply the eachBlock to each item in the array.  this method
// only cares about the side effect of the eachBlock.
//
- (NSArray *)filterBy:(BOOL (^)(id obj))predicate;
//
// apply the predicate block to each item in the NSArray and return 
// the resulting NSArray for objects that satisfy the predicate condition.
//
- (NSArray *)sliceAt:(NSInteger)start withLength:(NSInteger)length;
//
// a slice of the array starting at start with length length.
//


@end
