//
//  BasePopoverNavigationController.m
//  ListMonster
//
//  Created by Norm Barnard on 12/30/15.
//
//

#import "BasePopoverNavigationController.h"

@interface BasePopoverNavigationController ()

@end

@implementation BasePopoverNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    return self;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationPopover;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self.viewControllers firstObject];
}

+ (instancetype)popoverNavigationControllerWithRootViewController:(UIViewController *)rootViewController; {
    return [[[self class] alloc] initWithRootViewController:rootViewController];
}


@end
