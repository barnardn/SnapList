//
//  ListCategoryViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 12/26/12.
//
//

#import "SwipeToEditCellTableViewController.h"

@interface ListCategoryViewController : SwipeToEditCellTableViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithList:(MetaList *)list;

@end
