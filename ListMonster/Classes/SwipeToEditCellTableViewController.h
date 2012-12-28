//
//  SwipeToEditCellTableViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 11/18/12.
//
//

#import <UIKit/UIKit.h>

typedef enum  {
    SwipeGestureRecognizerDirectionNone,
    SwipeGestureRecognizerDirectionRight,
    SwipeGestureRecognizerDirectionLeft
} SwipeGestureRecognizerDirection;


@interface SwipeToEditCellTableViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)removeSwipeActionIndicatorViewsFromCell:(UITableViewCell *)cell;

@end
