//
//  NSString+EmptyString.m
//  ListMonster
//
//  Created by Norm Barnard on 5/27/12.
//  Copyright (c) 2012 clamdango.com. All rights reserved.
//

#import "NSString+EmptyString.h"

@implementation NSString (EmptyString)


- (BOOL)isEmptyString
{
    return ([self isEqualToString:@""]);
}

@end
