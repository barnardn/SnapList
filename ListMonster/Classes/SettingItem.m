//
//  SettingItem.m
//  ListMonster
//
//  Created by Norm Barnard on 1/30/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import "SettingItem.h"


@implementation SettingItem

@synthesize itemTitle, detailTitle, viewControllerClass, viewControllerInfo;

- (id)initWithItemTitle:(NSString *)title viewControllerClass:(Class)controllerClass {
    if (!(self = [super init])) return nil;
    [self setItemTitle:title];
    [self setViewControllerClass:controllerClass];
    return self;
}

- (void)dealloc {
    [itemTitle release];
    [detailTitle release];
    [viewControllerClass release];
    [viewControllerInfo release];
}
@end
