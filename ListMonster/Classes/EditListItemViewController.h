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

#define elivcCOUNT_BUTTON_CELLS     3  

@class MetaList;
@class MetaListItem;
@class EditTextViewController;

@interface EditListItemViewController : UITableViewController {

    MetaList *theList;
    MetaListItem *theItem;
    NSArray *editPropertySections;
    BOOL isModal;
    id<ListItemsViewControllerProtocol> delegate;
    
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) MetaListItem *theItem;
@property(nonatomic,retain) NSArray *editPropertySections;
@property(nonatomic,assign) BOOL isModal;
@property(nonatomic,assign) id<ListItemsViewControllerProtocol> delegate;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem;

@end
