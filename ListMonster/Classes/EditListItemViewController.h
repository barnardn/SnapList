//
//  EditListItemViewController.h
//  ListMonster
//
//  Created by Norm Barnard on 2/17/11.
//  Copyright 2011 clamdango.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define elivcCOUNT_BUTTON_CELLS     3  

@class MetaList;
@class MetaListItem;
@class EditTextViewController;

@interface EditListItemViewController : UITableViewController {

    MetaList *theList;
    MetaListItem *theItem;
    NSArray *itemProperties;
    EditTextViewController *editViewController;
    NSMutableDictionary *editProperty;
    BOOL hasDirtyProperties;
}

@property(nonatomic,retain) MetaList *theList;
@property(nonatomic,retain) MetaListItem *theItem;
@property(nonatomic,retain) NSArray *itemProperties;
@property(nonatomic,retain) EditTextViewController *editViewController;
@property(nonatomic,retain) NSMutableDictionary *editProperty;
@property(nonatomic,assign) BOOL hasDirtyProperties;

- (id)initWithList:(MetaList *)list editItem:(MetaListItem *)listItem;

@end
