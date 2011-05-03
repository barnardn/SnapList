//
//  Tuple.m
//
//  Created by Norm Barnard on 7/9/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "Tuple.h"


@implementation Tuple

@synthesize first, second;

- (id)init {
    if (self = [super init]) {
        [self initWithFirst:nil second:nil];
    }
    return self;
}

- (id)initWithFirst:(id)f second:(id)s {
    if (self = [super init]) {
        [self setFirst:f];
        [self setSecond:s];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%@,%@)", [self first], [self second]];
}

+ (id)tupleWithFirst:(id)f second:(id)s {
    return [[[Tuple alloc] initWithFirst:f second:s] autorelease];
}


- (void)dealloc {
    [first release];
    [second release];
    [super dealloc];
}

@end
