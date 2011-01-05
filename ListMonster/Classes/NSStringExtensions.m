//
//  NSStringExtensions.m
//  ListMonster
//
//  Created by Norm Barnard on 12/27/10.
//  Copyright 2010 clamdango.com. All rights reserved.
//

#import "NSStringExtensions.h"


@implementation NSString(Extensions)


+ (NSString *)stringWithUUID {
    
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
                                            //get the string representation of the UUID
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}


@end
