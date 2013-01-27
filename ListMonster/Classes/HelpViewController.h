//
//  HelpViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 1/27/13.
//
//

#import <UIKit/UIKit.h>


@protocol HelpViewDelegate <NSObject>

- (void)dismissHelpView;

@end

@interface HelpViewController : UIViewController

@property (nonatomic, weak) id<HelpViewDelegate> delegate;

@end
