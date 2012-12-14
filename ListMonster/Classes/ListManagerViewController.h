//
//  ListManagerViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/8/12.
//
//

#import <UIKit/UIKit.h>

#import "SwipeToEditCellTableViewController.h"

@protocol ListManagerDelegate <NSObject>

- (void)dismissListManagerView; // informs delegate to refresh any views before dismissing list manager view.

@end

@interface ListManagerViewController : SwipeToEditCellTableViewController

@property (nonatomic, weak) id<ListManagerDelegate> delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;


@end
