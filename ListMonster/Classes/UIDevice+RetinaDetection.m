//
//  UIDevice+RetinaDetection.m
//  ListMonster
//
//  Created by Norm Barnard on 1/5/13.
//
//

#import "UIDevice+RetinaDetection.h"

@implementation UIDevice (RetinaDetection)

+ (BOOL)hasRetinaDisplay
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        return YES;
    }
    return NO;
}

@end
