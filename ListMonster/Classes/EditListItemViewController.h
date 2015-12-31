//
//  EditListItemViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ListItemsViewController.h"

@class MetaList;
@class MetaListItem;
@class EditTextViewController;

@interface EditListItemViewController : UITableViewController


@property(nonatomic,weak) id<ListItemsViewControllerProtocol> delegate;
- (id)initWithItem:(MetaListItem *)item;

@end
