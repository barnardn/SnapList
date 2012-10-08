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
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSArray *stringParts = [stringValue componentsSeparatedByString:@"."];
    if ([stringParts count] == 1) {
        NSNumber *intNum = [formatter numberFromString:stringValue];
        return (intNum) ? @([intNum intValue]) : nil;
    } 
    NSNumber *decimalNum = [formatter numberFromString:stringValue];
    return (decimalNum) ? [self initWithDouble:[decimalNum doubleValue]] : nil;
}

+ (NSNumber *)numberWithString:(NSString *)stringValue {
    
    return [[NSNumber alloc] initWithString:stringValue];
}

@end
