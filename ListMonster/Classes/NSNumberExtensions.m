//
//  NSNumberExtensions.m
//  ListMonster
//
//  Created by Norm Barnard on 2/13/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "NSNumberExtensions.h"


@implementation NSNumber(Extensions)


// naive implementation.
- (id)initWithString:(NSString *)stringValue {
    self = [super init];
    
    if (!stringValue || [stringValue isEqualToString:@""]) 
        return nil;
    
    NSArray *stringParts = [stringValue componentsSeparatedByString:@"."];
    if ([stringParts count] == 1) {
        return [self initWithInteger:[stringValue integerValue]];
    } 
    return [self initWithDouble:[stringValue doubleValue]];
}

+ (NSNumber *)numberWithString:(NSString *)stringValue {
    
    return [[[NSNumber alloc] initWithString:stringValue] autorelease];
}

@end
