//
//  BasePopoverNavigationController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/30/15.
//
//

#import <UIKit/UIKit.h>

@interface BasePopoverNavigationController : UINavigationController

+ (instancetype)popoverNavigationControllerWithRootViewController:(UIViewController *)rootViewController;

@end
